pragma solidity ^0.4.18;

contract owned{
    address public owner;
    function owned(){
        owner = msg.sender;
    }
    
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    
    function transferOwnership(address newOwner) onlyOwner{
        owner = newOwner;
    }
}

contract Radium is owned{
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    mapping (address => uint256) public balanceOf;
    
    function Radium(uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits, address centralMinter) public
    {
            balanceOf[msg.sender] = initialSupply;
            
            totalSupply = initialSupply;
            name = tokenName;
            symbol = tokenSymbol;
            decimals = decimalUnits;
            if(centralMinter != 0)
            {
                owner = centralMinter;
            }
    }
        
    function _transfer(address _from, address _to, uint256 _value) internal
    {
        require(_to != 0x0);
        require(balanceOf[msg.sender] >= _value && balanceOf[_to] + _ value >= balanceOf[_to]);
        require(!frozenAccount[_from] && ! frozenAccount[_to]);
    
        balanceOf[msg.sender] -= _value;
        balaceOf[_to] += _value;
        
        emit Transfer(msg.sender, _to, _value);
    }
    
    fuction mintToken(address target, uint256 mintedAmount) onlyOwner{
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        emit Transfer(0, owner, mintedAmount);
        emit Transfer(owner, target, mintedAmount);
    }
}