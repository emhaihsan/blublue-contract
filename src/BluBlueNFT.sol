// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BluBluePost.sol";

contract BluBlueNFT is ERC721, Ownable {
    BluBluePost public postContract;
    uint256 private _nextTokenId = 1;

    // Mapping to store token URIs
    mapping(uint256 => string) private _tokenURIs;
    
    // Mapping to link posts to tokens and vice versa
    mapping(uint256 => uint256) private postToToken;
    mapping(uint256 => uint256) private tokenToPost;

    // Event for NFT minting
    event NFTMinted(
        uint256 indexed tokenId, 
        uint256 indexed postId, 
        address indexed author
    );

    constructor(address _postContractAddress) 
        ERC721("BluBlue Post NFT", "BBPOST") 
        Ownable(msg.sender) 
    {
        postContract = BluBluePost(_postContractAddress);
    }

    function mintPostNFT(uint256 postId) external returns (uint256) {
        // Retrieve the post details
        BluBluePost.Post memory postDetails = postContract.getPost(postId);
        
        // Ensure only the post author can mint
        require(postDetails.author == msg.sender, "Not post author");
        
        // Check if the post has already been minted
        require(postToToken[postId] == 0, "Already minted");

        // Mint the NFT
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);

        // Store token URI and post-token mappings
        _tokenURIs[tokenId] = postDetails.imageURI;
        postToToken[postId] = tokenId;
        tokenToPost[tokenId] = postId;

        // Emit minting event
        emit NFTMinted(tokenId, postId, msg.sender);

        return tokenId;
    }

    function tokenURI(uint256 tokenId) 
        public 
        view 
        override 
        returns (string memory) 
    {
        // Ensure token exists
        require(_ownerOf(tokenId) != address(0), "ERC721: invalid token ID");
        return _tokenURIs[tokenId];
    }

    function getPostIdForToken(uint256 tokenId) external view returns (uint256) {
        // Ensure token exists
        require(_ownerOf(tokenId) != address(0), "ERC721: invalid token ID");
        return tokenToPost[tokenId];
    }

    function getTokenIdForPost(uint256 postId) external view returns (uint256) {
        return postToToken[postId];
    }
}
