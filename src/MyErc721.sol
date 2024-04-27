// SPDX-License-Identifier: SEE LICENSE IN LICENSE

pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyErc721 is ERC721URIStorage {
    uint256 public number;
       constructor() ERC721("chy", "CAMP") {
      
    }

    function mint(address student, string memory tokenURI) public returns (uint256) {
        uint256 newItemId = number; 

        _mint(student, newItemId);
        _setTokenURI(newItemId, tokenURI);
        number++;
        return newItemId;
    }
}
