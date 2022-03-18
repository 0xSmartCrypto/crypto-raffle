// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "hardhat/console.sol";

/// @title TicketNFT contract interface
interface ITicketNFT {
    function mintNFT(string memory tokenURI, address _to) external returns (uint);
}

/// @title CampaignState 
// 0 = Active - 0 or more tickets sold
// 1 = Closed - Sold out or campaign ended
// 2 = WinnerSelected - Winner(s) selected
enum CampaignState {
    Active,
    Closed, 
    WinnerSelected
}


/**
    @todo 
    - check for max number of tickets sold
    - 
 */ 

/// @title RaffleCampaign
contract RaffleCampaign is Ownable, IERC721Receiver {

    /// @dev safemath library
    using SafeMath for uint;
    
    /// @dev declare ticketNFT of ITicketNFT interface
    ITicketNFT public ticketNFT;
    
    /// @notice Campaign state: active, closed, winner selected
    CampaignState public campaignState;

    /// @notice raffle's name
    string public raffleName;

    /// @notice raffle's description
    string public raffleDescription;

    /// @notice raffle's end date in blocks relative to when the contract is deployed
    uint public deadlineInBlocks;
    
    /// assumes 6330 blocks per day (Ethereum)
    uint constant public BLOCKS_PER_DAY = 6330;

    /// @notice price per ticket
    uint public ticketPrice;

    /// @notice total number of tickets per raffle
    uint public totalTickets;

    /// @notice total number of winners per raffle
    uint public totalWinners;

    /// @notice counts number of bought tickets 
    uint public ticketCount;

    /// @notice campaign manager's address
    address payable public manager;

    /// @dev mappings of this contract
    mapping (uint => address) public ticketOwners;
    mapping (address => uint) public ownerTicketCount;

    uint[] public campaignWinners;

    /// @dev Events of this contract
    event CampaignStateChange(CampaignState state);
    event TicketBought(uint tokenId);
    event WinnersSet(uint[] winners);
    event NewTicketOwner(address ticketOwner);

    /// @notice contract constructor
    /// @param _raffleName is the short name of the raffle, char limit 20
    /// @param _deadlineInBlocks is the number of blocks until deadline (at least 1 block, no more than 1 year)
    /// @param _ticketPriceInWei is the price per ticket (in wei)
    /// @param _totalTickets is the total number of tickets (between 2-25000)
    /// @param _totalWinners is the total number of winners
    /// @param _ticketNFT is the deployed TicketNFT contract address.
    constructor(
        string memory _raffleName,
        uint _deadlineInBlocks,
        uint _ticketPriceInWei, 
        uint _totalTickets, 
        uint _totalWinners, 
        address _ticketNFT) {
        require(bytes(_raffleName).length <= 20, "Name must be <= 20 chars");
        require(_deadlineInBlocks > 1 && _deadlineInBlocks <= 365 * BLOCKS_PER_DAY, "Invalid deadline.");
        require(_totalTickets > 1 && _totalTickets <= 25000, "Total tickets range 2-25000.");
        require(_totalTickets > _totalWinners, "Tickets should exceed winners.");

        manager = payable(msg.sender);

        raffleName = _raffleName;
        ticketPrice = _ticketPriceInWei;
        totalTickets = _totalTickets;
        totalWinners = _totalWinners;

        deadlineInBlocks = _deadlineInBlocks;

        ticketNFT = ITicketNFT(_ticketNFT);

        ticketCount = 0;
        campaignState = CampaignState.Active;
        emit CampaignStateChange(campaignState);
    }

    /// @notice forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
    function onERC721Received(address, address, uint, bytes memory) override external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }


    /**
    @notice function to buy a ticket.
    @dev only users not managers.
    */
    function buyTicket() public payable {
        require(campaignState == CampaignState.Active, "Campaign is not active.");
        require(msg.value >= ticketPrice, "Not enough funds.");

        // console.log(msg.sender, " wants to buyTicket");
        uint _tokenId = ticketNFT.mintNFT(raffleName, msg.sender);
        // console.log("_tokenId bought: ", _tokenId);
        
        // update ownership counters
        ticketCount++;
        ticketOwners[_tokenId] = msg.sender;
        ownerTicketCount[msg.sender] = ownerTicketCount[msg.sender].add(1);
        
        // console.log("new ticket owner", ticketOwners[_tokenId]);
        emit NewTicketOwner(ticketOwners[_tokenId]);

        // update campaign state if all tickets are sold
        // console.log("tickets bought", ticketCount, "total tickets", totalTickets);
        if (ticketCount == totalTickets) {
            // console.log("All tickets sold. Closing campaign.");
            campaignState = CampaignState.Closed;
            emit CampaignStateChange(campaignState);
        }
    }

    function getCampaignState() public view returns (CampaignState) {
        return campaignState;
    }

    /// @notice allow manager to set winner on chain
    /// App should call this function after calling chainlink VRF to get number of winning tickets.
    /// Takes in a list of winning ticket numbers
    function setWinners(uint[] memory winners) public onlyOwner {
        require(campaignState == CampaignState.Closed, "Campaign needs to be closed.");
        require(winners.length == totalWinners, "Number of winners mismatch.");
        // TODO: require winners to be actual tickets bought
        campaignWinners = winners;
        campaignState = CampaignState.WinnerSelected;
        emit CampaignStateChange(campaignState);
        emit WinnersSet(winners);
    }

    // /// @notice function to get current drawn ticket's owner address.
    // function getCurrentWinnerAddress() public view returns (address) {
    //     require(drawnTickets.length > 0, "No winner drawn.");
    //     uint drawnTicketNum = drawnTickets[drawnTickets.length - 1];
    //     return ticketOwner[drawnTicketNum];
    // }

    // /// @notice function to get total sold tickets count.
    // function getBoughtTicketsCount() public view returns (uint) {
    //     return tickets.length + drawnTickets.length;
    // }

    // /// @notice function to get undrawned tickets count in sold tickets.
    // function getUndrawnTicketsCount() public view returns (uint) {
    //     return tickets.length;
    // }

    // /// @notice function to get total drawn tickets count.
    // function getDrawnTicketsCount() public view returns (uint) {
    //     return drawnTickets.length;
    // }

    // /// @notice function to get one owner's total tickets count.
    // /// @param _owner is one owner's address.
    // function getOwnerTicketsCount(address _owner) public view returns (uint) {
    //     return ownerTicketCount[_owner];
    // }

    // /// @notice function to get one owner's total tickets price.
    // /// @param _owner is one owner's address.
    // function getOwnerTicketsPrice(address _owner) public view returns (uint) {
    //     return ticketPrice * ownerTicketCount[_owner];
    // }

    // /// @notice function to get remained tickets count.
    // function getRemainTickets() public view returns (uint) {
    //     return totalTickets - (tickets.length + drawnTickets.length);
    // }

    // /// @notice function to get total sold tickets price.
    // function getBoughtTicketsPrice() public view returns (uint) {
    //     return ticketPrice * (tickets.length + drawnTickets.length);
    // }

    // /// @notice function to get total tickets price.
    // function getTotalTicketsPrice() public view returns (uint) {
    //     return ticketPrice * totalTickets;
    // }

    // function getTickets() public view returns (uint[] memory) {
    //     return tickets;
    // }

    // @notice - get total tickets bough    
    function getTicketsBought() public view returns (uint) {
        return ticketCount;
    }

    // @notice - function to get total tickets allowed in campaign.
    function getTotalTickets() public view returns (uint) {
        return totalTickets;
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }

    /// @notice function to withdraw balance from contract
    function withdraw(address _to) public onlyOwner {
        uint amount = address(this).balance;
        require(amount > 0, "No funds to withdraw.");

        require(_to != address(0), "Invalid address.");
        console.log("withdraw goes to: ", _to);
        
        (bool success, ) = _to.call{value: amount}("");
        require(success, "Failed to withdraw");
    }
}
