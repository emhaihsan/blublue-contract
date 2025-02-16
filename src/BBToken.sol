// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BluBluePost.sol";

contract BBToken is ERC20, Ownable {
    BluBluePost public postContract;

    // Mapping to track minted tokens for posts
    mapping(uint256 => bool) private _postTokensMinted;

    // Event for token minting based on post likes
    event PostLikeTokensMinted(
        uint256 indexed postId, 
        address indexed author, 
        uint256 tokenAmount
    );

    constructor(address _postContractAddress) 
        ERC20("BluBlue Token", "BB") 
        Ownable(msg.sender)
    {
        postContract = BluBluePost(_postContractAddress);
    }

    function mintPostLikeTokens(uint256 postId) external {
        // Retrieve the post details
        BluBluePost.Post memory postDetails = postContract.getPost(postId);
        
        // Ensure only the post author can mint
        require(postDetails.author == msg.sender, "Not post author");
        
        // Check if tokens for this post have already been minted
        require(!_postTokensMinted[postId], "Tokens already minted");
        
        // Calculate token amount based on likes (1 token per like)
        uint256 tokenAmount = postDetails.likeCount;
        
        // Require at least one like
        require(tokenAmount > 0, "No likes to mint tokens");
        
        // Mark tokens as minted for this post
        _postTokensMinted[postId] = true;
        
        // Mint tokens to the post author
        _mint(msg.sender, tokenAmount * 10 ** decimals());
        
        // Emit event
        emit PostLikeTokensMinted(postId, msg.sender, tokenAmount);
    }

    function getPostTokensMinted(uint256 postId) external view returns (bool) {
        return _postTokensMinted[postId];
    }

    // Override decimals to use 18 decimal places (standard for ERC20)
    function decimals() public pure override returns (uint8) {
        return 18;
    }
}
