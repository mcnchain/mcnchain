// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WrappedMCN is ERC20, Ownable {
    address public vault;

    constructor() ERC20("Wrapped MCN", "WMCN") Ownable(msg.sender) {
        vault = msg.sender;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }

    function setVault(address newVault) external onlyOwner {
        vault = newVault;
    }
}
