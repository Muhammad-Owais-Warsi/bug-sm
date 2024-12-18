// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract users_info {
    
    event BountyCreated();
    event BountyAvailed();



    struct File { 
        string cid;        
        uint256 size;      
    }

    struct Bounties {
        string id;
        string title;           
        string description;        
        string[] links;              
        uint256 amount;         
        address creator;     
        bool isAvailed;   
        address availer;
    }

    struct Availer {
        address availer;
        File[] documents;
        string[] links;    
    }

    Bounties[] public bounties;
    Availer[] public availers;

    mapping(string => uint256) public BountyIdToIndex; 
    mapping(string => uint256) public BountyIdToAvailer;

    function create(
        string memory id,
        string memory title,
        string memory description,
        string[] memory links,     
        uint256 amount
    ) public {

        // storing in the bounties array.
        bounties.push();
        Bounties storage newBounty = bounties[bounties.length - 1];

        newBounty.id = id;
        newBounty.title = title;
        newBounty.description = description;
        newBounty.amount = amount;
        newBounty.creator = msg.sender;
        newBounty.isAvailed = false;
        newBounty.availer = address(0);

        for(uint256 i = 0; i < links.length; i++) {
            newBounty.links.push(links[i]);
        }

        BountyIdToIndex[id] = bounties.length;

        // In frontend make use of zustand and store the details, whenever this is emitted update it.
        emit BountyCreated();
        
    }


    function avail(
        string memory id,
        string[] memory links
    ) public {

        // Never be mapped with 0.         
        require(BountyIdToIndex[id] != 0, "Bounty does not exist");

        uint256 index = BountyIdToIndex[id] - 1;

        Bounties storage bounty = bounties[index];

        require(!bounty.isAvailed , "Bounty is already availed");


        // storing in array of availers.
        availers.push();
        Availer storage newAvailer = availers[availers.length-1];

        newAvailer.availer = msg.sender;

        for(uint256 i = 0; i<links.length; i++) {
            newAvailer.links.push(links[i]);
        }

        // changing state of bounty
        bounty.isAvailed = true;
        bounty.availer = msg.sender;

        BountyIdToAvailer[id] = availers.length;

        emit BountyAvailed();
    }


}