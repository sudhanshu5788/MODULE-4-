// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DegenToken {
    string public name = "Degen";
    string public symbol = "DGN";
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    address public owner;

    mapping(uint256 => string) public items;
    mapping(uint256 => uint256) public itemPrices;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event ItemAdded(uint256 itemId, string itemName, uint256 itemPrice);
    event ItemRedeemed(address indexed player, uint256 itemId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply;
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        require(to != address(0), "Invalid address");
        require(value > 0, "Invalid amount");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        require(spender != address(0), "Invalid address");

        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(from != address(0), "Invalid address");
        require(to != address(0), "Invalid address");
        require(value > 0, "Invalid amount");
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function mint(address to, uint256 value) external onlyOwner returns (bool) {
        require(to != address(0), "Invalid address");
        require(value > 0, "Invalid amount");

        totalSupply += value;
        balanceOf[to] += value;
        emit Transfer(address(0), to, value);
        return true;
    }

    function burn(uint256 value) external returns (bool) {
        require(value > 0, "Invalid amount");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        totalSupply -= value;
        balanceOf[msg.sender] -= value;
        emit Transfer(msg.sender, address(0), value);
        return true;
    }

    function addItemToStore(uint256 itemId, string memory itemName, uint256 price) external onlyOwner {
        require(bytes(itemName).length > 0, "Item name cannot be empty");
        require(price > 0, "Invalid item price");
        items[itemId] = itemName;
        itemPrices[itemId] = price;
        emit ItemAdded(itemId, itemName, price);
    }

    function redeemItem(uint256 itemId) external returns (bool) {
        require(bytes(items[itemId]).length > 0, "Item does not exist");
        require(itemPrices[itemId] > 0, "Item price not set");
        require(balanceOf[msg.sender] >= itemPrices[itemId], "Insufficient balance for the item");

        balanceOf[msg.sender] -= itemPrices[itemId];
        balanceOf[owner] += itemPrices[itemId];

        emit Transfer(msg.sender, owner, itemPrices[itemId]);
        emit ItemRedeemed(msg.sender, itemId);
        return true;
    }

    function getAvailableItems() external view returns (uint256[] memory, string[] memory, uint256[] memory) {
        uint256[]  memory itemIds = new uint256[](4); 
        string[] memory itemNames = new string[](4);
        uint256[] memory itemPricesArr = new uint256[](4);

        
        itemIds[0] = 1; 
        itemNames[0] = items[1];
        itemPricesArr[0] = itemPrices[1];

        itemIds[1] = 2; 
        itemNames[1] = items[2];
        itemPricesArr[1] = itemPrices[2];

        itemIds[2] = 3;
        itemNames[2] = items[3];
        itemPricesArr[2] = itemPrices[3];

        itemIds[3] = 4; 
        itemNames[3] = items[4];
        itemPricesArr[3] = itemPrices[4];

        return (itemIds, itemNames, itemPricesArr);
    }
}
