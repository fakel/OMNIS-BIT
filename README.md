# OMNIS-BIT
OMNIS-BIT additional features development

## About js web purchase function

To use the script you will require to import it on your site, also it's required to import the [ethjs](https://github.com/ethjs) library

```
<script type="text/javascript" src="https://cdn.jsdelivr.net/npm/ethjs@0.3.4/dist/ethjs.min.js"></script>
```

To make a purchase from your site to the ICO contract you must configure the script:

* **window.omnis:** address of your contract on the corresponding network

## Site script use

When you make a call to the ```purchase()``` function on the script, it will require from your interface two values:

* **amount:** amount in ethers, taken from html id tag ```contAmount```
* **referral:** Address of referral wallet, with 0x prefix, taken from html id tag ```refAdd```

Once you call this function, a prompt will show from Metamask, there you can review the transaction.

## ICO Code Explanation

Since the only changed code was the ICO one, this explanation will cover only it.

The ico contract uses 2 interfaces:

* ERC20 Token Standard Interface
* DateTime API interface

Also the contract implement a SafeMath Library.

When the contract will get deployed, you have input as parameters two addresses:

* @param _addressOfTokenUsedAsReward is the token to distribute
* @param _beneficiary is the address that will receive funds collected

Once deployed, the contract will follow the following rules for exchange ether for tokens:

* startTime = 2019/3/20 00:00 GMT
* ICOdeadline = 2019/6/5 23:59 GMT
* PreICO period
    * From 20/03 to 22/03 -> 1ETH = 1000 OMNIS
    * From 23/03 to 28/03 -> 1ETH = 800 OMNIS
    * From 29/03 to 11/04 -> 1ETH = 750 OMNIS
* No sales between 12/04 to 19/04
* ICO period
    * From 20/04 to 22/04 -> 1ETH = 700 OMNIS
    * From 23/04 to 28/04 -> 1ETH = 650 OMNIS
    * From 29/04 to 04/05 -> 1ETH = 600 OMNIS
    * From 05/05 to 05/06 -> 1ETH = 500
* A maximum presale amount of 200 million tokens is set
* A maximum total amount of 360 million tokens is set 
* Once ICO get finished, a poll period will begin
* If poll for extension get denied, ICO finishes
* If poll for extension get approved, 30 days more will be able to buy at 1ETH = 500
* The poll result should be set on the contract through extension() function
* For contributions above 100ETH a 10% bonus is applied
* Referral bounty is set to 3%
* Referrals can only claim their bounty after ico finish and with a minimum claim period of 30 days
* The bounty funds can be claimed through the claimReferral() function
* If funds collected surpasses 4000ETH, funds will be automatically transferred to the beneficiary
* At the ICO finish, all funds collected on the contract will be transferred to the beneficiary
* After 30 days passed the ICO finish, the creator of the contract will be able to retrieve to the beneficiary account the remaining and not claimed tokens to proceed with the burn process
* Remaining token can be retrieved for burning process using the retrieveTokens() function
* The following variables are available to the public:
    * state related
        * state
            * preSale
            * ICO
            * finishing
            * extended
            * successful
    * time related
        * startTime
        * ICOdeadline
        * completedAt
    * token related
        * tokenReward
        * presaleLimit
        * ICOLimit
    * funding related
        * totalRaised
        * totalDistributed
        * totalReferral
        * referralBalance
        * rates
            * 1000
            * 800 
            * 750
            * 700
            * 650
            * 600
            * 500
    * info
        * creator
        * beneficiary
        * version
* The following events are available on contract for public log
    * ```event LogFundingReceived(address _addr, uint _amount, uint _currentTotal);```
    * ```event LogBeneficiaryPaid(address _beneficiaryAddress);```
    * ```event LogFundingSuccessful(uint _totalRaised);```
    * ```event LogFunderInitialized(address _creator,uint256 _ICOdeadline);```
    * ```event LogContributorsPayout(address _addr, uint _amount);```
    * ```event LogStateCheck(State current);```