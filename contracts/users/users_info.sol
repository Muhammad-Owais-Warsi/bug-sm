// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract users_info {
 

    uint256 constant REVIEW_PERIOD = 72 hours;


    struct Bounties {
        string id; 
        uint256 amount;         
        address creator;     
        address availer;
        address[] applicants;
        uint256 SubmissionTime;
    }

  
    Bounties[] public bounties;

    mapping(string => uint256) public BountyIdToIndex; 

    function create(
        string memory id,    
        uint256 amount
    ) public {

        bounties.push();
        Bounties storage newBounty = bounties[bounties.length - 1];

        newBounty.id = id;
        newBounty.amount = amount;
        newBounty.creator = msg.sender;
        newBounty.availer = address(0);
        newBounty.SubmissionTime = 0;

        BountyIdToIndex[id] = bounties.length;

        
    }


    function Apply(
        string memory id
    ) public {

            
        require(BountyIdToIndex[id] != 0, "Bounty does not exist");

        uint256 index = BountyIdToIndex[id] - 1;

        Bounties storage bounty = bounties[index];

        bounty.applicants.push(msg.sender);

    }


}