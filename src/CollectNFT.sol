// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ContentNFT is ERC721 {
    uint256 private _tokenIds;

    constructor() ERC721("Content NFT", "CNFT") {}

    function mint() public payable returns (uint256) {
        _tokenIds += 1;
        _mint(msg.sender, _tokenIds);
        return _tokenIds;
    }
}
