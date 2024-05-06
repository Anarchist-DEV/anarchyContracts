// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}



interface IERC1155 {
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
}

contract BulkAirDrop is Ownable, ReentrancyGuard {
    constructor(address initialOwner) Ownable(initialOwner) {}

    // Define event for ERC20 token transfer
    event ERC20BulkTransfer(address indexed token, address indexed sender, address indexed recipient, uint256 value);
    // Define event for ERC1155 token transfer
    event ERC1155BulkTransfer(address indexed token, address indexed sender, address indexed recipient, uint256 id, uint256 amount);



    function bulkAirDropERC20(address _token, address[] calldata _to, uint256[] calldata _value) public onlyOwner nonReentrant {

        IERC20 token = IERC20(_token);
        require(_to.length == _value.length, "Receivers and amounts are different length!");
        for(uint256 i = 0; i < _to.length; i++) {
            require(token.transferFrom(msg.sender, _to[i], _value[i]),"Transfer failed");
            emit ERC20BulkTransfer(_token, msg.sender, _to[i], _value[i]);

        }
    }

    function bulkAirDrop1155(address _token, address[] calldata _to, uint256[] calldata _id, uint256[] calldata _amount) public onlyOwner nonReentrant{
        IERC1155 token = IERC1155 (_token);
        require(_to.length == _id.length && _to.length == _amount.length, "Receivers, value and amounts are of different length!");
        for(uint256 i = 0; i < _to.length; i++) {
            token.safeTransferFrom(msg.sender, _to[i], _id[i], _amount[i], '');
            emit ERC1155BulkTransfer(_token, msg.sender, _to[i], _id[i], _amount[i]);

        }
    }
}
