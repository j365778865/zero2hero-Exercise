// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract XiaoMiDiToken {
    string public name = "XiaoMiDi";
    string public symbol = "XMD";
    uint256 public totalSupply = 1000000000 * 10**18;
    uint8 public decimals = 18;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        address owner = msg.sender;
        _transfer(owner,_to,_value);
        return true;
    }

    function _transfer(address from, address to, uint256 _value) internal virtual {

        require(from != address(0),"ERC20: transfer from the zero address");
        require(to != address(0),"ERC20: transfer from the zero address");

        // _beforeTokenTransfer(from,to, _value);

        uint256 fromBalance = balanceOf[from];
        require(fromBalance >= _value,"ERC20: transfer amount exceeds balance");
        unchecked{
            balanceOf[from] = fromBalance - _value;
            balanceOf[to] += _value; 
        }
        emit Transfer(from,to,_value);

        // _afterTokenTransfer(from,to, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

      function _approve(address from, address _spender, uint256 _value) public returns (bool success) {
        allowance[from][_spender] = _value;
        emit Approval(from, _spender, _value);
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //获取当前信息调用者地址
        address sender = msg.sender;
        //校验当前信息调用者在发送方的授权余额是否够用
        _spendAllowance(_from,sender,_value);
        //如果校验成功，则发送
        _transfer(_from,_to,_value);
        return true;
    }

    function _spendAllowance(address from, address sender, uint256 _value) internal virtual {

       uint256 currentAllowance = allowance[from][sender];

        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= _value,"ERC20: insufficient allowance");
            _approve(from,sender,currentAllowance-_value);
        }

        // _beforeTokenTransfer(from,to, _value);

        uint256 fromBalance = balanceOf[from];
        require(fromBalance >= _value,"ERC20: transfer amount exceeds balance");
       

        // _afterTokenTransfer(from,to, _value);
    }
}
