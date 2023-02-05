import MoneyLegos "./money_legos";
import Ledger "canister:nns-ledger";
import Nat64 "mo:base/Nat64";
import CyclesMinting "canister:nns-cycles-minting";
import Principal "mo:base/Principal";
actor class Name ()= this{
  //ipo
  //initial user deposits icp to the canister
  //we call mint_canister
  //this mints a customized wallet ledger where all tokens are sent to this canister
  //this also mints an additional staking management canister that handles both 
  

  //in the wallet canister, we have an address and when it receives 


  

  //a mint canister function
  public shared ({caller}) func mint_canister() : async MoneyLegos.TopUpResult{
   var fee_result = await MoneyLegos.depositIcp(caller,Principal.fromActor(this), Principal.fromActor(this),Nat64.fromNat(200010000));
   var top_up_canister_result = await MoneyLegos.topUpCanister(Principal.fromActor(this),Nat64.fromNat(200000000));
   return top_up_canister_result;
  };

  //a canister for staking the tokens 

  //a timer that essentially when balance is 
};
