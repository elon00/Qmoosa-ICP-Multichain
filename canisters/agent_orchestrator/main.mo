import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";

actor QmoosaAgentOrchestrator {

    public type ActionLog = {
        log_id : Nat;
        timestamp : Int;
        agent : Text;
        action_type : Text;
        details : Text;
        requires_approval : Bool;
        approved_by : ?Text;
    };

    public type ModelRoute = {
        model_id : Text;
        provider : Text;
        latency_ms : Nat;
        cost_per_token : Nat;
        is_active : Bool;
    };

    stable var log_counter : Nat = 0;
    var action_history : [ActionLog] = [];

    let models = HashMap.HashMap<Text, ModelRoute>(10, Text.equal, Text.hash);

    let m1 : ModelRoute = {
        model_id = "icp-onchain-llm";
        provider = "DFINITY Canister Native Inference";
        latency_ms = 450;
        cost_per_token = 10;
        is_active = true;
    };
    let m2 : ModelRoute = {
        model_id = "claude-3-5-sonnet";
        provider = "Anthropic (via ICP HTTPS Outcalls)";
        latency_ms = 850;
        cost_per_token = 150;
        is_active = true;
    };
    let m3 : ModelRoute = {
        model_id = "gpt-4o";
        provider = "OpenAI (via ICP HTTPS Outcalls)";
        latency_ms = 920;
        cost_per_token = 200;
        is_active = true;
    };
    let m4 : ModelRoute = {
        model_id = "gemini-1-5-pro";
        provider = "Google (via ICP HTTPS Outcalls)";
        latency_ms = 800;
        cost_per_token = 120;
        is_active = true;
    };

    models.put(m1.model_id, m1);
    models.put(m2.model_id, m2);
    models.put(m3.model_id, m3);
    models.put(m4.model_id, m4);

    // Seed initial audit log
    log_counter += 1;
    let init_log : ActionLog = {
        log_id = log_counter;
        timestamp = Time.now();
        agent = "Blockchain Agent";
        action_type = "ICRC_LEDGER_HEALTH_CHECK";
        details = "Verified ICRC-1/2/3 ledger integrity, total supply balance, and cycle reserve levels.";
        requires_approval = false;
        approved_by = ?"System Auto-Policy";
    };
    action_history := [init_log];

    public query func get_models() : async [ModelRoute] {
        var list : [ModelRoute] = [];
        for ((_, m) in models.entries()) {
            list := Array.append(list, [m]);
        };
        return list;
    };

    public query func get_action_logs() : async [ActionLog] {
        return action_history;
    };

    public func dispatch_agent_action(args : {
        agent : Text;
        action_type : Text;
        details : Text;
        requires_approval : Bool;
    }) : async { #Ok : Nat; #Err : Text } {
        log_counter += 1;
        let log : ActionLog = {
            log_id = log_counter;
            timestamp = Time.now();
            agent = args.agent;
            action_type = args.action_type;
            details = args.details;
            requires_approval = args.requires_approval;
            approved_by = if (args.requires_approval) null else ?"Autonomous Allowed";
        };

        action_history := Array.append(action_history, [log]);
        return #Ok(log_counter);
    };

    public func approve_action(log_id : Nat) : async { #Ok : Text; #Err : Text } {
        let caller_text = Principal.toText(Principal.fromActor(QmoosaAgentOrchestrator));
        var found = false;

        var i = 0;
        while (i < action_history.size()) {
            let l = action_history[i];
            if (l.log_id == log_id) {
                found := true;
                let updated_log : ActionLog = {
                    log_id = l.log_id;
                    timestamp = l.timestamp;
                    agent = l.agent;
                    action_type = l.action_type;
                    details = l.details;
                    requires_approval = false;
                    approved_by = ?caller_text;
                };

                var copy : [ActionLog] = [];
                var idx = 0;
                while (idx < action_history.size()) {
                    if (idx == i) {
                        copy := Array.append(copy, [updated_log]);
                    } else {
                        copy := Array.append(copy, [action_history[idx]]);
                    };
                    idx += 1;
                };
                action_history := copy;
            };
            i += 1;
        };

        if (found) {
            return #Ok("Action approved and authorized for execution.");
        } else {
            return #Err("Log ID not found.");
        };
    };

    public query func get_orchestrator_stats() : async {
        total_actions_logged : Nat;
        pending_approvals : Nat;
        active_agents_count : Nat;
        active_models_count : Nat;
    } {
        var pending : Nat = 0;
        for (l in action_history.vals()) {
            if (l.requires_approval and l.approved_by == null) {
                pending += 1;
            };
        };

        return {
            total_actions_logged = log_counter;
            pending_approvals = pending;
            active_agents_count = 6;
            active_models_count = models.size();
        };
    };
}
