
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title Blockpioneers
 * @dev A community-driven pioneering platform on blockchain where users can register as Pioneers,
 *      propose groundbreaking ideas, and receive community support through votes and donations.
 */
contract Blockpioneers {
    struct Pioneer {
        address wallet;
        string name;
        string bio;
        uint256 joinDate;
        uint256 reputation;
    }

    struct Idea {
        uint256 id;
        address proposer;
        string title;
        string description;
        uint256 voteCount;
        uint256 fundsRaised;
        uint256 timestamp;
        bool executed;
    }

    address public immutable founder;
    uint256 public pioneerCount;
    uint256 public ideaCount;

    mapping(address => Pioneer) public pioneers;
    mapping(uint256 => Idea) public ideas;
    mapping(address => bool) public isPioneer;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    event PioneerRegistered(address indexed pioneer, string name, uint256 timestamp);
    event IdeaProposed(uint256 indexed ideaId, address indexed proposer, string title);
    event Voted(address indexed voter, uint256 indexed ideaId, uint256 voteCount);
    event DonationReceived(address indexed donor, uint256 indexed ideaId, uint256 amount);

    constructor() {
        founder = msg.sender;
    }

    /** Core Function 1: Register as a Pioneer */
    function registerPioneer(string memory _name, string memory _bio) external {
        require(!isPioneer[msg.sender], "Already a pioneer");
        require(bytes(_name).length > 0, "Name required");

        pioneers[msg.sender] = Pioneer({
            wallet: msg.sender,
            name: _name,
            bio: _bio,
            joinDate: block.timestamp,
            reputation: 0
        });

        isPioneer[msg.sender] = true;
        pioneerCount++;

        emit PioneerRegistered(msg.sender, _name, block.timestamp);
    }

    /** Core Function 2: Propose a groundbreaking idea */
    function proposeIdea(string memory _title, string memory _description) external {
        require(isPioneer[msg.sender], "Only pioneers can propose ideas");
        require(bytes(_title).length > 0 && bytes(_description).length > 0, "Invalid input");

        ideaCount++;
        ideas[ideaCount] = Idea({
            id: ideaCount,
            proposer: msg.sender,
            title: _title,
            description: _description,
            voteCount: 0,
            fundsRaised: 0,
            timestamp: block.timestamp,
            executed: false
        });

        emit IdeaProposed(ideaCount, msg.sender, _title);
    }

    /** Core Function 3: Vote & Support an idea (also increases reputation) */
    function voteAndSupport(uint256 _ideaId) external payable {
        require(isPioneer[msg.sender], "Only pioneers can vote");
        require(_ideaId > 0 && _ideaId <= ideaCount, "Invalid idea");
        require(!hasVoted[_ideaId][msg.sender], "Already voted");
        require(ideas[_ideaId].executed == false, "Idea already executed");

        hasVoted[_ideaId][msg.sender] = true;
        ideas[_ideaId].voteCount++;

        // Optional ETH donation to the idea
        if (msg.value > 0) {
            ideas[_ideaId].fundsRaised += msg.value;
            emit DonationReceived(msg.sender, _ideaId, msg.value);
        }

        // Increase reputation of voter and proposer
        pioneers[msg.sender].reputation += 1;
        pioneers[ideas[_ideaId].proposer].reputation += 2;

        emit Voted(msg.sender, _ideaId, ideas[_ideaId].voteCount);
    }

    // View function to get idea details
    function getIdea(uint256 _ideaId) external view returns (Idea memory) {
        require(_ideaId > 0 && _ideaId <= ideaCount, "Invalid idea");
        return ideas[_ideaId];
    }
}
