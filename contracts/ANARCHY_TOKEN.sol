// SPDX-License-Identifier: MIT
// author - KOOLNERD

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract ANARCHY_TOKEN is ERC20, ERC20Permit {
    constructor() ERC20("ANARCHY_TOKEN", "ANTK") ERC20Permit("ANARCHY_TOKEN") {
        _mint(msg.sender, 39000000 * 10 ** decimals()); // community incentive
        _mint(msg.sender, 15000000 * 10 ** decimals()); // Team
        _mint(msg.sender, 5000000 * 10 ** decimals()); // Advisor
        _mint(msg.sender, 1000000 * 10 ** decimals()); // Public round
        _mint(msg.sender, 10000000 * 10 ** decimals()); // private round 
        _mint(msg.sender, 5000000 * 10 ** decimals()); // seed round
        _mint(msg.sender, 6250000 * 10 ** decimals()); // Pre-seed round
        _mint(msg.sender, 18750000 * 10 ** decimals()); // Marketing & ecosystem & staking 
    }
}