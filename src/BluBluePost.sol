// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract BluBluePost is Ownable {
    struct Post {
        uint256 id;
        address author;
        string imageURI;
        string caption;
        uint256 likeCount;
        bool isActive;
    }

    uint256 private _nextPostId = 1;
    mapping(uint256 => Post) private _posts;
    mapping(uint256 => mapping(address => bool)) private _userLikes;
    mapping(address => uint256[]) private _userPosts;

    address public tokenContract;
    address public nftContract;

    event PostCreated(
        uint256 indexed postId,
        address indexed author,
        string imageURI,
        string caption
    );

    event PostLiked(uint256 indexed postId, address indexed liker);

    event PostUnliked(uint256 indexed postId, address indexed unliker);

    event PostDeleted(uint256 indexed postId, address indexed author);

    constructor() Ownable(msg.sender) {}

    function setTokenContract(address _tokenContract) external onlyOwner {
        require(_tokenContract != address(0), "Invalid token address");
        tokenContract = _tokenContract;
    }

    function setNFTContract(address _nftContract) external onlyOwner {
        require(_nftContract != address(0), "Invalid NFT address");
        nftContract = _nftContract;
    }

    function createPost(
        string memory imageURI,
        string memory caption
    ) external returns (uint256) {
        require(bytes(imageURI).length > 0, "Empty URI");

        uint256 postId = _nextPostId++;

        _posts[postId] = Post({
            id: postId,
            author: msg.sender,
            imageURI: imageURI,
            caption: caption,
            likeCount: 0,
            isActive: true
        });

        _userPosts[msg.sender].push(postId);

        emit PostCreated(postId, msg.sender, imageURI, caption);

        return postId;
    }

    function likePost(uint256 postId) external {
        Post storage post = _posts[postId];

        require(post.isActive, "Post not found");
        require(post.author != msg.sender, "Can't like own post");
        require(!_userLikes[postId][msg.sender], "Already liked");

        post.likeCount++;
        _userLikes[postId][msg.sender] = true;

        emit PostLiked(postId, msg.sender);
    }

    function unlikePost(uint256 postId) external {
        Post storage post = _posts[postId];

        require(post.isActive, "Post not found");
        require(_userLikes[postId][msg.sender], "Not liked");

        post.likeCount--;
        _userLikes[postId][msg.sender] = false;

        emit PostUnliked(postId, msg.sender);
    }

    function deletePost(uint256 postId) external {
        Post storage post = _posts[postId];

        require(post.isActive, "Post not found");
        require(post.author == msg.sender, "Not authorized");

        post.isActive = false;

        emit PostDeleted(postId, msg.sender);
    }

    function getPost(uint256 postId) external view returns (Post memory) {
        require(_posts[postId].isActive, "Post not found");
        return _posts[postId];
    }

    function getUserPosts(address user) external view returns (Post[] memory) {
        uint256[] memory postIds = _userPosts[user];
        Post[] memory userPosts = new Post[](postIds.length);

        uint256 activePostCount = 0;
        for (uint256 i = 0; i < postIds.length; i++) {
            Post memory post = _posts[postIds[i]];
            if (post.isActive) {
                userPosts[activePostCount] = post;
                activePostCount++;
            }
        }

        // Resize the array to remove empty slots
        assembly {
            mstore(userPosts, activePostCount)
        }

        return userPosts;
    }

    function userLikes(
        uint256 postId,
        address user
    ) external view returns (bool) {
        return _userLikes[postId][user];
    }
}
