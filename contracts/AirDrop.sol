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

contract AirDrop is Ownable, ReentrancyGuard {
    constructor(address initialOwner) Ownable(initialOwner) {}

    // Define event for ERC20 token transfer
    event ERC20Transfer(address indexed token, address indexed sender, address indexed recipient, uint256 value);
    // Define event for ERC1155 token transfer
    event ERC1155Transfer(address indexed token, address indexed sender, address indexed recipient, uint256 id, uint256 amount);
    address public acceptedToken; //token addres
    address public AnarchyToken; //token address
    uint256 public CF; //conversion factor


    function AirDropERC20(address _token, address _to, uint256 _value) public onlyOwner nonReentrant {

        IERC20 token = IERC20(_token);

        token.transferFrom(msg.sender, _to, _value);
        emit ERC20Transfer(_token, msg.sender, _to, _value);

        }

    function bulkAirDrop1155(address _token, address _to, uint256 _id, uint256 _amount) public onlyOwner nonReentrant{
        IERC1155 token = IERC1155 (_token);
        token.safeTransferFrom(msg.sender, _to, _id, _amount, '');
        emit ERC1155Transfer(_token, msg.sender, _to, _id, _amount);   
    }

    function BuyANRC(uint256 _value) public nonReentrant{
        IERC20 token = IERC20(acceptedToken);
        IERC20 ANRC = IERC20(AnarchyToken);
        token.transferFrom(msg.sender, owner(), _value); 
        uint256 amount = _value*CF/1e18;//conversion Factor and dividing 10^18
        ANRC.transferFrom(owner(), msg.sender, amount);
    }

    function setAcceptedToken(address _tokenAddress) public onlyOwner nonReentrant {
        acceptedToken = _tokenAddress;
    }
    function setANRCToken(address _tokenAddress) public onlyOwner nonReentrant {
        AnarchyToken = _tokenAddress;
    }
    function setConversionFactor(uint256 _cf) public onlyOwner nonReentrant {
        CF = _cf; //always put value conversion factor * 10^18
    }
}
