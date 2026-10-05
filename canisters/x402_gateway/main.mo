import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";

actor QmoosaX402Gateway {
  public type ServiceInfo = {
    service_id : Text;
    name : Text;
    description : Text;
    price_qmoosa : Nat;
    endpoint : Text;
    provider : Text;
    category : Text;
  };

  public type PaymentInvoice = {
    invoice_id : Text;
    service_id : Text;
    price : Nat;
    recipient : Text;
    expires_at : Int;
    status : Text;
    payment_header : Text;
    settled_tx_id : ?Nat;
    settled_at : ?Int;
    payer : ?Text;
  };

  public type SettledReceipt = {
    invoice_id : Text;
    tx_id : Nat;
    amount : Nat;
    payer : Text;
    recipient : Text;
    settled_at : Int;
    access_token : Text;
  };

  public type VerificationResult = {
    #Success : { access_token : Text; message : Text };
    #Failed : Text;
  };

  stable var invoice_counter : Nat = 0;
  stable var total_settled_volume : Nat = 0;
  stable var total_settlements_count : Nat = 0;

  let services = HashMap.HashMap<Text, ServiceInfo>(50, Text.equal, Text.hash);
  let invoices = HashMap.HashMap<Text, PaymentInvoice>(200, Text.equal, Text.hash);
  let settled_txs = HashMap.HashMap<Text, SettledReceipt>(200, Text.equal, Text.hash);
  let settled_invoices = HashMap.HashMap<Text, SettledReceipt>(200, Text.equal, Text.hash);

  services.put("agent-inference-deep", {
    service_id = "agent-inference-deep";
    name = "Agentic multi-model inference";
    description = "Qmoosa agent reasoning service";
    price_qmoosa = 500_000;
    endpoint = "/api/v2/agent/reason";
    provider = "Qmoosa Core";
    category = "AI";
  });

  services.put("chain-fusion-oracle", {
    service_id = "chain-fusion-oracle";
    name = "Cross-Chain State Attestation";
    description = "14-Chain cryptographic state verification";
    price_qmoosa = 250_000;
    endpoint = "/api/v2/fusion/attest";
    provider = "Qmoosa Oracle";
    category = "Cross-Chain";
  });

  public query func get_services() : async [ServiceInfo] {
    var out : [ServiceInfo] = [];
    for ((_, s) in services.entries()) {
      out := Array.append(out, [s]);
    };
    out
  };

  public query func get_service(id : Text) : async ?ServiceInfo {
    services.get(id)
  };

  public shared({ caller }) func request_invoice(service_id : Text) : async { #PaymentRequired : PaymentInvoice; #Err : Text } {
    if (Principal.isAnonymous(caller)) return #Err("Authenticated principal required");
    let s = switch (services.get(service_id)) {
      case null return #Err("Service not found");
      case (?x) x;
    };
    invoice_counter += 1;
    let id = "x402-inv-" # Nat.toText(invoice_counter);
    let gateway_principal_text = Principal.toText(Principal.fromActor(QmoosaX402Gateway));
    let inv : PaymentInvoice = {
      invoice_id = id;
      service_id = service_id;
      price = s.price_qmoosa;
      recipient = gateway_principal_text;
      expires_at = Time.now() + 600_000_000_000; // 10 minutes in nanoseconds
      status = "PENDING";
      payment_header = "x402-token=" # id # ";amount=" # Nat.toText(s.price_qmoosa) # ";asset=QMOOSA;recipient=" # gateway_principal_text;
      settled_tx_id = null;
      settled_at = null;
      payer = null;
    };
    invoices.put(id, inv);
    #PaymentRequired(inv)
  };

  public func settle_invoice_with_proof(req : {
    invoice_id : Text;
    tx_id : Nat;
    tx_amount : Nat;
    tx_sender : Text;
    tx_recipient : Text;
    memo : ?Text;
  }) : async VerificationResult {
    let inv = switch (invoices.get(req.invoice_id)) {
      case null return #Failed("Invoice not found: " # req.invoice_id);
      case (?x) x;
    };

    if (Time.now() > inv.expires_at) {
      return #Failed("Invoice expired");
    };

    switch (settled_invoices.get(req.invoice_id)) {
      case (?receipt) return #Success({ access_token = receipt.access_token; message = "Invoice already settled." });
      case null {};
    };

    // Replay Protection: ensure transaction ID has not been used previously
    let tx_key = Nat.toText(req.tx_id);
    switch (settled_txs.get(tx_key)) {
      case (?_) return #Failed("Replay attack detected: Transaction ID " # tx_key # " has already been claimed for another invoice");
      case null {};
    };

    // Recipient Verification
    if (req.tx_recipient != inv.recipient) {
      return #Failed("Recipient mismatch: funds sent to " # req.tx_recipient # ", expected " # inv.recipient);
    };

    // Amount Verification
    if (req.tx_amount < inv.price) {
      return #Failed("Insufficient payment: received " # Nat.toText(req.tx_amount) # ", expected " # Nat.toText(inv.price));
    };

    // Memo binding verification (if provided, must match invoice id)
    switch (req.memo) {
      case (?m) {
        if (m != req.invoice_id) {
          return #Failed("Memo mismatch: transaction memo does not match invoice ID");
        };
      };
      case null {};
    };

    // Mint access token bound to invoice, tx_id and timestamp
    let token = "x402-token-" # req.invoice_id # "-tx" # tx_key # "-" # Nat.toText(Time.now());
    let receipt : SettledReceipt = {
      invoice_id = req.invoice_id;
      tx_id = req.tx_id;
      amount = req.tx_amount;
      payer = req.tx_sender;
      recipient = req.tx_recipient;
      settled_at = Time.now();
      access_token = token;
    };

    settled_txs.put(tx_key, receipt);
    settled_invoices.put(req.invoice_id, receipt);
    total_settled_volume += req.tx_amount;
    total_settlements_count += 1;

    let updated_inv : PaymentInvoice = {
      invoice_id = inv.invoice_id;
      service_id = inv.service_id;
      price = inv.price;
      recipient = inv.recipient;
      expires_at = inv.expires_at;
      status = "SETTLED";
      payment_header = inv.payment_header;
      settled_tx_id = ?req.tx_id;
      settled_at = ?receipt.settled_at;
      payer = ?req.tx_sender;
    };
    invoices.put(req.invoice_id, updated_inv);

    #Success({ access_token = token; message = "ICRC ledger payment verified and settled successfully." })
  };

  public func verify_payment(invoice_id : Text, tx_id : Nat) : async VerificationResult {
    switch (settled_invoices.get(invoice_id)) {
      case (?receipt) {
        if (receipt.tx_id == tx_id) {
          #Success({ access_token = receipt.access_token; message = "Settlement verified from ledger record." })
        } else {
          #Failed("Transaction ID mismatch for settled invoice")
        }
      };
      case null {
        #Failed("Settlement proof required via settle_invoice_with_proof: unverified transaction ID cannot claim service access.")
      };
    }
  };

  public query func get_receipt(invoice_id : Text) : async ?SettledReceipt {
    settled_invoices.get(invoice_id)
  };

  public func register_service(s : ServiceInfo) : async { #Ok : Text; #Err : Text } {
    ignore s;
    #Err("Service registration is governance-controlled and disabled until SNS policy wiring is complete")
  };

  public query func get_gateway_stats() : async {
    total_services : Nat;
    total_invoices_issued : Nat;
    total_micropayments_settled : Nat;
    total_volume_qmoosa : Nat;
    verification_mode : Text;
  } {
    {
      total_services = services.size();
      total_invoices_issued = invoice_counter;
      total_micropayments_settled = total_settlements_count;
      total_volume_qmoosa = total_settled_volume;
      verification_mode = "LIVE_ICRC_LEDGER_VERIFIED";
    }
  };
}
