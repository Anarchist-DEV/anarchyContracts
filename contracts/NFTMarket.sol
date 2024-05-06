// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";



contract marketPlaceBoilerPlate is  ERC1155Holder, ReentrancyGuard{
    // using Counters for Counters.Counter;
    uint256 private _itemIds;
    uint256 private _itemsSold;
    
     
    constructor() {}

     
     struct MarketItem {
         uint itemId;
         address nftContract;
         uint256 tokenId;
         address payable seller;
         address payable owner;
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
     
    
    
    function createMarketItem (
        address nftContract,
        uint256 tokenId,
        uint256 amount,
        uint256 price
        ) public payable nonReentrant {
            require(price > 0, "Price must be greater than 0");
            
            _itemIds = _itemIds +1;
            uint256 itemId = _itemIds;
  
            idToMarketItem[itemId] =  MarketItem(
                itemId,
                nftContract,
                tokenId,
                payable(msg.sender),
                payable(address(0)),
                price,
                amount
            );
            
            IERC1155(nftContract).safeTransferFrom(msg.sender, address(this), tokenId, amount, "0x");
                
            emit MarketItemCreated(
                itemId,
                nftContract,
                tokenId,
                msg.sender,
                address(0),
                price,
                amount
            );
        }
        
    function createMarketSaleInEth (
        address nftContract,
        uint256 itemId,
        uint256 amount
        ) public payable nonReentrant {
            uint price = idToMarketItem[itemId].price;
            uint tokenId = idToMarketItem[itemId].tokenId;
            uint itemLeft = idToMarketItem[itemId].itemLeft;
            require(msg.value == amount * price, "Please submit the asking price in order to complete the purchase");
            require( itemLeft - amount >= 0 , "not enough item left in sale");
            emit MarketItemSold(
                itemId,
                msg.sender
                );

            idToMarketItem[itemId].seller.transfer(msg.value);
            idToMarketItem[itemId].owner = payable(msg.sender);
            _itemsSold = _itemsSold + 1;
            idToMarketItem[itemId].itemLeft -= amount ;
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
