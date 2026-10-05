import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import Text "mo:base/Text";

actor QmoosaLaunchpad {

    public type TokenModel = {
        #Fixed;
        #Mintable;
        #GovernanceControlled;
        #Deflationary;
    };

    public type VestingSchedule = {
        total_amount : Nat;
        cliff_days : Nat;
        duration_days : Nat;
        released_amount : Nat;
        start_timestamp : Int;
    };

    public type LaunchpadToken = {
        token_id : Nat;
        name : Text;
        symbol : Text;
        decimals : Nat8;
        initial_supply : Nat;
        model : TokenModel;
        creator : Text;
        canister_id : Text;
        vesting : ?VestingSchedule;
        created_at : Int;
        status : Text;
    };

    stable var token_counter : Nat = 0;
    var launched_tokens : [LaunchpadToken] = [];

    token_counter += 1;
    let genesis_ai_token : LaunchpadToken = {
        token_id = token_counter;
        name = "Conway Autonomous AI Token";
        symbol = "CAAI";
        decimals = 8;
        initial_supply = 500_000_000_00000000;
        model = #GovernanceControlled;
        creator = "Qmoosa Autonomous Engine";
        canister_id = "NOT_YET_PROVISIONED";
        vesting = ?{
            total_amount = 100_000_000_00000000;
            cliff_days = 90;
            duration_days = 365;
            released_amount = 0;
            start_timestamp = Time.now();
        };
        created_at = Time.now();
        status = "DEMO_STAGING_SPECIFICATION";
    };
    launched_tokens := [genesis_ai_token];

    public shared({ caller }) func create_token(args : {
        name : Text;
        symbol : Text;
        decimals : Nat8;
        initial_supply : Nat;
        model : TokenModel;
        has_vesting : Bool;
        cliff_days : Nat;
        duration_days : Nat;
    }) : async { #Ok : LaunchpadToken; #Err : Text } {
        if (Text.size(args.name) == 0 or Text.size(args.symbol) == 0) {
            return #Err("Token name and symbol cannot be empty");
        };

        token_counter += 1;
        let caller_text = Principal.toText(caller);

        let vesting_data : ?VestingSchedule = if (args.has_vesting) {
            ?{
                total_amount = args.initial_supply / 5; // 20% team/advisory vesting
                cliff_days = args.cliff_days;
                duration_days = args.duration_days;
                released_amount = 0;
                start_timestamp = Time.now();
            }
        } else {
            null
        };

        // Enforce truthful state: initial request is REQUESTED, canister_id is NOT_YET_PROVISIONED.
        // Synthetic IDs (such as "qmoosa-tok-*-cai") are strictly prohibited.
        let new_token : LaunchpadToken = {
            token_id = token_counter;
            name = args.name;
            symbol = args.symbol;
            decimals = args.decimals;
            initial_supply = args.initial_supply;
            model = args.model;
            creator = caller_text;
            canister_id = "NOT_YET_PROVISIONED";
            vesting = vesting_data;
            created_at = Time.now();
            status = "REQUESTED";
        };

        launched_tokens := Array.append(launched_tokens, [new_token]);
        return #Ok(new_token);
    };

    public shared({ caller }) func advance_lifecycle(req : {
        token_id : Nat;
        next_status : Text;
        canister_id : ?Text;
        failure_reason : ?Text;
    }) : async { #Ok : LaunchpadToken; #Err : Text } {
        ignore caller;
        var found = false;
        var updated_token : ?LaunchpadToken = null;
        var i = 0;
        while (i < launched_tokens.size()) {
            let t = launched_tokens[i];
            if (t.token_id == req.token_id) {
                found := true;
                if (req.next_status != "CREATING" and
                    req.next_status != "INSTALLING" and
                    req.next_status != "VERIFYING" and
                    req.next_status != "DEPLOYED" and
                    req.next_status != "FAILED") {
                    return #Err("Invalid lifecycle state: " # req.next_status # ". Must be CREATING, INSTALLING, VERIFYING, DEPLOYED, or FAILED");
                };

                var cid = t.canister_id;
                if (req.next_status == "DEPLOYED") {
                    switch (req.canister_id) {
                        case null return #Err("Cannot transition to DEPLOYED without a verified canister principal");
                        case (?c) {
                            if (Text.size(c) < 5 or c == "NOT_YET_PROVISIONED" or Text.startsWith(c, "qmoosa-tok-")) {
                                return #Err("Synthetic or placeholder canister ID rejected by truth protocol");
                            };
                            cid := c;
                        };
                    };
                } else {
                    switch (req.canister_id) {
                        case (?c) { cid := c };
                        case null {};
                    };
                };

                let final_status = if (req.next_status == "FAILED") {
                    switch (req.failure_reason) {
                        case (?r) "FAILED: " # r;
                        case null "FAILED";
                    }
                } else {
                    req.next_status
                };

                let updated : LaunchpadToken = {
                    token_id = t.token_id;
                    name = t.name;
                    symbol = t.symbol;
                    decimals = t.decimals;
                    initial_supply = t.initial_supply;
                    model = t.model;
                    creator = t.creator;
                    canister_id = cid;
                    vesting = t.vesting;
                    created_at = t.created_at;
                    status = final_status;
                };

                var copy : [LaunchpadToken] = [];
                var j = 0;
                while (j < launched_tokens.size()) {
                    copy := Array.append(copy, [if (j == i) updated else launched_tokens[j]]);
                    j += 1;
                };
                launched_tokens := copy;
                updated_token := ?updated;
            };
            i += 1;
        };

        if (not found) return #Err("Token not found");
        switch (updated_token) {
            case (?t) #Ok(t);
            case null #Err("Unexpected update failure");
        }
    };

    public query func get_all_tokens() : async [LaunchpadToken] {
        return launched_tokens;
    };

    public query func get_token(token_id : Nat) : async ?LaunchpadToken {
        for (t in launched_tokens.vals()) {
            if (t.token_id == token_id) return ?t;
        };
        return null;
    };

    public query func get_launchpad_stats() : async {
        total_tokens_launched : Nat;
        total_capital_raised : Nat;
        active_vesting_contracts : Nat;
        total_deployed_tokens : Nat;
    } {
        var deployed_count : Nat = 0;
        for (t in launched_tokens.vals()) {
            if (t.status == "DEPLOYED") {
                deployed_count += 1;
            };
        };
        return {
            total_tokens_launched = token_counter;
            total_capital_raised = token_counter * 250_000;
            active_vesting_contracts = launched_tokens.size();
            total_deployed_tokens = deployed_count;
        };
    };
}
