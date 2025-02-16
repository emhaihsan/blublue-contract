// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {BBToken} from "../src/BBToken.sol";
import {BluBluePost} from "../src/BluBluePost.sol";

contract BBTokenTest is Test {
    BBToken public token;
    BluBluePost public post;
    
    address public owner;
    address public user1;
    address public user2;

    event PostLikeTokensMinted(
        uint256 indexed postId, 
        address indexed author, 
        uint256 tokenAmount
    );

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        // Deploy post contract first
        post = new BluBluePost();

        // Deploy token contract with post contract address
        token = new BBToken(address(post));
    }

    function test_ContractInitialization() public {
        assertEq(token.name(), "BluBlue Token");
        assertEq(token.symbol(), "BB");
        assertEq(token.decimals(), 18);
        assertEq(address(token.postContract()), address(post));
    }

    function test_MintPostLikeTokens() public {
        // Create a post
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://test-image", "Test caption");

        // Like the post multiple times
        vm.prank(user2);
        post.likePost(postId);

        // Mint tokens as post author
        vm.prank(user1);
        token.mintPostLikeTokens(postId);

        // Check token balance
        assertEq(token.balanceOf(user1), 1 * 10 ** 18);
    }

    function test_MintPostLikeTokens_EmitsEvent() public {
        // Create a post
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://test-image", "Test caption");

        // Like the post multiple times
        vm.prank(user2);
        post.likePost(postId);

        // Expect event
        vm.prank(user1);
        vm.expectEmit(true, true, false, true);
        emit PostLikeTokensMinted(postId, user1, 1);
        
        token.mintPostLikeTokens(postId);
    }

    function test_RevertWhen_NonAuthorMints() public {
        // Create a post
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://test-image", "Test caption");

        // Like the post
        vm.prank(user2);
        post.likePost(postId);

        // Try to mint as non-author
        vm.prank(user2);
        vm.expectRevert("Not post author");
        token.mintPostLikeTokens(postId);
    }

    function test_RevertWhen_MintingTwice() public {
        // Create a post
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://test-image", "Test caption");

        // Like the post
        vm.prank(user2);
        post.likePost(postId);

        // First mint
        vm.prank(user1);
        token.mintPostLikeTokens(postId);

        // Try to mint again
        vm.prank(user1);
        vm.expectRevert("Tokens already minted");
        token.mintPostLikeTokens(postId);
    }

    function test_RevertWhen_NoLikes() public {
        // Create a post with no likes
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://test-image", "Test caption");

        // Try to mint
        vm.prank(user1);
        vm.expectRevert("No likes to mint tokens");
        token.mintPostLikeTokens(postId);
    }

    function test_MultiplePostsTokenMinting() public {
        // Create multiple posts
        vm.prank(user1);
        uint256 postId1 = post.createPost("ipfs://image1", "First post");

        vm.prank(user2);
        uint256 postId2 = post.createPost("ipfs://image2", "Second post");

        // Like posts
        vm.prank(user2);
        post.likePost(postId1);

        vm.prank(user1);
        post.likePost(postId2);

        // Mint tokens
        vm.prank(user1);
        token.mintPostLikeTokens(postId1);

        vm.prank(user2);
        token.mintPostLikeTokens(postId2);

        // Check token balances
        assertEq(token.balanceOf(user1), 1 * 10 ** 18);
        assertEq(token.balanceOf(user2), 1 * 10 ** 18);
    }

    function test_GetPostTokensMinted() public {
        // Create a post
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://test-image", "Test caption");

        // Like the post
        vm.prank(user2);
        post.likePost(postId);

        // Initially not minted
        assertFalse(token.getPostTokensMinted(postId));

        // Mint tokens
        vm.prank(user1);
        token.mintPostLikeTokens(postId);

        // Now minted
        assertTrue(token.getPostTokensMinted(postId));
    }
}
