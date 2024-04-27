// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Test, console} from "forge-std/Test.sol";

import {MyToken} from "../src/MyToken.sol";
import {MyErc721} from "../src/MyErc721.sol";
import {NFTMarket} from "../src/NftMarket.sol";
import "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

contract NFTMarketTest is Test {
    NFTMarket public myNFTMarket;
    MyToken public myToken;
    MyErc721 public myERC721;

    address public bob = address(1);

    address public cindy = address(2);

    function setUp() public {
        myToken = new MyToken();
        myERC721 = new MyErc721();
        myNFTMarket = new NFTMarket(address(myToken), address(myERC721));
        myERC721.mint(bob,"0xaaaa");
        
    }

    function testList_success() public {
        uint256 tokenId = 1;
        _list(tokenId, bob, myNFTMarket);

        uint256 gotPrice = myNFTMarket.tokenIdPrice(tokenId);
        assertEq(100, gotPrice, "want 100,but failed ");

        address seller = myNFTMarket.tokenIdSeller(tokenId);
        assertEq(bob, seller, "want bob failed ");
        vm.stopPrank();
    }

    function testList_failed_when_not_owner_operation() public {
        uint256 tokenId = 1;
        myToken.transfer(cindy, 1000);

        vm.startPrank(cindy);
        vm.expectRevert("not owner");
        myNFTMarket.list(1, 100);
        vm.stopPrank();
    }

     function testBuyNFT_success() public {
        // bob 上架
        uint256 tokenId = 1;
        _list(tokenId, bob, myNFTMarket);

        // cindy 授权后成功购买
        myToken.transfer(cindy, 1000);
        vm.startPrank(cindy);
        myToken.approve(address(myNFTMarket), 1000);
        myNFTMarket.buy(tokenId , 1000);
        assertEq(myERC721.ownerOf(tokenId), cindy, "owner is not cindy");
        vm.stopPrank();
    }


    function _list(uint256 newtokenId, address seller, NFTMarket _myNFTMarket) internal {
        uint256 newtokenId = 1;
        myToken.transfer(seller, 1000);

        vm.startPrank(seller);
        myERC721.isApprovedForAll(seller, address(_myNFTMarket));
        myERC721.approve(address(_myNFTMarket), newtokenId);

        _myNFTMarket.list(1, 100);

        vm.stopPrank();
    }

    function testBuyNFT_faild_when_allow_token_not_enough() public {
        uint256 tokenId = 1;
        _list(tokenId, bob, myNFTMarket);

        myToken.transfer(cindy, 1000);
        vm.startPrank(cindy);
        myToken.approve(address(myNFTMarket), 1);
        vm.expectRevert(
            abi.encodeWithSignature("ERC20InsufficientAllowance(address,uint256,uint256)", address(myNFTMarket), 1, 100)
        );
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, address(myNFTMarket), 1, 100)
        );

        myNFTMarket.buy(tokenId,1000);
        vm.stopPrank();
    }

    function testBuyNFT_faild_when_seller_not_approve_market_sell() public {
        uint256 tokenId = 1;
        myToken.transfer(bob, 1000);

        vm.startPrank(bob);
        myNFTMarket.list(1, 100);
        vm.stopPrank();

        myToken.transfer(cindy, 1000);
        vm.startPrank(cindy);
        myToken.approve(address(myNFTMarket), tokenId);
        vm.expectRevert(
            abi.encodeWithSignature("ERC721InsufficientApproval(address,uint256)", address(myNFTMarket), tokenId)
        );
        myNFTMarket.buy(tokenId,50);
        vm.stopPrank();
    }

    function testTransferCallback_market_buy_nft_success() public {
        uint256 tokenId = 1;
        _list(tokenId, bob, myNFTMarket);

        myToken.transfer(cindy, 100);
        vm.startPrank(cindy);
        bytes memory data = abi.encode(tokenId);
        bool success = myToken.transferWithCallback(address(myNFTMarket), 100, data);
        assertEq(true, success);
        vm.stopPrank();
    }
}