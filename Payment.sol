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


    // Allows the spender to claim his allowance for ALL positions he is elligible for
    function claim() public {
        address spender = msg.sender;
        Position[] memory userPositions = getSpenderPositions(spender);
        
        for(uint i; i < userPositions.length; i++) {
            claimPosition(userPositions[i]);
        }
    }

    // Loops through all the positions and collects the ones where "_spender" is the spender
    function getSpenderPositions(address _spender) public view returns (Position[] memory) {
        Position[] memory spenderPos;
        for(uint i; i < positions.length; i++) {
            if (positions[i].spender == _spender) {
                spenderPos[i] = positions[i];
            }
        }
        return spenderPos;
    }

    // Sends the claimable amount of a position to its corresponding spender
    function claimPosition(Position memory _position) internal {
        uint256 weeksSinceLastClaim = (block.timestamp - _position.lastClaim) / 1 weeks;
        uint256 claimable = weeksSinceLastClaim * _position.weeklyAllowance;
        // Make sure the position has enough funds
        require(_position.totalDeposit >= claimable, "Insufficient funds");
        // Update the state of the position
        _position.lastClaim = block.timestamp;
        _position.totalClaimed += claimable;
        _position.totalDeposit -= claimable;
        // Send the funds to the spender
        payable(_position.spender).transfer(claimable);
       
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
