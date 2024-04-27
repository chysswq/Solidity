// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./MyToken.sol";
import "./MyErc721.sol";

contract NFTMarket is IERC721Receiver {
   
    mapping(uint256 => uint256) public tokenIdPrice;
    mapping(uint256 => address) public tokenIdSeller;
    address public immutable token;
    address public immutable nftToken;
    
    
    constructor(address _token, address _nftToken) {
        token = _token;
        nftToken = _nftToken;
    }
   

    function list (uint tokenId, uint amount)public {
        IERC721(nftToken).safeTransferFrom(msg.sender, address(this), tokenId,"");
        tokenIdPrice [tokenId] = amount;
         tokenIdSeller [tokenId]  =msg.sender;
    }

    function buy (uint tokenId, uint amount)external {
        require(amount >= tokenIdPrice[tokenId] , "low price");
        require(IERC721(nftToken).ownerOf(tokenId) == address(this),"aleady selled");

        IERC20(token).transferFrom(msg.sender, address(this), tokenIdPrice[tokenId]);
        IERC721(nftToken).transferFrom(address(this),msg.sender,tokenId);
    }
   
       function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4)
    {
        return this.onERC721Received.selector;
    }
  function tokenReceived(address buyer, uint256 amount, bytes memory data) external returns (bool) {
        uint256 tokenId = abi.decode(data, (uint256));
        IERC20(token).transfer(tokenIdSeller[tokenId], tokenIdPrice[tokenId]);

        IERC721(token).safeTransferFrom(tokenIdSeller[tokenId], buyer, tokenId);
        return true;
    }
}


