pragma solidity ^0.4.18;

contract owned{
    address public owner;
    function owned() public{
        owner = msg.sender;
    }
    
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner{
        owner = newOwner;
    }
}

contract Radium is owned{
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public sellPrice;
    uint256 public buyPrice;
    uint public minBalanceForAccounts;
    
    byte32 public currentChallenge;
    uint public timeOfLastProof;
    uint public difficulty = 10**32;
    
    mapping (address => uint256) public balanceOf;
    mapping (address => bool) public frozenAccount;
    mapping(address => mapping(address => uint256)) public allowance;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event FrozenFunds(address target, bool frozen);
    event Burn(address indexed from, uint256 value);
    
    
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
            timeOfLastProof = now;
    }
        
    function _transfer(address _from, address _to, uint256 _value) internal
    {
        require(_to != 0x0);
        require(balanceOf[msg.sender] >= _value && balanceOf[_to] + _value >= balanceOf[_to]);
        require(!frozenAccount[_from] && ! frozenAccount[_to]);
    
        balanceOf[msg.sender] -= _value;
        balaceOf[_to] += _value;
        
        emit Transfer(msg.sender, _to, _value);
        
        if(msg.sender.balance < minBalanceForAccounts)
        {
            sell((minBalanceForAccounts - msg.sender.balance) / sellPrice);
        }
    }
    
    function transfer(address _to, uint256 _value) public{
        _transfer(msg.sender, _to, _value);
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool success){
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success){
        allowance[msg.sender][_spender] = _value;
        return true;
    }
    
    function approveAnCall(address _spender, uint256 _value, bytes _extraData) public returns(bool success){
        tokenRecipient spender = tokenRecipient(_spender);
        if(approve(_spender,_value))
        {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
    
    function burn(uint256 _value) public returns (bool success){
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }
    
    function mintToken(address target, uint256 mintedAmount) public onlyOwner{
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        emit Transfer(0, owner, mintedAmount);
        emit Transfer(owner, target, mintedAmount);
    }
    
    function freezeAccount(address target, bool freeze) public onlyOwner{
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }
    
    function setPrices(unint256 newSellPrice, uint256 newBuyPrice) public onlyOwner{
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }
    
    function buy() payable public returns (uint amount){
        amount = msg.value / buyPrice;
        require(balanceOf[this] >= amount);
        balanceOf[msg.sender] += amount;
        balanceOf[this] -= amount;
        emit Transfer(this, msg.sender, amount);
        return amount;
    }
    
    function sell(uint amount) public returns (uint revenue){
        require(balanceOf[msg.sender] >= amount);
        balanceOf[this] += amount;
        balanceOf[msg.sender] -= amount;
        revenue = amount * sellPrice;
        msg.sender.transfer(revenue);
        emit Transfer(msg.sender, this, amount);
        return revenue;
    }
    
    function setMinBalance(uint minimumBalanceInFinney) public onlyOwner{
        minBalanceForAccounts = minimumBalanceInFinney * 1 finney;
    }
    
    function giveBlockReward() public{
        balanceOf[block.coinbase] += 1;
    }
    
    function proofOfWork(uint nounce) public{
        bytes8 n = bytes8(sha3(nounce, currentChallenge));
        require(n >= bytes8(difficulty));
        
        uint timeSinceLastProof = (now - timeOfLastProof);
        require(timeSinceLastProof >= 5 seconds);
        balanceOf[msg.sender] += timeSinceLastProof / 60 seconds;
        
        difficulty = difficulty * 10 minutes / timeSinceLastProof + 1;
        
        timeOfLastProof = now;
        currentChallenge = sha3(nounce, currentChallenge, block.blockhash(block.number - 1));
    }
}