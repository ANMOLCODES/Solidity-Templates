// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.6.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.6.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.6.0/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts@4.6.0/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts@4.6.0/token/ERC721/utils/ERC721Holder.sol";

contract MyToken is ERC20, Ownable, ERC20Permit, ERC721Holder {

    IERC721 public collection; //address of this NFT we're trying to fractionalize
    uint256 public tokenId; //tokenId of the NFT we're trying to fractionalize
    bool public initialized = false;
    bool public forSale = false;
    uint256 public salePrice;
    bool public canRedeem = false;

    constructor() ERC20("MyToken", "MTK") ERC20Permit("MyToken") {}

    /** @dev transfer NFT owned by msg.sender to the contract and fractionalisez it into _amount ERC20 token.
      * @param _collection Address of the NFT collection.
      * @param _tokenId tokenId of the NFT owned my msg.sender.
      * @param _amount amount of ERC20 token to be created.
      */
    function intialize(address _collection, uint256 _tokenId, uint256 _amount) external onlyOwner {
        require(!initialized, "Already initialised");
        require(_amount > 0, "Amount needs to be more than 0");
        collection = IERC721(_collection);
        collection.safeTransferFrom(msg.sender, address(this), _tokenId); 
        tokenId = _tokenId;
        initialized = true;
        _mint(msg.sender, _amount);
    }

    function putForSale(uint256 price) external onlyOwner {
        salePrice = price;
        forSale = true;
    }

    function purchase() external payable{
        require(forSale, "Not for sale");
        require(msg.value >= salePrice, "Not enough ether sent");
        collection.safeTransferFrom(address(this), msg.sender, tokenId);
        forSale = false;
        canRedeem = true;
    }

    function redeem(uint256 _amount) external {
        require(canRedeem, "Redemption not available");
        uint256 totalEther = address(this).balance;
        uint256 toRedeem = _amount * totalEther / totalSupply();
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(toRedeem);
    }
    
}
