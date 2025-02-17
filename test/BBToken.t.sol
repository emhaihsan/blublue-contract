// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/BBToken.sol";
import "../src/BluBluePost.sol";

contract BBTokenTest is Test {
    BBToken public token;
    BluBluePost public post;

    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        // Deploy contracts
        post = new BluBluePost();
        token = new BBToken(address(post));

        // Set token address in post contract
        post.setTokenContract(address(token));

        // Give some ETH to test users
        vm.deal(user1, 1 ether);
        vm.deal(user2, 1 ether);
    }

    function test_Initialize() public {
        assertEq(token.name(), "BluBlue Token");
        assertEq(token.symbol(), "BBT");
        assertEq(address(token.postContract()), address(post));
        assertEq(token.decimals(), 18);
    }

    function test_MintPostLikeTokens() public {
        // Create a post as user1
        vm.startPrank(user1);
        uint256 postId = post.createPost("ipfs://QmTest", "Test post");
        vm.stopPrank();

        // Like the post as user2
        vm.prank(user2);
        post.likePost(postId);

        // Mint tokens as post author
        vm.prank(user1);
        token.mintPostLikeTokens(postId);

        // Verify token balance (1 like = 1 token)
        assertEq(token.balanceOf(user1), 1 * 10 ** 18);
        assertTrue(token.getPostTokensMinted(postId));
    }

    function test_MintPostLikeTokensMultipleLikes() public {
        // Create a post as user1
        vm.startPrank(user1);
        uint256 postId = post.createPost("ipfs://QmTest", "Test post");
        vm.stopPrank();

        // Add multiple likes from different users
        for (uint i = 0; i < 5; i++) {
            address liker = makeAddr(string(abi.encodePacked("liker", i)));
            vm.deal(liker, 1 ether);
            vm.prank(liker);
            post.likePost(postId);
        }

        // Mint tokens as post author
        vm.prank(user1);
        token.mintPostLikeTokens(postId);

        // Verify token balance (5 likes = 5 tokens)
        assertEq(token.balanceOf(user1), 5 * 10 ** 18);
    }

    function test_RevertWhen_MintingWithNoLikes() public {
        // Create a post as user1
        vm.startPrank(user1);
        uint256 postId = post.createPost("ipfs://QmTest", "Test post");

        // Try to mint tokens with no likes
        vm.expectRevert("No likes to mint tokens");
        token.mintPostLikeTokens(postId);
        vm.stopPrank();
    }

    function test_RevertWhen_MintingTokensTwice() public {
        // Create and like post
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://QmTest", "Test post");

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

    function test_RevertWhen_NonAuthorMinting() public {
        // Create post as user1
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://QmTest", "Test post");

        // Like post
        vm.prank(user2);
        post.likePost(postId);

        // Try to mint as non-author
        vm.prank(user2);
        vm.expectRevert("Not post author");
        token.mintPostLikeTokens(postId);
    }

    function test_RevertWhen_MintingForNonexistentPost() public {
        vm.prank(user1);
        vm.expectRevert("Post not found");
        token.mintPostLikeTokens(999);
    }
}
