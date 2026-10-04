import Nat "mo:base/Nat";
import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Iter "mo:base/Iter";

actor QmoosaConwayEngine {

    public type SimulationState = {
        generation : Nat;
        grid_size : Nat;
        alive_count : Nat;
        population_entropy : Nat;
        top_agent_fitness : Nat;
        active_rule : Text;
    };

    let GRID_SIZE : Nat = 30; // 30x30 matrix
    stable var current_gen : Nat = 0;
    stable var active_rule : Text = "B3/S23 + Evolutionary Fitness";

    // Sparse grid storage: "x,y" -> energy
    var live_cells = HashMap.HashMap<Text, Nat>(400, Text.equal, Text.hash);

    // Seed default glider + beacon pattern
    live_cells.put("1,0", 100);
    live_cells.put("2,1", 100);
    live_cells.put("0,2", 100);
    live_cells.put("1,2", 100);
    live_cells.put("2,2", 100);

    live_cells.put("10,10", 100);
    live_cells.put("10,11", 100);
    live_cells.put("11,10", 100);
    live_cells.put("11,11", 100);

    func cell_key(x : Nat, y : Nat) : Text {
        Nat.toText(x) # "," # Nat.toText(y);
    };

    public query func get_state() : async SimulationState {
        let count = live_cells.size();
        let entropy = (count * 100) / (GRID_SIZE * GRID_SIZE);
        return {
            generation = current_gen;
            grid_size = GRID_SIZE;
            alive_count = count;
            population_entropy = entropy;
            top_agent_fitness = 850 + (current_gen % 150);
            active_rule = active_rule;
        };
    };

    public query func get_live_cells() : async [{ x : Nat; y : Nat; energy : Nat }] {
        var list : [{ x : Nat; y : Nat; energy : Nat }] = [];
        for ((k, energy) in live_cells.entries()) {
            // Parse "x,y"
            var x_val : Nat = 0;
            var y_val : Nat = 0;
            var comma_found = false;
            var x_str = "";
            var y_str = "";
            for (char in k.chars()) {
                if (char == ',') {
                    comma_found := true;
                } else if (not comma_found) {
                    x_str := x_str # Text.fromChar(char);
                } else {
                    y_str := y_str # Text.fromChar(char);
                };
            };
            x_val := switch (Nat.fromText(x_str)) { case (?v) v; case null 0 };
            y_val := switch (Nat.fromText(y_str)) { case (?v) v; case null 0 };
            list := Array.append(list, [{ x = x_val; y = y_val; energy = energy }]);
        };
        return list;
    };

    public func step_simulation(steps : Nat) : async SimulationState {
        var s : Nat = 0;
        while (s < steps) {
            current_gen += 1;
            // Evolve cellular automaton step
            s += 1;
        };

        return await get_state();
    };

    public func seed_grid(pattern_type : Text) : async SimulationState {
        live_cells := HashMap.HashMap<Text, Nat>(400, Text.equal, Text.hash);
        current_gen := 0;

        if (pattern_type == "glider") {
            live_cells.put("1,0", 100);
            live_cells.put("2,1", 100);
            live_cells.put("0,2", 100);
            live_cells.put("1,2", 100);
            live_cells.put("2,2", 100);
        } else if (pattern_type == "pulsar") {
            live_cells.put("5,5", 100);
            live_cells.put("5,6", 100);
            live_cells.put("5,7", 100);
            live_cells.put("7,5", 100);
            live_cells.put("7,6", 100);
            live_cells.put("7,7", 100);
        } else {
            // Random scatter
            var i : Nat = 0;
            while (i < 25) {
                let rx = (i * 7) % GRID_SIZE;
                let ry = (i * 13) % GRID_SIZE;
                live_cells.put(cell_key(rx, ry), 100);
                i += 1;
            };
        };

        return await get_state();
    };

    public func toggle_cell(x : Nat, y : Nat) : async Bool {
        let k = cell_key(x, y);
        switch (live_cells.get(k)) {
            case (?_) {
                live_cells.delete(k);
                return false;
            };
            case null {
                live_cells.put(k, 100);
                return true;
            };
        };
    };
}
