pragma solidity 0.5.5;
/**
 * @title OMNIS-BIT ICO CONTRACT
 * @dev ERC-20 Token Standard Compliant
 */

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns(uint c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) internal pure returns(uint c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint a, uint b) internal pure returns(uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint a, uint b) internal pure returns(uint c) {
        require(b > 0);
        c = a / b;
    }
}

// ----------------------------------------------------------------------------
// ERC20 Token Standard Interface
// ----------------------------------------------------------------------------
interface ERC20Interface {
    function totalSupply() external view returns(uint);

    function balanceOf(address tokenOwner) external view returns(uint balance);

    function allowance(address tokenOwner, address spender) external view returns(uint remaining);

    function transfer(address to, uint tokens) external returns(bool success);

    function approve(address spender, uint tokens) external returns(bool success);

    function transferFrom(address from, address to, uint tokens) external returns(bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

interface DateTimeAPI {

    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) external view returns(uint timestamp);

}

contract ICO {

    //DateTimeAPI dateTimeContract = DateTimeAPI(0x1a6184CD4C5Bea62B0116de7962EE7315B7bcBce);//Main
    //DateTimeAPI dateTimeContract = DateTimeAPI(0x71b6e049E78c75fC61480357CD5aA1B81E1b16E0);//Kovan
    //DateTimeAPI dateTimeContract = DateTimeAPI(0x670b2B167e13b131C491D87bA745dA41f07ecbc3);//Rinkeby
    DateTimeAPI dateTimeContract = DateTimeAPI(0x1F0a2ba4B115bd3e4007533C52BBd30C17E8B222); //Ropsten

    using SafeMath
    for uint256;

    enum State {
        //This ico have  states
        preSale,
        ICO,
        finishing,
        extended,
        successful
    }

    //public variables
    State public state = State.preSale; //Set initial stage
    uint256 public startTime = dateTimeContract.toTimestamp(2019, 3, 20, 0, 0);
    uint256 public totalRaised; //eth in wei
    uint256 public totalDistributed; //tokens distributed
    uint256 public totalReferral;
    uint256 public presaleLimit = 200000000 * 10 ** 18; //200.000.000 Tokens
    uint256 public ICOLimit = 360000000 * 10 ** 18; //360.000.000 Tokens
    uint256[7] public rates = [1000, 800, 750, 700, 650, 600, 500];
    uint256 public ICOdeadline = dateTimeContract.toTimestamp(2019, 6, 5, 23, 59);
    uint256 public completedAt;
    ERC20Interface public tokenReward;
    address public creator;
    address payable public beneficiary;
    string public campaignUrl;
    string public version = '0.2';
    mapping(address => uint256) public referralBalance;

    //events for log
    event LogFundingReceived(address _addr, uint _amount, uint _currentTotal);
    event LogBeneficiaryPaid(address _beneficiaryAddress);
    event LogFundingSuccessful(uint _totalRaised);
    event LogFunderInitialized(
        address _creator,
        string _url,
        uint256 _ICOdeadline);
    event LogContributorsPayout(address _addr, uint _amount);

    modifier notFinished() {
        require(state != State.successful);
        _;
    }
    /**
     * @notice ICO constructor
     * @param _addressOfTokenUsedAsReward is the token totalDistributed
     * @param _beneficiary is the address that will receive funds collected
     */
    constructor(ERC20Interface _addressOfTokenUsedAsReward, address payable _beneficiary) public {

        creator = msg.sender;
        tokenReward = _addressOfTokenUsedAsReward;
        beneficiary = _beneficiary;

        emit LogFunderInitialized(
            creator,
            campaignUrl,
            ICOdeadline);

    }

    /**
     * @notice contribution handler
     */
    function contribute(address referralAddress) public notFinished payable {

        require(now >= startTime);

        uint256 tokenBought = 0;

        totalRaised = totalRaised.add(msg.value);

        //Rate of exchange depends on stage
        if (state == State.preSale) {

            if (now <= dateTimeContract.toTimestamp(2019, 3, 22, 23, 59)) {

                tokenBought = msg.value.mul(rates[0]);

            } else if (now <= dateTimeContract.toTimestamp(2019, 3, 28, 23, 59)) {

                tokenBought = msg.value.mul(rates[1]);

            } else {

                tokenBought = msg.value.mul(rates[2]);

            }

        } else if (state == State.ICO) {

            if (now <= dateTimeContract.toTimestamp(2019, 4, 22, 23, 59)) {

                tokenBought = msg.value.mul(rates[3]);

            } else if (now <= dateTimeContract.toTimestamp(2019, 4, 28, 23, 59)) {

                tokenBought = msg.value.mul(rates[4]);

            } else if (now <= dateTimeContract.toTimestamp(2019, 5, 4, 23, 59)) {

                tokenBought = msg.value.mul(rates[5]);

            } else {

                tokenBought = msg.value.mul(rates[6]);

            }

        } else if (state == State.finishing) {

            revert("Purchases disabled while extension Poll");

        } else { //extension approved

            tokenBought = msg.value.mul(rates[6]);

        }

        //+10% Bonus for high contributor
        if (msg.value >= 100 ether) {
            tokenBought = tokenBought.mul(11);
            tokenBought = tokenBought.div(10);
        }

        //3% for referral
        if (referralAddress != address(0) && referralAddress != msg.sender) {
            uint256 bounty = tokenBought.mul(3);
            bounty = bounty.div(100);
            totalReferral = totalReferral.add(bounty);
            referralBalance[referralAddress] = referralBalance[referralAddress].add(bounty);
        }

        if (state == State.preSale) {

            require(totalDistributed.add(tokenBought.add(totalReferral)) <= presaleLimit, "Presale Limit exceded");

        } else {

            require(totalDistributed.add(tokenBought.add(totalReferral)) <= ICOLimit, "ICO Limit exceded");

        }

        //Automatic retrieve only after a trust threshold
        if (totalRaised >= 4000 ether) {

            beneficiary.transfer(address(this).balance);

            emit LogBeneficiaryPaid(beneficiary);
        }

        totalDistributed = totalDistributed.add(tokenBought);

        require(tokenReward.transfer(msg.sender, tokenBought), "Transfer could not be made");

        emit LogFundingReceived(msg.sender, msg.value, totalRaised);
        emit LogContributorsPayout(msg.sender, tokenBought);

        checkIfFundingCompleteOrExpired();
    }

    /**
     * @notice check status
     */
    function checkIfFundingCompleteOrExpired() public {

        if (state == State.preSale && now > dateTimeContract.toTimestamp(2019, 4, 11, 23, 59)) {

            state = State.ICO;

        } else if (state == State.ICO && now > ICOdeadline) {

            state = State.finishing;

        } else if (state == State.extended && now > ICOdeadline) {

            state = State.successful; //ico becomes Successful
            completedAt = now; //ICO is complete

            emit LogFundingSuccessful(totalRaised); //we log the finish
            finished(); //and execute closure

        }

    }

    /**
     * @notice closure handler
     */
    function finished() public { //When finished eth and remaining tokens are transfered to beneficiary

        require(state == State.successful, "Wrong Stage");

        beneficiary.transfer(address(this).balance);

        emit LogBeneficiaryPaid(beneficiary);

    }

    function claimReferral() public {

        require(state == State.successful, "Wrong Stage");

        uint256 bounty = referralBalance[msg.sender];
        referralBalance[msg.sender] = 0;

        require(tokenReward.transfer(msg.sender, bounty), "Transfer could not be made");

        emit LogContributorsPayout(msg.sender, bounty);
    }

    function retrieveTokens() public {

        require(msg.sender == creator);
        require(state == State.successful, "Wrong Stage");

        require(now >= completedAt.add(30 days));

        uint256 remanent = tokenReward.balanceOf(address(this));

        require(tokenReward.transfer(beneficiary, remanent), "Transfer could not be made");
    }

    function extension(bool pollResult) public {

        require(msg.sender == creator);
        require(state == State.finishing, "Wrong Stage");

        if (pollResult == true) {
            state = State.extended;
            ICOdeadline = now.add(30 days);
        } else {

            state = State.successful; //ico becomes Successful
            completedAt = now; //ICO is complete

            emit LogFundingSuccessful(totalRaised); //we log the finish
            finished(); //and execute closure

        }
    }

    /*
     * @dev direct payments handle
     */
    function () external payable {

        contribute(address(0));

    }
}