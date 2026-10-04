import Array "mo:base/Array";
import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";

actor QmoosaPqcHub {
  public type PqcAlgorithm = { #ML_DSA_44; #ML_DSA_65; #ML_DSA_87; #ML_KEM_768; #ML_KEM_1024 };
  public type PqcManifest = { manifest_id : Text; name : Text; sha256_hash : Text; algorithm : PqcAlgorithm; public_key_hex : Text; signature_hex : Text; signed_by : Text; timestamp : Int; is_verified : Bool };
  let manifests = HashMap.HashMap<Text, PqcManifest>(50, Text.equal, Text.hash);

  public func register_manifest(req : { manifest_id : Text; name : Text; sha256_hash : Text; algorithm : PqcAlgorithm; public_key_hex : Text; signature_hex : Text; signed_by : Text }) : async { #Ok : PqcManifest; #Err : Text } {
    if (Text.size(req.sha256_hash) != 64) return #Err("Expected a 32-byte SHA-256 digest encoded as 64 hex characters");
    let item : PqcManifest = { manifest_id=req.manifest_id; name=req.name; sha256_hash=req.sha256_hash; algorithm=req.algorithm; public_key_hex=req.public_key_hex; signature_hex=req.signature_hex; signed_by=req.signed_by; timestamp=Time.now(); is_verified=false };
    manifests.put(req.manifest_id,item);
    #Ok(item)
  };

  public func verify_signature(manifest_id : Text) : async { #Ok : Bool; #Err : Text } {
    switch (manifests.get(manifest_id)) {
      case null #Err("Manifest not found");
      case (?_) #Err("No in-canister FIPS 204 verifier is integrated; verification must not be inferred from signature length or metadata")
    }
  };

  public query func get_manifests() : async [PqcManifest] { var out:[PqcManifest]=[]; for ((_,m) in manifests.entries()) out:=Array.append(out,[m]); out };
  public query func get_manifest(id : Text) : async ?PqcManifest { manifests.get(id) };
  public query func get_pqc_security_report() : async { total_pqc_manifests : Nat; verified_manifests : Nat; supported_standards : [Text]; quantum_resistance_status : Text } {
    { total_pqc_manifests=manifests.size(); verified_manifests=0; supported_standards=["NIST FIPS 204 ML-DSA","NIST FIPS 203 ML-KEM"]; quantum_resistance_status="PQC-READY ARCHITECTURE; CRYPTOGRAPHIC VERIFIER NOT YET INTEGRATED" }
  };
}
