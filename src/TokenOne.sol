// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract TokenOne is ERC20 {
    // Initialize contract with 1 million tokens minted to the creator of the contract
    constructor() ERC20("TokenOne", "TKNO") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}