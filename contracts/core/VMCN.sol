// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract VMCN is ERC20, Ownable {
    constructor() ERC20("VMCN", "VMCN") Ownable(msg.sender) {
        _mint(msg.sender, 40_000_000 * 10 ** decimals());
    }

    // при желании можно оставить минт на будущее:
    // function mint(address to, uint256 amount) external onlyOwner {
    //     _mint(to, amount);
    // }
}