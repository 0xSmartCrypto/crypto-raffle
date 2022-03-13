// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "hardhat/console.sol";


/// @title VelvetTicket
contract VelvetTicket is ERC721Enumerable {

    /// @notice counters library
    using Counters for Counters.Counter;

    /// @dev declare ticket token's id
    Counters.Counter private _tokenIds;

    /// @notice structure of each ticket item
    struct Item {
        uint256 id;
        address creator;
        string uri; // metadata url
    }

    /// @dev mapping of this contract
    mapping(uint256 => Item) public items;

    /// @notice this contract constructor
    constructor () ERC721("VelvetTicket", "VT") {}

    /**
    @notice function to mint ticket NFT on Ethereum
    @dev only users not managers.
    @param uri is IPFS uri of the ticket
    */
    function mintNFT(string memory uri) external returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);

        items[newItemId] = Item({
            id: newItemId, 
            creator: msg.sender,
            uri: uri
        });

        return newItemId;
    }

    /**
    @notice function to get minted token's uri.
    @param tokenId is NFT's id.
    */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "tokenURI nonexistent for tokenId");

        return items[tokenId].uri;
    }

}
