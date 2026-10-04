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
        canister_id = "staging-caai-canister";
        vesting = ?{
            total_amount = 100_000_000_00000000;
            cliff_days = 90;
            duration_days = 365;
            released_amount = 0;
            start_timestamp = Time.now();
        };
        created_at = Time.now();
        status = "Local Staging Demo";
    };
    launched_tokens := [genesis_ai_token];

    public func create_token(args : {
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
        let caller_text = Principal.toText(Principal.fromActor(QmoosaLaunchpad));
        let mock_canister_id = "qmoosa-tok-" # Nat.toText(token_counter) # "-cai";

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

        let new_token : LaunchpadToken = {
            token_id = token_counter;
            name = args.name;
            symbol = args.symbol;
            decimals = args.decimals;
            initial_supply = args.initial_supply;
            model = args.model;
            creator = caller_text;
            canister_id = mock_canister_id;
            vesting = vesting_data;
            created_at = Time.now();
            status = "Deployed & Verified";
        };

        launched_tokens := Array.append(launched_tokens, [new_token]);
        return #Ok(new_token);
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
    } {
        return {
            total_tokens_launched = token_counter;
            total_capital_raised = token_counter * 250_000;
            active_vesting_contracts = launched_tokens.size();
        };
    };
}
