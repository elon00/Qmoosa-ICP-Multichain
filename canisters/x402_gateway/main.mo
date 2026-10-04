import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";

actor QmoosaX402Gateway {
  public type ServiceInfo = { service_id : Text; name : Text; description : Text; price_qmoosa : Nat; endpoint : Text; provider : Text; category : Text };
  public type PaymentInvoice = { invoice_id : Text; service_id : Text; price : Nat; recipient : Text; expires_at : Int; status : Text; payment_header : Text };
  public type VerificationResult = { #Success : { access_token : Text; message : Text }; #Failed : Text };

  stable var invoice_counter : Nat = 0;
  let services = HashMap.HashMap<Text, ServiceInfo>(50, Text.equal, Text.hash);
  let invoices = HashMap.HashMap<Text, PaymentInvoice>(200, Text.equal, Text.hash);

  services.put("agent-inference-deep", { service_id="agent-inference-deep"; name="Agentic multi-model inference"; description="Qmoosa agent reasoning service"; price_qmoosa=500_000; endpoint="/api/v2/agent/reason"; provider="Qmoosa Core"; category="AI" });

  public query func get_services() : async [ServiceInfo] { var out:[ServiceInfo]=[]; for ((_,s) in services.entries()) out := Array.append(out,[s]); out };
  public query func get_service(id : Text) : async ?ServiceInfo { services.get(id) };

  public shared({ caller }) func request_invoice(service_id : Text) : async { #PaymentRequired : PaymentInvoice; #Err : Text } {
    if (Principal.isAnonymous(caller)) return #Err("Authenticated principal required");
    let s = switch (services.get(service_id)) { case null return #Err("Service not found"); case (?x) x };
    invoice_counter += 1;
    let id = "x402-inv-" # Nat.toText(invoice_counter);
    let inv : PaymentInvoice = { invoice_id=id; service_id=service_id; price=s.price_qmoosa; recipient=Principal.toText(Principal.fromActor(QmoosaX402Gateway)); expires_at=Time.now()+600_000_000_000; status="PENDING_PAYMENT"; payment_header="x402-token=" # id # ";amount=" # Nat.toText(s.price_qmoosa) # ";asset=QMOOSA" };
    invoices.put(id, inv);
    #PaymentRequired(inv)
  };

  public func verify_payment(invoice_id : Text, tx_id : Nat) : async VerificationResult {
    ignore tx_id;
    let inv = switch (invoices.get(invoice_id)) { case null return #Failed("Invoice not found"); case (?x) x };
    if (Time.now() > inv.expires_at) return #Failed("Invoice expired");
    #Failed("Live settlement verification is not configured. Refusing to grant access without cryptographic ledger proof.")
  };

  public func register_service(s : ServiceInfo) : async { #Ok : Text; #Err : Text } {
    ignore s;
    #Err("Service registration is governance-controlled and disabled until SNS policy wiring is complete")
  };

  public query func get_gateway_stats() : async { total_services : Nat; total_invoices_issued : Nat; verification_mode : Text } {
    { total_services=services.size(); total_invoices_issued=invoice_counter; verification_mode="FAIL_CLOSED_PENDING_LEDGER_VERIFIER" }
  };
}
