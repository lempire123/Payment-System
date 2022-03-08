pragma solidity ^0.8.0;

contract Payment {

    address public owner; 
    address public spender;
    uint256 public weeklyAllowance;
    uint256 public weekCounter = 1;
    uint256 public totalClaimed;
    uint256 public startTime;
    bool public initialized = false;
    
    constructor() {
        owner = msg.sender;
    }

    function initialize(address _spender, uint256 _weeklyAllowance) public payable {
        require(msg.sender == owner, "only Owner can deposit");
        require(initialized == false, "already initialized");
        spender = _spender;
        weeklyAllowance = _weeklyAllowance;
        startTime = block.timestamp;
        initialized = true;
    }

    function deposit() public payable {}

    function claim() external {
        require(msg.sender == spender, "Can only be called by spender");
        require(block.timestamp >= (startTime + (weekCounter * 1 weeks)), "Cannot claim yet");
        require(getContractBalance() >= weeklyAllowance, "Gotta top up the balance");
        weekCounter += 1;
        payable(msg.sender).transfer(weeklyAllowance);
        totalClaimed += weeklyAllowance;
    }

    function withdraw(uint256 amount) external {
        require(msg.sender == owner, "Only Owner can access");
        payable(msg.sender).transfer(amount);
    }

    function emergencyWithdraw() external {
        require(msg.sender == owner, "Only Owner can access");
        uint256 totalBalance = address(this).balance;
        payable(msg.sender).transfer(totalBalance);
    }

    function editAllowance(uint256 newAllowance) external {
        require(msg.sender == owner, "Only Owner can access");
        weeklyAllowance = newAllowance;
    }

    function transferOwnership(address newOwner) external {
        require(msg.sender == owner, "Only Owner can access");
        owner = newOwner;
    }

    function getTotalClaimed() public view returns (uint256) {
        return totalClaimed;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
