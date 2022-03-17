//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract Payment { 

    // A position represents the relationship between the Owner and spender
    struct Position {
        address owner;
        address spender;
        uint256 totalDeposit;
        uint256 totalClaimed;
        uint256 weeklyAllowance;
        uint256 lastClaim;
    }

    // Array to keep track of all position ever created
    Position[] public positions;

    // Allows anyone to create a position
    function createPosition(
        address _spender,
        uint256 _weeklyAllowance
        ) public payable {
          
        // Creation of position
        Position memory newPosition = Position(
            msg.sender,
            _spender,
            msg.value,
            0,
            _weeklyAllowance,
            block.timestamp
        );

        // Position is pushed to the array
        positions.push(newPosition);
        
    }

    // Sends the claimable amount of a position to its corresponding spender
    function claimPositions() public {

        for(uint i; i < positions.length; i++) {
            uint256 weeksSinceLastClaim = (block.timestamp - positions[i].lastClaim) / 10 seconds;
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
    function editAllowance(uint256 newAllowance, uint256 index) public {
        require(positions[index].owner == msg.sender, "Cannot edit the position");
        positions[index].weeklyAllowance = newAllowance;
    }

    // Allows the owner of a position to top up its balance
    function deposit(uint256 index) public payable {
        positions[index].totalDeposit += msg.value;
    }

    // Allows the owner to withdraw ALL funds
    function withdrawFunds(uint256 index) public {
        require(positions[index].owner == msg.sender, "Cannot edit the position");
        uint256 bal = positions[index].totalDeposit;
        positions[index].totalDeposit = 0;
        payable(msg.sender).transfer(bal);
    }
}
