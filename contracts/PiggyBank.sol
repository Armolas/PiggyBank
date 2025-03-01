// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import './ERC20.sol';

contract PiggyBank{
    uint32 private constant ONE_MONTH_IN_SECS = 30 * 24 * 60 * 60;
    uint8 public constant PENALTY_FEE = 15;
    address public owner;
    address private devAddress;
    uint256 daiBalance;
    uint256 usdcBalance;
    uint256 usdtBalance;
    uint256 withdrawalTime;
    uint8 lockPeriodInMonths;
    string public purpose;
    bool public isWithdrawn;

    enum Token{
        DAI,
        USDC,
        USDT
    }
    mapping(Token => address) tokenAddresses;

    error notOwner();
    error Withdrawn();

    event Deposit(address indexed _owner, uint256 _amount, Token _token);
    event Withdraw(address indexed _owner, uint256 _amount, Token _token);

    constructor(address _owner, uint8 _lockPeriodInMonths, string memory _purpose, address _devAddress){
        devAddress = _devAddress;
        owner = _owner;
        lockPeriodInMonths = _lockPeriodInMonths;
        purpose = _purpose;
        withdrawalTime = block.timestamp + (lockPeriodInMonths * ONE_MONTH_IN_SECS);
        tokenAddresses[Token.DAI] = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        tokenAddresses[Token.USDC] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        tokenAddresses[Token.USDT] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    }

    modifier onlyOwner {
        if(msg.sender != owner) revert notOwner();
        _;
    }

    modifier checkWithdraw(){
        if(isWithdrawn) revert Withdrawn();
        _;
    }

    function deposit(uint256 _amount, Token _token) external onlyOwner checkWithdraw{
        require(tokenAddresses[_token] != address(0), "Invalid token");
        require(_amount > 0, "Deposit amount should be greater than 0");
        ERC20 token = ERC20(tokenAddresses[_token]);
        bool success = token.transferFrom(msg.sender, address(this), _amount);
        require(success, "Deposit failed");
        if(_token == Token.DAI){
            daiBalance += _amount;
        }else if(_token == Token.USDC){
            usdcBalance += _amount;
        }else if(_token == Token.USDT){
            usdtBalance += _amount;
        }
        emit Deposit(owner, _amount, _token);
    }

    function withdraw() external onlyOwner checkWithdraw{
        require(block.timestamp >= withdrawalTime, "Lock period is not over");
        isWithdrawn = true;
        ERC20 dai = ERC20(tokenAddresses[Token.DAI]);
        ERC20 usdc = ERC20(tokenAddresses[Token.USDC]);
        ERC20 usdt = ERC20(tokenAddresses[Token.USDT]);
        if(daiBalance > 0){
            dai.transfer(owner, daiBalance);
            emit Withdraw(owner, daiBalance, Token.DAI);
        }
        if(usdcBalance > 0){
            usdc.transfer(owner, usdcBalance);
            emit Withdraw(owner, usdcBalance, Token.USDC);
        }
        if(usdtBalance > 0){
            usdt.transfer(owner, usdtBalance);
            emit Withdraw(owner, usdtBalance, Token.USDT);
        }

    }

    function emergencyWithraw() external onlyOwner checkWithdraw{
        require(block.timestamp < withdrawalTime, "Lock period is over");
        isWithdrawn = true;
        ERC20 dai = ERC20(tokenAddresses[Token.DAI]);
        ERC20 usdc = ERC20(tokenAddresses[Token.USDC]);
        ERC20 usdt = ERC20(tokenAddresses[Token.USDT]);
        if(daiBalance > 0){
            dai.transfer(owner, daiBalance - calculatePenalty(daiBalance));
            dai.transfer(devAddress, calculatePenalty(daiBalance));
            emit Withdraw(owner, daiBalance - calculatePenalty(daiBalance), Token.DAI);
        }
        if(usdcBalance > 0){
            usdc.transfer(owner, usdcBalance - calculatePenalty(usdcBalance));
            usdc.transfer(devAddress, calculatePenalty(usdcBalance));
            emit Withdraw(owner, usdcBalance - calculatePenalty(usdcBalance), Token.USDC);
        }
        if(usdtBalance > 0){
            usdt.transfer(owner, usdtBalance - calculatePenalty(usdtBalance));
            usdt.transfer(devAddress, calculatePenalty(usdtBalance));
            emit Withdraw(owner, usdtBalance - calculatePenalty(usdtBalance), Token.USDT);
        }
    }

    function checkDaiBalance() external view onlyOwner returns(uint256){
        return daiBalance;
    }

    function checkUsdcBalance() external view onlyOwner returns(uint256){
        return usdcBalance;
    }

    function checkUsdtBalance() external view onlyOwner returns(uint256){
        return usdtBalance;
    }

    function checkWithdrawalTime() external view onlyOwner returns(uint256){
        return withdrawalTime;
    }

    function calculatePenalty(uint256 _amount) internal pure returns(uint256){
        return (_amount * PENALTY_FEE) / 100;
    }
}