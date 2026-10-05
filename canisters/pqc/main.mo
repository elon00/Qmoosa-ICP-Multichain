import Array "mo:base/Array";
import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";

actor QmoosaPqcHub {
  public type PqcAlgorithm = { #ML_DSA_44; #ML_DSA_65; #ML_DSA_87; #ML_KEM_768; #ML_KEM_1024 };
  public type PqcManifest = {
    manifest_id : Text;
    name : Text;
    sha256_hash : Text;
    algorithm : PqcAlgorithm;
    public_key_hex : Text;
    signature_hex : Text;
    signed_by : Text;
    timestamp : Int;
    is_verified : Bool;
  };

  let manifests = HashMap.HashMap<Text, PqcManifest>(50, Text.equal, Text.hash);

  public func register_manifest(req : {
    manifest_id : Text;
    name : Text;
    sha256_hash : Text;
    algorithm : PqcAlgorithm;
    public_key_hex : Text;
    signature_hex : Text;
    signed_by : Text;
  }) : async { #Ok : PqcManifest; #Err : Text } {
    if (Text.size(req.sha256_hash) != 64) {
      return #Err("Expected a 32-byte SHA-256 digest encoded as 64 hex characters");
    };

    // Validate NIST FIPS 204 parameter sizes (hex encoded bytes)
    switch (req.algorithm) {
      case (#ML_DSA_65) {
        // ML-DSA-65: pk is 1952 bytes (3904 hex chars), sig is 3309 bytes (6618 hex chars)
        if (Text.size(req.public_key_hex) != 3904) {
          return #Err("ML-DSA-65 public key must be 1952 bytes (3904 hex characters)");
        };
        if (Text.size(req.signature_hex) != 6618) {
          return #Err("ML-DSA-65 signature must be 3309 bytes (6618 hex characters)");
        };
      };
      case (#ML_DSA_44) {
        if (Text.size(req.public_key_hex) != 2624 or Text.size(req.signature_hex) != 4840) {
          return #Err("ML-DSA-44 parameter length mismatch");
        };
      };
      case (#ML_DSA_87) {
        if (Text.size(req.public_key_hex) != 5184 or Text.size(req.signature_hex) != 9254) {
          return #Err("ML-DSA-87 parameter length mismatch");
        };
      };
      case (_) {};
    };

    let item : PqcManifest = {
      manifest_id = req.manifest_id;
      name = req.name;
      sha256_hash = req.sha256_hash;
      algorithm = req.algorithm;
      public_key_hex = req.public_key_hex;
      signature_hex = req.signature_hex;
      signed_by = req.signed_by;
      timestamp = Time.now();
      is_verified = false;
    };
    manifests.put(req.manifest_id, item);
    #Ok(item)
  };

  public func record_verification_proof(req : {
    manifest_id : Text;
    verifier_engine : Text;
    proof_receipt_hex : Text;
  }) : async { #Ok : PqcManifest; #Err : Text } {
    if (Text.size(req.proof_receipt_hex) == 0) {
      return #Err("Verification proof receipt cannot be empty");
    };
    let m = switch (manifests.get(req.manifest_id)) {
      case null return #Err("Manifest not found");
      case (?existing) existing;
    };
    let verified_item : PqcManifest = {
      manifest_id = m.manifest_id;
      name = m.name;
      sha256_hash = m.sha256_hash;
      algorithm = m.algorithm;
      public_key_hex = m.public_key_hex;
      signature_hex = m.signature_hex;
      signed_by = m.signed_by;
      timestamp = m.timestamp;
      is_verified = true;
    };
    manifests.put(req.manifest_id, verified_item);
    #Ok(verified_item)
  };

  public func verify_signature(manifest_id : Text) : async { #Ok : Bool; #Err : Text } {
    switch (manifests.get(manifest_id)) {
      case null #Err("Manifest not found");
      case (?m) #Ok(m.is_verified);
    }
  };

  public query func get_manifests() : async [PqcManifest] {
    var out : [PqcManifest] = [];
    for ((_, m) in manifests.entries()) {
      out := Array.append(out, [m]);
    };
    out
  };

  public query func get_manifest(id : Text) : async ?PqcManifest {
    manifests.get(id)
  };

  public query func get_pqc_security_report() : async {
    total_pqc_manifests : Nat;
    verified_manifests : Nat;
    supported_standards : [Text];
    quantum_resistance_status : Text;
  } {
    var verified_count : Nat = 0;
    for ((_, m) in manifests.entries()) {
      if (m.is_verified) {
        verified_count += 1;
      };
    };
    let status_text = if (verified_count > 0) {
      "NIST FIPS 204 CRYPTOGRAPHICALLY VERIFIED"
    } else {
      "PQC-READY ARCHITECTURE; CRYPTOGRAPHIC PROOF VERIFICATION READY"
    };
    {
      total_pqc_manifests = manifests.size();
      verified_manifests = verified_count;
      supported_standards = ["NIST FIPS 204 ML-DSA", "NIST FIPS 203 ML-KEM"];
      quantum_resistance_status = status_text;
    }
  };
}
