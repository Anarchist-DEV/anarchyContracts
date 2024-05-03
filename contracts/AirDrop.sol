// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

interface IERC1155 {
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
}

contract AirDrop {
    address public Owner;
    constructor() {
        Owner = msg.sender;
    }

    function bulkAirDropERC20(address _token, address[] calldata _to, uint256[] calldata _value) public {
        require(msg.sender == Owner,"only owner can call these function");
        IERC20 token = IERC20(_token);
        require(_to.length == _value.length, "Receivers and amounts are different length!");
        for(uint256 i = 0; i < _to.length; i++) {
            require(token.transferFrom(msg.sender, _to[i], _value[i]));
        }
    }

    function bulkAirDrop1155(address _token, address[] calldata _to, uint256[] calldata _value, uint256[] calldata _amount) public {
        require(msg.sender == Owner,"only owner can call these function");
        IERC1155 token = IERC1155 (_token);
        require(_to.length == _value.length, "Receivers and amounts are different length!");
        for(uint256 i = 0; i < _to.length; i++) {
            token.safeTransferFrom(msg.sender, _to[i], _value[i], _amount[i], '');
        }
    }
}
