import A "./Account";
import Ledger "canister:nns-ledger";
import CyclesMinting "canister:nns-cycles-minting";
import Nat64 "mo:base/Nat64";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Time "mo:base/Time";
import Principal "mo:base/Principal";

module
{
  public type TopUpResult =  {
    #Ok: CyclesMinting.Cycles;
    #Err: TopUpError;
  };
  public type TopUpError= {
  #Refunded : {
    // The reason for the refund.
    reason : Text;
    // The index of the block containing the refund.
    block_index : ?CyclesMinting.BlockIndex;
  };
  #Processing;
  #TransactionTooOld : CyclesMinting.BlockIndex;
  #InvalidTransaction : Text;
  #Other :{ error_code : Nat64; error_message : Text };
  #BadFee : { expected_fee : Ledger.Tokens; };
  #InsufficientFunds : { balance: Ledger.Tokens; };
  #TxTooOld : { allowed_window_nanos: Nat64; };
  #TxCreatedInFuture;
  #TxDuplicate : { duplicate_of: Ledger.BlockIndex; };
};

  public func depositIcp(caller:Principal,this_principal:Principal,to_principal:Principal,amount:Nat64): async Ledger.TransferResult {
    let icp_fee_record = await Ledger.transfer_fee({});
    let icp_fee = icp_fee_record.transfer_fee.e8s;
    // Calculate target subaccount
    // NOTE: Should this be hashed first instead?
    let source_account = A.accountIdentifier(this_principal, A.principalToSubaccount(caller));
    let target_account = A.accountIdentifier(to_principal, A.defaultSubaccount());

    // Check ledger for value
    let balance = await Ledger.account_balance({ account = source_account });
    if(balance.e8s < amount + icp_fee) {
       return #Err(#InsufficientFunds({ balance = balance }));
    };
    let target_balance = await Ledger.account_balance({ account = target_account });
    // Transfer to default subaccount
      var transfer_result = await Ledger.transfer({
        memo: Nat64   = Nat64.fromNat(0);
        from_subaccount = ?A.principalToSubaccount(caller);
        to = A.accountIdentifier(to_principal, A.defaultSubaccount());
        amount = { e8s = balance.e8s - icp_fee};
        fee = { e8s = icp_fee };
        created_at_time = ?{ timestamp_nanos = Nat64.fromNat(Int.abs(Time.now())) };
        });
        return transfer_result;
  };

  public func topUpCanister(_this_principal:Principal,_amount:Nat64,):async TopUpResult{

    //first transfer icp to the cycles minting canister using the ledger
    //use the default subaccount for both the to and from subaccounts
    //on transfer you will get a Result<#Ok,#Err> type. Do a switch case #Ok then call 
    //then call the minting canister to mint cycles
  var transfer_result = await Ledger.transfer({
    memo: Nat64   = Nat64.fromNat(0);
    from_subaccount = null;
    to = A.accountIdentifier(Principal.fromActor(CyclesMinting), A.defaultSubaccount());
    amount = { e8s = _amount};
    fee = { e8s = 0 };
    created_at_time = ?{ timestamp_nanos = Nat64.fromNat(Int.abs(Time.now())) };
    });
    switch(transfer_result) {
      case (#Ok block_index) {
        let notify_top_up_arg = {
          block_index = block_index;
          canister_id = _this_principal;
          };
        let mint_result = await CyclesMinting.notify_top_up(notify_top_up_arg);
        return mint_result;
      };
      case (#Err transfer_error) {
      return #Err(transfer_error);
      };
    };
  };

  public func getSubaccountBalance(caller:Principal,this_principal:Principal): async Ledger.Tokens{
    let source_account = A.accountIdentifier(this_principal, A.principalToSubaccount(caller));
    let balance = await Ledger.account_balance({ account = source_account });
    return balance;
  };
}
