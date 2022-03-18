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
    uint public deadlineInSecs;
    
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

    /// @notice the block number when the campaign is closed
    uint public deadline;

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
    /// @param _deadlineInSecs is the number of seconds until deadline (at least 60s, no more than 1 year)
    /// @param _ticketPriceInWei is the price per ticket (in wei)
    /// @param _totalTickets is the total number of tickets (between 2-25000)
    /// @param _totalWinners is the total number of winners
    /// @param _ticketNFT is the deployed RaffleTicket NFT contract address.
    constructor(
        string memory _raffleName,
        uint _deadlineInSecs,
        uint _ticketPriceInWei, 
        uint _totalTickets, 
        uint _totalWinners, 
        address _ticketNFT) {
        require(bytes(_raffleName).length <= 20, "Name must be <= 20 chars");
        require(_deadlineInSecs >= 0 && _deadlineInSecs <= 60 * 60 * 24 * 365, "Invalid deadline.");
        require(_totalTickets > 1 && _totalTickets <= 25000, "Total tickets range 2-25000.");
        require(_totalTickets > _totalWinners, "Tickets should exceed winners.");

        manager = payable(msg.sender);

        raffleName = _raffleName;
        ticketPrice = _ticketPriceInWei;
        totalTickets = _totalTickets;
        totalWinners = _totalWinners;

        deadlineInSecs = _deadlineInSecs;
        deadline = block.timestamp + deadlineInSecs;

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
        require(beforeDeadline(), "Past Campaign deadline.");
        require(msg.value >= ticketPrice, "Not enough funds.");

        uint _tokenId = ticketNFT.mintNFT(raffleName, msg.sender);
        // console.log(msg.sender, "bought _tokenId: ", _tokenId);
        
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

    function beforeDeadline() public view returns (bool) {
        return block.timestamp <= deadline;
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
        require(validateWinners(winners), "Winners are not valid.");
        campaignWinners = winners;
        campaignState = CampaignState.WinnerSelected;
        emit CampaignStateChange(campaignState);
        emit WinnersSet(winners);
    }

    /// @notice validate winners array to be uint, each member in range of tickets bought
    /// (positive integers less than totalTickets)
    function validateWinners(winners) public view returns (bool) {
        for (uint i = 0; i < winners; i++) {
            // make sure each "winner" is a valid ticket
            if (winners[i] > totalTickets || winners[i] < 1) {
                return false;
            }
        }
        return true;
    }
    
    /// @notice validate msg.sender is changing their own, OR some other way to validate
    function changeTicketOwner(uint _tokenId, address _newOwner) public {    
        require(msg.sender == ticketOwners[_tokenId], "Only owner can change ownership.");
        ticketOwners[_tokenId] = _newOwner;
    }

    /// @notice function to get one owner's total tickets count.
    /// @param _owner is one owner's address.
    function getOwnerTicketsCount(address _owner) public view returns (uint) {
        return ownerTicketCount[_owner];
    }

    /// @notice function to get one owner's total tickets price.
    /// @param _owner is one owner's address.
    function getOwnerTicketsPrice(address _owner) public view returns (uint) {
        return ticketPrice * ownerTicketCount[_owner];
    }

    /// @notice function to get total earnings from ticket sales.
    function getTotalEarnings() public view returns (uint) {
        return ticketPrice * totalTickets;
    }

    // @notice - get winning numbers for this campaign
    function getWinners() public view returns (uint[] memory) {
        return campaignWinners;
    }

    // @notice - get total tickets bought
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
