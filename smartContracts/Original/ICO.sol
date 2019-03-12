pragma solidity ^0.4.24;

import "./ERC20-Token.sol";

contract ICO is Owned {

    Token public token;
    uint public rate;
    uint256 private _openingTime;
    uint256 private _closingTime;
    uint256 private _preSale_openingTime;
    uint256 private _preSale_closingTime;

    constructor (address _tokenAddress, uint256 preSale_openingTime, uint256 preSale_closingTime, uint256 openingTime, uint256 closingTime) public {
        token = Token(_tokenAddress);

        require(openingTime >= block.timestamp);
        require(closingTime > openingTime);

        _openingTime = openingTime;
        _closingTime = closingTime;
        _preSale_closingTime = preSale_closingTime;
        _preSale_openingTime = preSale_openingTime;
    }


    function buyToken() public payable {

        rate = rateOptimizationICO();



        if(preSale_isOpen() || isOpen()){
            require((msg.value * rate) <= token.balanceOf(address(this)));
            token.transfer(msg.sender, (msg.value * rate));
        }
        else{
            revert();
        }
    }


    function rateOptimizationICO() internal view returns(uint){
        if((block.timestamp >= 1549324800) && (block.timestamp <= 1553212800)){
            return 1000;
        }
        else if((block.timestamp >= 1553299200) && (block.timestamp <= 1553731200)){
            return 800;
        }
        else if((block.timestamp >= 1553817600) && (block.timestamp <= 1554940800)){
            return 750;
        }
        else if((block.timestamp >= 1555718400) && (block.timestamp <= 1555891200)){
            return 700;
        }
        else if((block.timestamp >= 1555977600) && (block.timestamp <= 1556409600)){
            return 650;
        }
        else if((block.timestamp >= 1556496000) && (block.timestamp <= 1556928000)){
            return 600;
        }
        else if((block.timestamp >= 1557014400) && (block.timestamp <= 1559692800)){
            return 500;
        }
    }


    function tokenWithdraw() public onlyOwner {
        token.transfer(owner, token.balanceOf(address(this)));
    }

    function getBalance() public view returns (uint) {
        return token.balanceOf(msg.sender);
    }

    function getICOBalance() public view returns (uint) {
        return token.balanceOf(address(this));
    }

    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        uint256 etherAmount = _weiAmount / 1000000000000000000;
        return etherAmount*rate;
    }

    //timed ICO
    function openingTime() public view returns (uint256) {
        return _openingTime;
    }
    /**
  * @return the crowdsale closing time.
  */
    function closingTime() public view returns (uint256) {
        return _closingTime;
    }

    function preSale_openingTime() public view returns (uint256) {
        return _preSale_openingTime;
    }

    function preSale_closingTime() public view returns (uint256) {
        return _preSale_closingTime;
    }



    /**
     * @return true if the crowdsale is open, false otherwise.
     */
    function isOpen() public view returns (bool) {
        // solhint-disable-next-line not-rely-on-time
        return block.timestamp >= _openingTime && block.timestamp <= _closingTime;
    }

    /**
     * @dev Checks whether the period in which the crowdsale is open has already elapsed.
     * @return Whether crowdsale period has elapsed
     */
    function hasClosed() public view returns (bool) {
        // solhint-disable-next-line not-rely-on-time
        return block.timestamp > _closingTime;
    }

    function preSale_isOpen() public view returns (bool) {
        // solhint-disable-next-line not-rely-on-time
        return block.timestamp >= _preSale_openingTime && block.timestamp <= _preSale_closingTime;
    }

    /**
     * @dev Checks whether the period in which the crowdsale is open has already elapsed.
     * @return Whether crowdsale period has elapsed
     */
    function preSale_hasClosed() public view returns (bool) {
        // solhint-disable-next-line not-rely-on-time
        return block.timestamp > _preSale_closingTime;
    }

	function _forwardFunds() public onlyOwner {
        owner.transfer(address(this).balance);
    }

}

