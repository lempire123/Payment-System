//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract Payment { 

    // A position represents the relationship between the Owner and spender
    struct Position {
        address spender;
        uint256 totalDeposit;
        uint256 totalClaimed;
        uint256 weeklyAllowance;
        uint256 lastClaim;
        bool created;
    }

    // Array to keep track of all position ever created
    Position[] public positions;
    
    // Mapping of owner to its corresponding position 
    // Each owner can only have one position (could be changed to have an array of positions)
    mapping(address => Position) public ownerPosition;

    // Allows anyone to create a position
    function createPosition(
        address _spender,
        uint256 _weeklyAllowance
        ) public payable {
          
        // Cannot create more than one position
        require(ownerPosition[msg.sender].created == false, "Can only create one position");
        // Creation of position
        Position memory newPosition = Position(
            _spender,
            msg.value,
            0,
            _weeklyAllowance,
            block.timestamp,
            true
        );

        // Mapping is added
        ownerPosition[msg.sender] = newPosition;

        // Position is pushed to the array
        positions.push(newPosition);
    }
    
    // Sends the claimable amount of a position to its corresponding spender
    function claimPositions() public {

        for(uint i; i < positions.length; i++) {
            uint256 weeksSinceLastClaim = (block.timestamp - positions[i].lastClaim) / 1 weeks;
            uint256 claimable = weeksSinceLastClaim * positions[i].weeklyAllowance;
            // Make sure the position has enough funds
            require(positions[i].totalDeposit >= claimable, "Insufficient funds");
            // Update the state of the position
            positions[i].lastClaim = block.timestamp;
            positions[i].totalClaimed += claimable;
            positions[i].totalDeposit -= claimable;
            // Send the funds to the spender
            payable(positions[i].spender).transfer(claimable);
        }
        
       
    }

    // ======= EDIT POSITION FUNCTIONS ============ // 

    // Allows the owner to change the allowance
    function editAllowance(uint256 newAllowance) public {
        Position storage position = ownerPosition[msg.sender];
        position.weeklyAllowance = newAllowance;
    }

    // Allows the owner of a position to top up its balance
    function deposit() public payable {
        Position storage position = ownerPosition[msg.sender];
        position.totalDeposit += msg.value;
    }

    // Allows the owner to withdraw ALL funds
    function withdrawFunds() public {
        Position storage position = ownerPosition[msg.sender];
        uint256 bal = position.totalDeposit;
        payable(msg.sender).transfer(bal);
    }
}
