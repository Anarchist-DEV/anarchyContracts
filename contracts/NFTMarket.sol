// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}


contract marketPlaceBoilerPlate is  ERC1155Holder, ReentrancyGuard, Ownable{
    // using Counters for Counters.Counter;
    uint256 private _itemIds;
    uint256 private _itemsSold;
    address public acceptedToken; //token addres

    
     
    constructor(address initialOwner) Ownable(initialOwner){}

     
     struct MarketItem {
         uint itemId;
         address nftContract;
         uint256 tokenId;
         address seller;
         address owner;
         uint256 price;
         uint256 itemLeft

         ;
     }
     
     mapping(uint256 => MarketItem) private idToMarketItem;
     
     event MarketItemCreated (
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        uint256 itemLeft
     );
     
     event MarketItemSold (
         uint indexed itemId,
         address owner
         );
     
    
    function setAcceptedToken(address _tokenAddress) public onlyOwner nonReentrant { //give ANRC address
        acceptedToken = _tokenAddress;
    }
    function createMarketItem (
        address nftContract,
        uint256 tokenId,
        uint256 amount,
        uint256 priceInANRC //per unit 
        ) public payable nonReentrant {
            require(priceInANRC > 0, "Price must be greater than 0");
            
            _itemIds = _itemIds +1;
            uint256 itemId = _itemIds;
  
            idToMarketItem[itemId] =  MarketItem(
                itemId,
                nftContract,
                tokenId,
                msg.sender,
                payable(address(0)),
                priceInANRC,
                amount
            );
            
            IERC1155(nftContract).safeTransferFrom(msg.sender, address(this), tokenId, amount, "0x");
                
            emit MarketItemCreated(
                itemId,
                nftContract,
                tokenId,
                msg.sender,
                address(0),
                priceInANRC,
                amount
            );
        }
        
    function createMarketSaleInToken (
        address nftContract,
        uint256 itemId,
        uint256 amount
        ) public payable nonReentrant {
            uint price = idToMarketItem[itemId].price;
            uint tokenId = idToMarketItem[itemId].tokenId;
            uint itemLeft = idToMarketItem[itemId].itemLeft;
            uint totalAmountToPay = amount * price;
            require( itemLeft - amount >= 0 , "not enough item left in sale");
            emit MarketItemSold(
                itemId,
                msg.sender
                );

            IERC20(acceptedToken).transferFrom(msg.sender, idToMarketItem[itemId].owner, totalAmountToPay);
            _itemsSold = _itemsSold + 1;
            idToMarketItem[itemId].itemLeft -= amount ;
            IERC1155(nftContract).safeTransferFrom(address(this), msg.sender, tokenId, amount ,"0x");
        }
        
    function cancelSale(
        address nftContract,
        uint256 itemId,
        uint256 amount
    ) public nonReentrant {
            require(idToMarketItem[itemId].owner == msg.sender);
            uint tokenId = idToMarketItem[itemId].tokenId;
            uint itemLeft = idToMarketItem[itemId].itemLeft;
            require( itemLeft - amount >= 0 , "not enough item left in sale for cancelling");
            IERC1155(nftContract).safeTransferFrom(address(this), msg.sender, tokenId, amount ,"0x");
    }
        
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint itemCount = _itemIds;
        uint unsoldItemCount = _itemIds - _itemsSold;
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(0)) {
                uint currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
      
}
