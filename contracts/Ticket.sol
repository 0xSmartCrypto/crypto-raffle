// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";
import { Base64 } from "./libraries/Base64.sol";

/// @title RaffleTicket
contract RaffleTicket is ERC721Enumerable {

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

    /// @notice construct svg for ticket nft
    string public svgPartOne = '<svg xmlns="http://www.w3.org/2000/svg" width="270" height="120" fill="none"><path fill="url(#B)" d="M0 0h270v270H0z"/><defs><filter id="A" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="270" width="120"><feDropShadow dx="0" dy="1" stdDeviation="2" flood-opacity=".625" width="200%" height="200%"/></filter></defs><defs><linearGradient id="B" x1="0" y1="0" x2="270" y2="120" gradientUnits="userSpaceOnUse"><stop stop-color="#ff8844"/><stop offset="1" stop-color="#0cd7e4" stop-opacity=".99"/></linearGradient></defs><text x="32" y="90" font-size="19" fill="#777" filter="url(#A)" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
    string public svgPartTwo = '</text></svg>';

    /// @notice this contract constructor
    constructor () ERC721("RaffleTicket", "RT") {}

    /**
    @notice function to mint ticket NFT on Ethereum
    @dev only users not managers.
    @param _campaignName is the short name of the campaign
    */
    function mintNFT(string memory _campaignName) external returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        
        string memory _ticketNumber = string(abi.encodePacked("Ticket #", Strings.toString(newItemId)));
        string memory finalSvg = string(
            abi.encodePacked(
                svgPartOne,
                _ticketNumber,
                svgPartTwo
            )
        );
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        _campaignName,
                        '", "description": "A raffle ticket", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(finalSvg)),
                        '","ticketNumber":"',
                        _ticketNumber,
                        '"}'
                    )
                )
            )
        );
        string memory finalTokenUri = string(abi.encodePacked("data:application/json;base64,", json));
        console.log("\n--------------------------------------------------------");
        console.log("Final tokenURI", finalTokenUri);
        console.log("--------------------------------------------------------\n");
        
        _safeMint(msg.sender, newItemId);
        // _setTokenURI(newItemId, finalTokenUri);

        items[newItemId] = Item({
            id: newItemId, 
            creator: msg.sender,
            uri: finalTokenUri
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
