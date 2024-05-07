// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarketplace is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    struct Sale {
        address seller;
        uint256 price;
        bool isActive;
    }

    mapping(uint256 => Sale) private _tokenSales;

    event NftListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event NftSold(uint256 indexed tokenId, address indexed buyer, uint256 price);

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    function listNFT(uint256 tokenId, uint256 price) external {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Market: not owner or approved");
        _tokenSales[tokenId] = Sale({seller: msg.sender, price: price, isActive: true});
        emit NftListed(tokenId, msg.sender, price);
    }

    function buyNFT(uint256 tokenId) external payable {
        Sale storage sale = _tokenSales[tokenId];
        require(sale.isActive, "Market: nft not for sale");
        require(msg.value >= sale.price, "Market: insufficient funds");

        address seller = sale.seller;

        _safeTransfer(seller, _msgSender(), tokenId, "");
        sale.isActive = false;

        emit NftSold(tokenId, msg.sender, sale.price);
    }

    function cancelSale(uint256 tokenId) external {
        Sale storage sale = _tokenSales[tokenId];
        require(msg.sender == sale.seller, "Market: caller is not the seller");

        sale.isActive = false;
    }

    function getNFTSale(uint256 tokenId) external view returns (address seller, uint256 price, bool isActive) {
        Sale storage sale = _tokenSales[tokenId];
        return (sale.seller, sale.price, sale.isActive);
    }
}