// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Bridge is Ownable {
    event LockedERC20(address indexed token, address indexed sender, uint256 amount, string targetChain, address recipient);
    event LockedERC721(address indexed token, address indexed sender, uint256 tokenId, string targetChain, address recipient);
    event LockedERC1155(address indexed token, address indexed sender, uint256 id, uint256 amount, string targetChain, address recipient);

    mapping(bytes32 => bool) public processedTx;

    constructor() Ownable(msg.sender) {}

    function lockERC20(address token, uint256 amount, string memory targetChain, address recipient) external {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        emit LockedERC20(token, msg.sender, amount, targetChain, recipient);
    }

    function lockERC721(address token, uint256 tokenId, string memory targetChain, address recipient) external {
        IERC721(token).transferFrom(msg.sender, address(this), tokenId);
        emit LockedERC721(token, msg.sender, tokenId, targetChain, recipient);
    }

    function lockERC1155(address token, uint256 id, uint256 amount, string memory targetChain, address recipient) external {
        IERC1155(token).safeTransferFrom(msg.sender, address(this), id, amount, "");
        emit LockedERC1155(token, msg.sender, id, amount, targetChain, recipient);
    }

    function releaseERC20(address token, address to, uint256 amount, bytes32 txHash) external onlyOwner {
        require(!processedTx[txHash], "Already processed");
        processedTx[txHash] = true;
        IERC20(token).transfer(to, amount);
    }

    function releaseERC721(address token, address to, uint256 tokenId, bytes32 txHash) external onlyOwner {
        require(!processedTx[txHash], "Already processed");
        processedTx[txHash] = true;
        IERC721(token).transferFrom(address(this), to, tokenId);
    }

    function releaseERC1155(address token, address to, uint256 id, uint256 amount, bytes32 txHash) external onlyOwner {
        require(!processedTx[txHash], "Already processed");
        processedTx[txHash] = true;
        IERC1155(token).safeTransferFrom(address(this), to, id, amount, "");
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
