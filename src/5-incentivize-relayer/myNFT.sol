// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/contracts@4.8.1/token/ERC721/ERC721.sol";
import "./Ownable.sol";

contract myNFT is ERC721, Ownable {
    address owner;

    constructor(string memory name, string memory symbol, address _owner) ERC721(name, symbol) Ownable(_owner) {
        owner = msg.sender;
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        require(msg.sender == owner);
        _safeMint(to, tokenId);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "My Avalanche Academy NFT";
    }
}
