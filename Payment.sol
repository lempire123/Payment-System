pragma solidity ^0.8.0;

contract Payment { 

    // A position represents the relationship between the Owner and spender
    struct Position {
        address spender;
        uint256 allowance;
        uint256 totalDeposit;
        uint256 totalClaimed;
        uint256 weeklyAllowance;
        uint256 lastClaim;
    }

    // Array to keep track of all position ever created
    Position[] public positions;
    
    // Mapping of position to its corresponding owner (creator)
    // Each owner can only have one position
    mapping(address => Position) public ownerPosition;

    // Allows anyone to create a position
    function createPosition(
        address _spender;
        uint256 _allowance;
        uint256 _weekCounter;
        uint256 _weeklyAllowance;
        ) public payable {
            
        // Cannot create more than one position
        require(ownerPosition[msg.sender] == 0, "Can only create one position");

        // Creation of position
        Position newPosition = Position(
            spender: _spender,
            allowance: _allowance,
            totalDeposit: msg.value,
            weekCounter: 1,
            totalClaimed: 0,
            weeklyAllowance: _weekCounter,
            lastClaim: block.timestamp
        );

        // Mapping is added
        ownerPosition[msg.sender] = newPosition;

        // Position is pushed to the array
        positions.push(newPosition);
    }


    // Allows the spender to claim his allowance for ALL positions he is elligible for
    function claim() public {
        uint256 spender = msg.sender;
        Position[] userPositions = getSpenderPositions(spender);
        
        for(uint i; i < userPositions.length; i++) {
            claimPosition(userPositions[i]);
        }
    }

    // Loops through all the positions and collects the ones where "_spender" is the spender
    function getSpenderPositions(address _spender) public view returns (Position[]) {
        Position[] spenderPos;
        for(uint i; i < positions.length; i++) {
            if (positions[i].spender == _spender) {
                spenderPos.push(positions[i])
            }
        }
        return spenderPos;
    }

    // Sends the claimable amount of a position to its corresponding spender
    function claimPosition(Position _position) internal returns (uint256) {
        uint256 weeksSinceLastClaim = (block.timestamp - _position.lastClaim) / 1 weeks;
        uint256 claimable = weeksSinceLastClaim * weeklyAllowance;
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
        Position position = ownerPosition[msg.sender];
        position.weeklyAllowance = newAllowance;
    }

    // Allows the owner of a position to top up its balance
    function deposit() public payable {
        address depositor = msg.sender;
        ownerPosition[depositor].totalDeposit += msg.value;
    }

    // Allows the owner to withdraw ALL funds
    function withdrawFunds() public {
        Position position = ownerPosition[msg.sender];
        uint256 bal = position.totalDeposit;
        payable(msg.sender).transfer(bal);
    }
}
