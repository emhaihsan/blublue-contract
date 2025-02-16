// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {BluBlueNFT} from "../src/BluBlueNFT.sol";
import {BluBluePost} from "../src/BluBluePost.sol";

contract BluBlueNFTTest is Test {
    BluBlueNFT public nft;
    BluBluePost public post;
    
    address public owner;
    address public user1;
    address public user2;

    event NFTMinted(
        uint256 indexed tokenId, 
        uint256 indexed postId, 
        address indexed author
    );

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        // Deploy post contract first
        post = new BluBluePost();

        // Deploy NFT contract with post contract address
        nft = new BluBlueNFT(address(post));
    }

    function test_ContractInitialization() public {
        assertEq(nft.name(), "BluBlue Post NFT");
        assertEq(nft.symbol(), "BBPOST");
        assertEq(address(nft.postContract()), address(post));
    }

    function test_MintNFT() public {
        // Create a post first
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://test-image", "Test caption");

        // Mint NFT for the post
        vm.prank(user1);
        uint256 tokenId = nft.mintPostNFT(postId);

        // Verify NFT details
        assertEq(nft.ownerOf(tokenId), user1);
        assertEq(nft.tokenURI(tokenId), "ipfs://test-image");
    }

    function test_MintNFT_EmitsEvent() public {
        // Create a post first
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://test-image", "Test caption");

        // Expect event
        vm.prank(user1);
        vm.expectEmit(true, true, true, false);
        emit NFTMinted(1, postId, user1);
        
        nft.mintPostNFT(postId);
    }

    function test_RevertWhen_NonAuthorMints() public {
        // Create a post as user1
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://test-image", "Test caption");

        // Try to mint as user2
        vm.prank(user2);
        vm.expectRevert("Not post author");
        nft.mintPostNFT(postId);
    }

    function test_RevertWhen_MintingTwice() public {
        // Create a post
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://test-image", "Test caption");

        // Mint first time
        vm.prank(user1);
        nft.mintPostNFT(postId);

        // Try to mint again
        vm.prank(user1);
        vm.expectRevert("Already minted");
        nft.mintPostNFT(postId);
    }

    function test_GetPostIdForToken() public {
        // Create a post
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://test-image", "Test caption");

        // Mint NFT
        vm.prank(user1);
        uint256 tokenId = nft.mintPostNFT(postId);

        // Verify post ID retrieval
        assertEq(nft.getPostIdForToken(tokenId), postId);
    }

    function test_GetTokenIdForPost() public {
        // Create a post
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://test-image", "Test caption");

        // Mint NFT
        vm.prank(user1);
        uint256 tokenId = nft.mintPostNFT(postId);

        // Verify token ID retrieval
        assertEq(nft.getTokenIdForPost(postId), tokenId);
    }

    function test_TransferNFT() public {
        // Create a post
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://test-image", "Test caption");

        // Mint NFT
        vm.prank(user1);
        uint256 tokenId = nft.mintPostNFT(postId);

        // Transfer NFT
        vm.prank(user1);
        nft.transferFrom(user1, user2, tokenId);

        // Verify new ownership
        assertEq(nft.ownerOf(tokenId), user2);
    }

    function test_RevertWhen_TokenURIForNonExistentToken() public {
        vm.expectRevert("ERC721: invalid token ID");
        nft.tokenURI(999);
    }

    function test_RevertWhen_GetPostIdForNonExistentToken() public {
        vm.expectRevert("ERC721: invalid token ID");
        nft.getPostIdForToken(999);
    }

    function test_MultiplePostsMintedByDifferentUsers() public {
        // Create posts by different users
        vm.prank(user1);
        uint256 postId1 = post.createPost("ipfs://image1", "First post");

        vm.prank(user2);
        uint256 postId2 = post.createPost("ipfs://image2", "Second post");

        // Mint NFTs
        vm.prank(user1);
        uint256 tokenId1 = nft.mintPostNFT(postId1);

        vm.prank(user2);
        uint256 tokenId2 = nft.mintPostNFT(postId2);

        // Verify details
        assertEq(nft.ownerOf(tokenId1), user1);
        assertEq(nft.ownerOf(tokenId2), user2);
        assertEq(nft.tokenURI(tokenId1), "ipfs://image1");
        assertEq(nft.tokenURI(tokenId2), "ipfs://image2");
    }
}
