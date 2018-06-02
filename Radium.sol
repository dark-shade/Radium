pragma solidity ^0.4.18;

contract Radium{
    string public name;
    string public symbol;
    uint8 public decimals;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    mapping (address => uint256) public balanceOf;
    
    function Radium(uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits) public
    {
            balanceOf[msg.sender] = initialSUpply;
            
            name = tokenName;
            symbol = tokenSymbol;
            decimals = decimalUnits;
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
    
    
}