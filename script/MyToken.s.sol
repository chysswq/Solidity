// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import "../src/TokenMy.sol";

contract MyTokenScript is Script {
    function setUp() public {}

    function run() public {
       vm.startBroadcast();
        TokenMy token = new TokenMy("chyToken", "chy");

        console.log("token:", address(token));

        require(token.balanceOf(address(this)) == 1e10 * 1e18, "bad amount");
        vm.stopBroadcast();
    }
}