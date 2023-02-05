actor class Staking(_token:Principal,_wallet:Principal)= this{
    public type PayoutPeriod = Nat;
    public type InitialStakeDate = Nat;
    var token = _token;
    var paying_out_calls = 0; 
    var current_pay_period = 0;
    var payout_in_progress = false;
    var stakers = <Principal,(PayoutPeriod,InitialStakeDate)>;
    var max_send_stakers = 100;
    var seconds_check_payout = 100;

  // in the timer every x seconds you check if paying_out is greater than 0 if so call paying_out function, 
  //else call the wallet and check if there is enough money to pay out 


   var time = 0;
   system func heartbeat():async()
   {
   if (time%seconds_check_payout == 0)
      {
      };
   };



  //checks if payout is in progress
  //if it is
  //loops through stakers and grabs max_send stakers 
  //sets all the grabbed stakers payouts +=1
  //if staker count was 0
  //checks if paying_out_calls > 0
  //if it is, do nothing
  //if it is not, set payout in progress to false
  //moves current_pay_period +=1
  //if staker count was greater than 0
  //sends to the wallet the list of stakers 
  //and updates payout_calls +=1
  //once the return occurs
  //do payout_calles -=1
  //if success
  //calls payout again
  //if failure
  //set all the max_sned_stakers -=1
  //calls payout again
  //if payout is not in progress, checks if there is enough money in wallet to payout
  //if there is set payout in progress to true
  //call payout

  public func payout(){};

  
  

};

