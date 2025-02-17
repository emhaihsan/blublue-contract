// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/BluBluePost.sol";
import "../src/BBToken.sol";
import "../src/BluBlueNFT.sol";

contract BluBluePostTest is Test {
    BluBluePost public post;
    BBToken public token;
    BluBlueNFT public nft;

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
        nft = new BluBlueNFT(address(post));

        // Set token and NFT addresses
        post.setTokenContract(address(token));
        post.setNFTContract(address(nft));

        // Give some ETH to test users
        vm.deal(user1, 1 ether);
        vm.deal(user2, 1 ether);
    }

    function test_CreatePost() public {
        vm.startPrank(user1);

        string memory imageURI = "ipfs://QmTest";
        string memory caption = "Test post";

        uint256 postId = post.createPost(imageURI, caption);

        BluBluePost.Post memory createdPost = post.getPost(postId);
        assertEq(createdPost.author, user1);
        assertEq(createdPost.imageURI, imageURI);
        assertEq(createdPost.caption, caption);
        assertEq(createdPost.likeCount, 0);
        assertTrue(createdPost.isActive);

        vm.stopPrank();
    }

    function test_LikePost() public {
        // Create a post first
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://QmTest", "Test post");

        // Like the post as user2
        vm.prank(user2);
        post.likePost(postId);

        BluBluePost.Post memory likedPost = post.getPost(postId);
        assertEq(likedPost.likeCount, 1);
        assertTrue(post.userLikes(postId, user2));
    }

    function test_RevertWhen_LikingOwnPost() public {
        vm.startPrank(user1);

        uint256 postId = post.createPost("ipfs://QmTest", "Test post");

        vm.expectRevert("Can't like own post");
        post.likePost(postId);

        vm.stopPrank();
    }

    function test_UnlikePost() public {
        // Create and like a post
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://QmTest", "Test post");

        vm.prank(user2);
        post.likePost(postId);

        // Unlike the post
        vm.prank(user2);
        post.unlikePost(postId);

        BluBluePost.Post memory unlikedPost = post.getPost(postId);
        assertEq(unlikedPost.likeCount, 0);
        assertFalse(post.userLikes(postId, user2));
    }

    function test_DeletePost() public {
        vm.startPrank(user1);

        uint256 postId = post.createPost("ipfs://QmTest", "Test post");
        post.deletePost(postId);

        vm.expectRevert("Post not found");
        post.getPost(postId);

        vm.stopPrank();
    }

    function test_RevertWhen_DeletingOtherUserPost() public {
        // Create post as user1
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://QmTest", "Test post");

        // Try to delete as user2 (should revert)
        vm.prank(user2);
        vm.expectRevert("Not authorized");
        post.deletePost(postId);
    }

    function test_GetUserPosts() public {
        vm.startPrank(user1);

        // Create multiple posts
        post.createPost("ipfs://QmTest1", "Test post 1");
        post.createPost("ipfs://QmTest2", "Test post 2");
        post.createPost("ipfs://QmTest3", "Test post 3");

        BluBluePost.Post[] memory userPosts = post.getUserPosts(user1);
        assertEq(userPosts.length, 3);

        vm.stopPrank();
    }

    function test_SetTokenContract() public {
        address newToken = makeAddr("newToken");
        post.setTokenContract(newToken);
        assertEq(post.tokenContract(), newToken);
    }

    function test_SetNFTContract() public {
        address newNFT = makeAddr("newNFT");
        post.setNFTContract(newNFT);
        assertEq(post.nftContract(), newNFT);
    }

    function test_RevertWhen_SettingTokenContractUnauthorized() public {
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSignature(
                "OwnableUnauthorizedAccount(address)",
                user1
            )
        );
        post.setTokenContract(address(0x1));
    }

    function test_RevertWhen_SettingNFTContractUnauthorized() public {
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSignature(
                "OwnableUnauthorizedAccount(address)",
                user1
            )
        );
        post.setNFTContract(address(0x1));
    }
}
