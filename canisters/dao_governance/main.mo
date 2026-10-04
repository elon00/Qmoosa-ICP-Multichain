import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Iter "mo:base/Iter";

actor QmoosaDAOGovernance {
  public type ProposalType = {
    #TokenMint : { recipient : Text; amount : Nat };
    #TreasuryDisbursement : { recipient : Text; amount : Nat; purpose : Text };
    #ProtocolUpgrade : { canister_id : Text; wasm_hash : Text };
    #LaunchpadPolicy : { min_allocation : Nat; fee_pct : Nat };
    #AgentToolAuth : { agent_name : Text; tool_name : Text; authorized : Bool };
  };
  public type ProposalStatus = { #Active; #Passed; #Rejected; #Executed };
  public type Proposal = { id : Nat; proposer : Text; title : Text; description : Text; proposal_type : ProposalType; yes_votes : Nat; no_votes : Nat; quorum : Nat; created_at : Int; voting_deadline : Int; timelock_until : Int; status : ProposalStatus };
  public type Neuron = { neuron_id : Nat; owner : Text; staked_amount : Nat; dissolve_delay_seconds : Int; voting_power : Nat; created_at : Int; is_dissolving : Bool };

  stable var neuron_counter : Nat = 0;
  stable var proposal_counter : Nat = 0;
  stable var treasury_balance : Nat = 150_000_000_00000000;
  stable var total_staked : Nat = 0;
  stable var total_voting_power : Nat = 0;

  let neurons = HashMap.HashMap<Text, Neuron>(100, Text.equal, Text.hash);
  var proposals_list : [Proposal] = [];
  let votes_cast = HashMap.HashMap<Text, Bool>(200, Text.equal, Text.hash);

  public shared({ caller }) func stake_neuron(amount : Nat, dissolve_delay_seconds : Int) : async { #Ok : Neuron; #Err : Text } {
    if (Principal.isAnonymous(caller)) return #Err("Anonymous staking is not allowed");
    if (amount < 100_000_000) return #Err("Minimum stake is 1 QMOOSA");
    if (dissolve_delay_seconds < 86_400) return #Err("Minimum dissolve delay is 1 day");
    neuron_counter += 1;
    let bonus = if (dissolve_delay_seconds >= 15_552_000) 2 else 1;
    let n : Neuron = { neuron_id = neuron_counter; owner = Principal.toText(caller); staked_amount = amount; dissolve_delay_seconds = dissolve_delay_seconds; voting_power = amount * bonus; created_at = Time.now(); is_dissolving = false };
    neurons.put(Nat.toText(neuron_counter), n);
    total_staked += amount;
    total_voting_power += n.voting_power;
    #Ok(n)
  };

  public query func get_neuron(neuron_id : Nat) : async ?Neuron { neurons.get(Nat.toText(neuron_id)) };

  public shared query({ caller }) func get_my_neurons() : async [Neuron] {
    let owner = Principal.toText(caller);
    var out : [Neuron] = [];
    for ((_, n) in neurons.entries()) { if (n.owner == owner) out := Array.append(out, [n]) };
    out
  };

  public shared({ caller }) func submit_proposal(req : { title : Text; description : Text; proposal_type : ProposalType }) : async { #Ok : Nat; #Err : Text } {
    if (Principal.isAnonymous(caller)) return #Err("Anonymous proposals are not allowed");
    var eligible = false;
    for ((_, n) in neurons.entries()) { if (n.owner == Principal.toText(caller) and n.voting_power > 0) eligible := true };
    if (not eligible) return #Err("A staked governance neuron is required");
    proposal_counter += 1;
    let now = Time.now();
    let p : Proposal = { id = proposal_counter; proposer = Principal.toText(caller); title = req.title; description = req.description; proposal_type = req.proposal_type; yes_votes = 0; no_votes = 0; quorum = 5_000_000; created_at = now; voting_deadline = now + 259_200_000_000_000; timelock_until = now + 345_600_000_000_000; status = #Active };
    proposals_list := Array.append(proposals_list, [p]);
    #Ok(proposal_counter)
  };

  public shared({ caller }) func vote(args : { proposal_id : Nat; neuron_id : Nat; approve : Bool }) : async { #Ok : Text; #Err : Text } {
    if (Principal.isAnonymous(caller)) return #Err("Anonymous voting is not allowed");
    let n = switch (neurons.get(Nat.toText(args.neuron_id))) { case null return #Err("Neuron not found"); case (?x) x };
    if (n.owner != Principal.toText(caller)) return #Err("Caller does not own this neuron");
    let key = Nat.toText(args.proposal_id) # "#" # Nat.toText(args.neuron_id);
    switch (votes_cast.get(key)) { case (?_) return #Err("Neuron already voted"); case null {} };
    var updated = false;
    var i = 0;
    while (i < proposals_list.size()) {
      let p = proposals_list[i];
      if (p.id == args.proposal_id) {
        if (Time.now() > p.voting_deadline) return #Err("Voting period has ended");
        let yes = if (args.approve) p.yes_votes + n.voting_power else p.yes_votes;
        let no = if (args.approve) p.no_votes else p.no_votes + n.voting_power;
        let nextStatus = if (yes >= p.quorum and yes > no) #Passed else p.status;
        let q : Proposal = { id=p.id; proposer=p.proposer; title=p.title; description=p.description; proposal_type=p.proposal_type; yes_votes=yes; no_votes=no; quorum=p.quorum; created_at=p.created_at; voting_deadline=p.voting_deadline; timelock_until=p.timelock_until; status=nextStatus };
        var copy : [Proposal] = [];
        for (idx in Iter.range(0, proposals_list.size() - 1)) { copy := Array.append(copy, [if (idx == i) q else proposals_list[idx]]) };
        proposals_list := copy; updated := true;
      };
      i += 1;
    };
    if (not updated) return #Err("Proposal not found");
    votes_cast.put(key, args.approve);
    #Ok("Vote recorded")
  };

  public func execute_proposal(proposal_id : Nat) : async { #Ok : Text; #Err : Text } {
    for (p in proposals_list.vals()) {
      if (p.id == proposal_id) {
        if (p.status != #Passed) return #Err("Proposal is not passed");
        if (Time.now() < p.timelock_until) return #Err("Timelock has not elapsed");
        return #Err("Execution adapter is intentionally disabled until SNS/canister-call wiring is complete");
      }
    };
    #Err("Proposal not found")
  };

  public query func get_proposals() : async [Proposal] { proposals_list };
  public query func get_proposal(id : Nat) : async ?Proposal { for (p in proposals_list.vals()) { if (p.id == id) return ?p }; null };
  public query func get_dao_stats() : async { total_staked : Nat; total_voting_power : Nat; total_proposals : Nat; treasury_balance : Nat; active_neurons_count : Nat; execution_status : Text } {
    { total_staked=total_staked; total_voting_power=total_voting_power; total_proposals=proposal_counter; treasury_balance=treasury_balance; active_neurons_count=neuron_counter; execution_status="LOCKED_PENDING_SNS_INTEGRATION" }
  };
}
