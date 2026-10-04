import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";

actor QmoosaToken {
  public type Account = { owner : Principal; subaccount : ?Blob };
  public type TransferArgs = { from_subaccount : ?Blob; to : Account; amount : Nat; fee : ?Nat; memo : ?Blob; created_at_time : ?Int };
  public type ApproveArgs = { from_subaccount : ?Blob; spender : Account; amount : Nat; expected_allowance : ?Nat; expires_at : ?Int; fee : ?Nat; memo : ?Blob; created_at_time : ?Int };
  public type TransferResult = { #Ok : Nat; #Err : Text };
  public type ApproveResult = { #Ok : Nat; #Err : Text };
  public type Transaction = { id : Nat; timestamp : Int; tx_type : Text; from : Text; to : Text; amount : Nat; fee : Nat };

  stable var token_name : Text = "Qmoosa ICP";
  stable var token_symbol : Text = "QMOOSA";
  stable var token_decimals : Nat8 = 8;
  stable var token_fee : Nat = 10_000;
  stable var total_circulating_supply : Nat = 1_000_000_000_00000000;
  stable var tx_counter : Nat = 0;

  let balances = HashMap.HashMap<Text, Nat>(100, Text.equal, Text.hash);
  let allowances = HashMap.HashMap<Text, Nat>(100, Text.equal, Text.hash);
  var transaction_log : [Transaction] = [];

  balances.put("2vxsx-fae", total_circulating_supply);

  public query func icrc1_name() : async Text { token_name };
  public query func icrc1_symbol() : async Text { token_symbol };
  public query func icrc1_decimals() : async Nat8 { token_decimals };
  public query func icrc1_fee() : async Nat { token_fee };
  public query func icrc1_total_supply() : async Nat { total_circulating_supply };

  public query func icrc1_balance_of(acc : Account) : async Nat {
    switch (balances.get(Principal.toText(acc.owner))) { case null 0; case (?b) b }
  };

  public shared({ caller }) func icrc1_transfer(args : TransferArgs) : async TransferResult {
    if (Principal.isAnonymous(caller)) return #Err("Anonymous transfers are not allowed");
    let sender = Principal.toText(caller);
    let recipient = Principal.toText(args.to.owner);
    let senderBal = switch (balances.get(sender)) { case null 0; case (?b) b };
    let effectiveFee = switch (args.fee) { case (?f) f; case null token_fee };
    if (effectiveFee != token_fee) return #Err("Bad fee");
    if (senderBal < args.amount + effectiveFee) return #Err("Insufficient funds");
    balances.put(sender, senderBal - args.amount - effectiveFee);
    let receiverBal = switch (balances.get(recipient)) { case null 0; case (?b) b };
    balances.put(recipient, receiverBal + args.amount);
    tx_counter += 1;
    transaction_log := Array.append(transaction_log, [{ id = tx_counter; timestamp = Time.now(); tx_type = "Transfer"; from = sender; to = recipient; amount = args.amount; fee = effectiveFee }]);
    #Ok(tx_counter)
  };

  public shared({ caller }) func icrc2_approve(args : ApproveArgs) : async ApproveResult {
    if (Principal.isAnonymous(caller)) return #Err("Anonymous approvals are not allowed");
    let owner = Principal.toText(caller);
    let spender = Principal.toText(args.spender.owner);
    allowances.put(owner # "#" # spender, args.amount);
    tx_counter += 1;
    #Ok(tx_counter)
  };

  public query func icrc2_allowance(req : { account : Account; spender : Account }) : async { allowance : Nat; expires_at : ?Int } {
    let key = Principal.toText(req.account.owner) # "#" # Principal.toText(req.spender.owner);
    { allowance = switch (allowances.get(key)) { case null 0; case (?a) a }; expires_at = null }
  };

  // Disabled until an SNS-controlled minting path is wired to the ledger.
  public shared({ caller }) func dao_mint(args : { to : Account; amount : Nat; proposal_id : Nat }) : async TransferResult {
    ignore caller; ignore args;
    #Err("DAO minting is disabled until SNS governance and proposal execution are cryptographically wired")
  };

  public shared({ caller }) func burn(args : { amount : Nat; memo : ?Text }) : async TransferResult {
    if (Principal.isAnonymous(caller)) return #Err("Anonymous burns are not allowed");
    let sender = Principal.toText(caller);
    let bal = switch (balances.get(sender)) { case null 0; case (?b) b };
    if (bal < args.amount) return #Err("Insufficient balance to burn");
    balances.put(sender, bal - args.amount);
    total_circulating_supply -= args.amount;
    tx_counter += 1;
    transaction_log := Array.append(transaction_log, [{ id = tx_counter; timestamp = Time.now(); tx_type = "Burn"; from = sender; to = "burn"; amount = args.amount; fee = 0 }]);
    #Ok(tx_counter)
  };

  public query func get_token_metadata() : async {
    name : Text; symbol : Text; decimals : Nat8; fee : Nat; total_supply : Nat; supply_model : Text; mainnet_minting_status : Text
  } {
    { name = token_name; symbol = token_symbol; decimals = token_decimals; fee = token_fee; total_supply = total_circulating_supply;
      supply_model = "Uncapped supply policy requires SNS governance approval";
      mainnet_minting_status = "LOCKED_PENDING_SNS_INTEGRATION" }
  };

  public query func get_transactions(offset : Nat, limit : Nat) : async [Transaction] {
    ignore offset; ignore limit; transaction_log
  };
}
