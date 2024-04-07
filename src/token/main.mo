import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";


actor Token {
    let owner: Principal = Principal.fromText("g6iuk-u4yxh-q4wf2-p7tvn-j2hsk-zkhfx-3v5vm-ex24b-kms3a-hb3b5-mqe");
    let totalSupply: Nat = 1000000000;
    let symbol: Text = "JOY";

    // balanceEntries and balances are only modified in the Token, so make them private
    private stable var balanceEntries: [(Principal, Nat)] = []; // This Array is to store the values of the 'balances' HashMap as every deployment would format the values in the HashMap since it's not stable
    private var balances = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash); // The reason why use HashMap instead of Array is using Array can be very costly on the IC and inefficient
    
    // This is when first time deploy, no upgrade yet, assign 1 billion to the owner
    if(balances.size() < 1) {
        balances.put(owner, totalSupply);
    };

    public query func balanceOf(who: Principal): async Nat {
        let balance: Nat = switch(balances.get(who)) {
            case null 0;
            case (?result) result;
        };
        return balance;
    };

    public query func getSymbol(): async Text {
        return symbol;
    };

    public shared(msg) func payOut(): async Text {
        // Debug.print(debug_show(msg.caller));
        if (balances.get(msg.caller) == null) { //msg.caller refers to the caller of the function
            let amount = 100;
            // balances.put(msg.caller, amount);
            // return "Success";
            let result = await transfer(msg.caller, amount);
            return result;
        } else {
            return "Already claimed";
        }
    };

    public shared(msg) func transfer(to: Principal, amount: Nat): async Text {
        let fromBalance: Nat = await balanceOf(msg.caller);
        if (fromBalance > amount) {
            let newFromBalance: Nat = fromBalance - amount;
            balances.put(msg.caller, newFromBalance);

            let toBalance: Nat = await balanceOf(to);
            let newToBalance: Nat = toBalance + amount;
            balances.put(to, newToBalance);

            return "Success";
        } else {
            return "Insufficient fund";
        }
    };

    system func preupgrade() {
        // Transfer values from HashMap to Array
        balanceEntries := Iter.toArray(balances.entries()); // entries() would enable the Array iterable
    };

    system func postupgrade() {
        // Transfer values back from Array to HashMap
        balances := HashMap.fromIter<Principal, Nat>(balanceEntries.vals(), 1, Principal.equal, Principal.hash);
        // Only initially, give 1 billion to the owner
        if(balances.size() < 1) {
            balances.put(owner, totalSupply);
        }
    };

}