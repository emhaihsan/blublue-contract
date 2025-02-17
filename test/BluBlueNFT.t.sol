// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/BluBlueNFT.sol";
import "../src/BluBluePost.sol";

contract BluBlueNFTTest is Test {
    BluBlueNFT public nft;
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
        nft = new BluBlueNFT(address(post));

        // Set NFT address in post contract
        post.setNFTContract(address(nft));

        // Give some ETH to test users
        vm.deal(user1, 1 ether);
        vm.deal(user2, 1 ether);
    }

    function test_Initialize() public {
        assertEq(nft.name(), "BluBlue NFT");
        assertEq(nft.symbol(), "BBN");
        assertEq(address(nft.postContract()), address(post));
    }

    function test_MintPostNFT() public {
        // Create a post as user1
        vm.startPrank(user1);
        uint256 postId = post.createPost("ipfs://QmTest", "Test post");

        // User1 mints their own post
        uint256 tokenId = nft.mintPostNFT(postId);
        vm.stopPrank();

        // Verify NFT ownership and data
        assertEq(nft.ownerOf(tokenId), user1);
        assertEq(nft.tokenURI(tokenId), "ipfs://QmTest");
        assertEq(nft.getPostIdForToken(tokenId), postId);
        assertEq(nft.getTokenIdForPost(postId), tokenId);
    }

    function test_DifferentUsersMintingSamePost() public {
        // User1 creates a post
        vm.prank(user1);
        uint256 postId = post.createPost("ipfs://QmTest", "Test post");

        // User1 tries to mint NFT
        vm.prank(user1);
        uint256 tokenId1 = nft.mintPostNFT(postId);

        // User2 tries to mint the same post (should revert)
        vm.prank(user2);
        vm.expectRevert("Not post author");
        nft.mintPostNFT(postId);

        // Verify only user1's NFT exists
        assertEq(nft.ownerOf(tokenId1), user1);
        assertEq(nft.getTokenIdForPost(postId), tokenId1);
    }

    function test_RevertWhen_MintingSamePostTwice() public {
        // Create and mint first time
        vm.startPrank(user1);
        uint256 postId = post.createPost("ipfs://QmTest", "Test post");
        nft.mintPostNFT(postId);

        // Try to mint again (should revert)
        vm.expectRevert("Already minted");
        nft.mintPostNFT(postId);
        vm.stopPrank();
    }

    function test_RevertWhen_MintingNonExistentPost() public {
        vm.prank(user1);
        vm.expectRevert("Post not found");
        nft.mintPostNFT(999);
    }

    function test_TokenURI() public {
        // Create post and mint NFT
        vm.startPrank(user1);
        uint256 postId = post.createPost("ipfs://QmTest", "Test post");
        uint256 tokenId = nft.mintPostNFT(postId);
        vm.stopPrank();

        assertEq(nft.tokenURI(tokenId), "ipfs://QmTest");
    }

    function test_RevertWhen_QueryingNonexistentToken() public {
        vm.expectRevert("ERC721: invalid token ID");
        nft.tokenURI(999);
    }
}
