// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {BluBluePost} from "../src/BluBluePost.sol";

contract BluBluePostTest is Test {
    BluBluePost public post;
    address public user1;
    address public user2;

    event PostCreated(
        uint256 indexed postId, 
        address indexed author, 
        string imageURI, 
        string caption
    );
    
    event PostLiked(
        uint256 indexed postId, 
        address indexed liker
    );
    
    event PostUnliked(
        uint256 indexed postId, 
        address indexed unliker
    );
    
    event PostDeleted(
        uint256 indexed postId, 
        address indexed author
    );

    function setUp() public {
        post = new BluBluePost();
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
    }

    function test_CreatePost() public {
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://image1", "First post!");

        BluBluePost.Post memory createdPost = post.getPost(postId);
        
        assertEq(createdPost.id, postId);
        assertEq(createdPost.author, user1);
        assertEq(createdPost.imageURI, "ipfs://image1");
        assertEq(createdPost.caption, "First post!");
        assertEq(createdPost.likeCount, 0);
        assertTrue(createdPost.isActive);
    }

    function test_CreatePost_EmitsEvent() public {
        vm.prank(user1);
        
        vm.expectEmit(true, true, false, true);
        emit PostCreated(1, user1, "ipfs://image1", "First post!");
        
        post.createPost("ipfs://image1", "First post!");
    }

    function test_RevertWhen_CreatingPostWithEmptyURI() public {
        vm.prank(user1);
        vm.expectRevert("Empty URI");
        post.createPost("", "Empty URI post");
    }

    function test_LikePost() public {
        // Create a post first
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://image1", "First post!");

        // Like the post
        vm.prank(user2);
        post.likePost(postId);

        // Check post state
        BluBluePost.Post memory likedPost = post.getPost(postId);
        assertEq(likedPost.likeCount, 1);
        assertTrue(post.userLikes(postId, user2));
    }

    function test_LikePost_EmitsEvent() public {
        // Create a post first
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://image1", "First post!");

        // Like the post
        vm.prank(user2);
        
        vm.expectEmit(true, true, false, false);
        emit PostLiked(postId, user2);
        
        post.likePost(postId);
    }

    function test_RevertWhen_LikingNonExistentPost() public {
        vm.prank(user1);
        vm.expectRevert("Post not found");
        post.likePost(999);
    }

    function test_RevertWhen_LikingOwnPost() public {
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://image1", "First post!");

        vm.prank(user1);
        vm.expectRevert("Can't like own post");
        post.likePost(postId);
    }

    function test_RevertWhen_LikingPostTwice() public {
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://image1", "First post!");

        vm.prank(user2);
        post.likePost(postId);

        vm.prank(user2);
        vm.expectRevert("Already liked");
        post.likePost(postId);
    }

    function test_UnlikePost() public {
        // Create and like a post first
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://image1", "First post!");

        vm.prank(user2);
        post.likePost(postId);

        // Unlike the post
        vm.prank(user2);
        post.unlikePost(postId);

        // Check post state
        BluBluePost.Post memory unlikedPost = post.getPost(postId);
        assertEq(unlikedPost.likeCount, 0);
        assertFalse(post.userLikes(postId, user2));
    }

    function test_UnlikePost_EmitsEvent() public {
        // Create and like a post first
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://image1", "First post!");

        vm.prank(user2);
        post.likePost(postId);

        // Unlike the post
        vm.prank(user2);
        
        vm.expectEmit(true, true, false, false);
        emit PostUnliked(postId, user2);
        
        post.unlikePost(postId);
    }

    function test_RevertWhen_UnlikingWithoutLiking() public {
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://image1", "First post!");

        vm.prank(user2);
        vm.expectRevert("Not liked");
        post.unlikePost(postId);
    }

    function test_DeletePost() public {
        // Create a post
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://image1", "First post!");

        // Delete the post
        vm.prank(user1);
        post.deletePost(postId);

        // Try to get the post (should revert)
        vm.expectRevert("Post not found");
        post.getPost(postId);
    }

    function test_DeletePost_EmitsEvent() public {
        // Create a post
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://image1", "First post!");

        // Delete the post
        vm.prank(user1);
        
        vm.expectEmit(true, true, false, false);
        emit PostDeleted(postId, user1);
        
        post.deletePost(postId);
    }

    function test_RevertWhen_NonAuthorDeletesPost() public {
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://image1", "First post!");

        vm.prank(user2);
        vm.expectRevert("Not authorized");
        post.deletePost(postId);
    }

    function test_GetUserPosts() public {
        // Create multiple posts
        vm.startPrank(user1);
        uint256 postId1 = post.createPost("ipfs://image1", "First post!");
        uint256 postId2 = post.createPost("ipfs://image2", "Second post!");
        post.deletePost(postId1);
        vm.stopPrank();

        // Get user posts
        BluBluePost.Post[] memory userPosts = post.getUserPosts(user1);
        
        // Should only return active posts
        assertEq(userPosts.length, 1);
        assertEq(userPosts[0].id, postId2);
    }

    function test_UserLikes() public {
        // Create a post
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://image1", "First post!");

        // Like the post
        vm.prank(user2);
        post.likePost(postId);

        // Check likes
        assertTrue(post.userLikes(postId, user2));
        assertFalse(post.userLikes(postId, user1));
    }
}
