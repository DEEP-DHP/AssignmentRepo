1-// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    struct Campaign {
        address payable creator;
        uint256 targetAmount;
        uint256 deadline;
        uint256 totalContributions;
        bool finalized;
        mapping(address => uint256) contributions;
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public campaignCount;

    // Events
    event CampaignCreated(uint256 campaignId, address creator, uint256 targetAmount, uint256 deadline);
    event ContributionMade(uint256 campaignId, address contributor, uint256 amount);
    event CampaignFinalized(uint256 campaignId, bool successful);
    event Withdrawal(uint256 campaignId, address contributor, uint256 amount);

    // Create a new crowdfunding campaign
    function createCampaign(uint256 _targetAmount, uint256 _durationInDays) external {
        require(_targetAmount > 0, "Target amount must be greater than 0");
        require(_durationInDays > 0, "Duration must be greater than 0");

        campaignCount++;
        Campaign storage newCampaign = campaigns[campaignCount];
        newCampaign.creator = payable(msg.sender);
        newCampaign.targetAmount = _targetAmount;
        newCampaign.deadline = block.timestamp + (_durationInDays * 1 days);
        newCampaign.totalContributions = 0;
        newCampaign.finalized = false;

        emit CampaignCreated(campaignCount, msg.sender, _targetAmount, newCampaign.deadline);
    }

    // Contribute to a specific campaign
    function contribute(uint256 _campaignId) external payable {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp < campaign.deadline, "Campaign has ended");
        require(msg.value > 0, "Contribution must be greater than 0");
        require(!campaign.finalized, "Campaign has been finalized");

        campaign.contributions[msg.sender] += msg.value;
        campaign.totalContributions += msg.value;

        emit ContributionMade(_campaignId, msg.sender, msg.value);
    }

    // Finalize the campaign
    function finalizeCampaign(uint256 _campaignId) external {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp >= campaign.deadline, "Campaign is still ongoing");
        require(!campaign.finalized, "Campaign already finalized");

        campaign.finalized = true;

        if (campaign.totalContributions >= campaign.targetAmount) {
            // Transfer the funds to the campaign creator
            campaign.creator.transfer(campaign.totalContributions);
            emit CampaignFinalized(_campaignId, true);
        } else {
            emit CampaignFinalized(_campaignId, false);
        }
    }

    // Withdraw contribution if the campaign was not successful
    function withdraw(uint256 _campaignId) external {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp >= campaign.deadline, "Campaign is still ongoing");
        require(campaign.totalContributions < campaign.targetAmount, "Campaign reached its goal");
        require(campaign.contributions[msg.sender] > 0, "No contributions to withdraw");

        uint256 contributedAmount = campaign.contributions[msg.sender];
        campaign.contributions[msg.sender] = 0;
        payable(msg.sender).transfer(contributedAmount);

        emit Withdrawal(_campaignId, msg.sender, contributedAmount);
    }

    // View the details of a campaign
    function getCampaignDetails(uint256 _campaignId) external view returns (
        address creator, uint256 targetAmount, uint256 deadline, uint256 totalContributions, bool finalized
    ) {
        Campaign storage campaign = campaigns[_campaignId];
        return (
            campaign.creator,
            campaign.targetAmount,
            campaign.deadline,
            campaign.totalContributions,
            campaign.finalized
        );
    }
}
2-// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {
    
    struct Proposal {
        string name;
        uint256 voteCount;
    }

    struct Voter {
        bool hasVoted;
        uint256 votedProposalIndex;
    }

    // Mapping from proposal ID to proposal details
    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCount;

    // Mapping from voter address to the proposal they voted for
    mapping(address => Voter) public voters;

    // Events
    event ProposalCreated(uint256 proposalId, string name);
    event VoteCast(address voter, uint256 proposalId);
    event WinningProposal(uint256 proposalId, string name, uint256 voteCount);

    // Create a new proposal
    function createProposal(string calldata _name) external {
        require(bytes(_name).length > 0, "Proposal name cannot be empty");

        proposalCount++;
        proposals[proposalCount] = Proposal(_name, 0);

        emit ProposalCreated(proposalCount, _name);
    }

    // Cast a vote for a specific proposal
    function vote(uint256 _proposalId) external {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Invalid proposal ID");
        require(!voters[msg.sender].hasVoted, "You have already voted");

        // Record that the voter has voted
        voters[msg.sender] = Voter(true, _proposalId);

        // Increase the vote count of the selected proposal
        proposals[_proposalId].voteCount += 1;

        emit VoteCast(msg.sender, _proposalId);
    }

    // View the current results for a specific proposal
    function getProposal(uint256 _proposalId) external view returns (string memory name, uint256 voteCount) {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Invalid proposal ID");

        Proposal storage proposal = proposals[_proposalId];
        return (proposal.name, proposal.voteCount);
    }

    // Determine the winning proposal based on the highest vote count
    function getWinningProposal() external view returns (uint256 winningProposalId, string memory winningProposalName, uint256 winningVoteCount) {
        require(proposalCount > 0, "No proposals available");

        uint256 maxVotes = 0;
        uint256 winningId = 0;

        // Loop through all proposals to find the one with the highest votes
        for (uint256 i = 1; i <= proposalCount; i++) {
            if (proposals[i].voteCount > maxVotes) {
                maxVotes = proposals[i].voteCount;
                winningId = i;
            }
        }

        Proposal storage winningProposal = proposals[winningId];
        return (winningId, winningProposal.name, winningProposal.voteCount);
    }

    // Declare the winner (this can be used after voting has finished)
    function declareWinner() external {
        (uint256 winningProposalId, string memory name, uint256 voteCount) = getWinningProposal();
        emit WinningProposal(winningProposalId, name, voteCount);
    }
}