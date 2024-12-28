// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract users_info {
 

    uint256 constant REVIEW_PERIOD = 72 hours;


    struct Bounties {
        string id; 
        uint256 amount;         
        address payable creator;     
        address payable availer;
        bool isAvailed;
        address[] applicants;
        bool isSubmitted;
        uint256 deadline;
        uint256 SubmissionTime;
        bool isActive;
    }

    Bounties[] public bounties;

    mapping(string => uint256) public BountyIdToIndex; 

    modifier onlyCreator(string memory id) {
        require(BountyIdToIndex[id] !=0, "Bounty does not exist");
        require(bounties[BountyIdToIndex[id]-1].creator == msg.sender, "Not the creator");
        _;
    }

    modifier onlyAvailer(string memory id) {
        require(BountyIdToIndex[id] != 0, "Bounty does not exist");
        require(bounties[BountyIdToIndex[id]-1].availer == msg.sender, "Not the availer");
        _;
    }



    function create(string memory id,uint256 deadline) public payable {
        require(msg.value > 0, "Must send ether to complete the transaction");

        bounties.push();
        Bounties storage newBounty = bounties[bounties.length - 1];

        newBounty.id = id;
        newBounty.amount = msg.value;
        newBounty.creator = payable(msg.sender);
        newBounty.availer = payable(address(0));
        newBounty.isAvailed = false;
        newBounty.deadline = block.timestamp + (deadline * 1 hours);
        newBounty.SubmissionTime = 0;
        newBounty.isActive = true;

        BountyIdToIndex[id] = bounties.length;
       
    }

    function Apply(string memory id) public {
        require(BountyIdToIndex[id] != 0, "Bounty does not exist");

        uint256 index = BountyIdToIndex[id] - 1;
        Bounties storage bounty = bounties[index];

        require(bounty.creator != msg.sender, "Creator cannot apply");

        bounty.applicants.push(msg.sender);

    }

    function assign(string memory id,address payable applicant) public onlyCreator(id) {
        uint256 index = BountyIdToIndex[id] - 1;
        Bounties storage bounty = bounties[index];

        require(bounty.isAvailed == false, "Bounty is already availed");
        require(bounty.isSubmitted == false, "Bounty is already Submitted");

        bounty.availer = applicant;
        bounty.isAvailed = true;
    }

    function submit(string memory id) public onlyAvailer(id) {
        uint256 index = BountyIdToIndex[id] - 1;
        Bounties storage bounty = bounties[index];

        require(bounty.isSubmitted == false, "Bounty is already Submitted");

        bounty.SubmissionTime = block.timestamp;
        bounty.isSubmitted = true;
    }

    function release(string memory id) public onlyCreator(id) {
        uint256 index = BountyIdToIndex[id] - 1;
        Bounties storage bounty = bounties[index];

        require(bounty.isSubmitted == true, "Not submitted");

        if(msg.sender == bounty.creator || block.timestamp >= REVIEW_PERIOD + bounty.SubmissionTime) {
            bounty.availer.transfer(bounty.amount);
            bounty.amount = 0;
            bounty.isActive = false;

        }
    }

    function claim(string memory id) public onlyAvailer(id) {
        uint256 index = BountyIdToIndex[id] - 1;
        Bounties storage bounty = bounties[index];

        require(bounty.isSubmitted == true, "Not submitted");

        if(msg.sender == bounty.availer && block.timestamp >= REVIEW_PERIOD + bounty.SubmissionTime) {
            bounty.availer.transfer(bounty.amount);
            bounty.amount = 0;
            bounty.isActive = false;
        }
    }

    function refund(string memory id) public onlyCreator(id) {
        uint256 index = BountyIdToIndex[id] - 1;
        Bounties storage bounty = bounties[index];

        require(!bounty.isSubmitted, "Cannot refund a submitted bounty");
        require(bounty.isActive == true, "Not active");

        if(block.timestamp > bounty.deadline && !bounty.isSubmitted) {
            bounty.creator.transfer(bounty.amount);
            bounty.amount = 0;
            bounty.isActive = false;
        } 

    }



}