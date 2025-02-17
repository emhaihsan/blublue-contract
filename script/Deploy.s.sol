// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/BBToken.sol";
import "../src/BluBlueNFT.sol";
import "../src/BluBluePost.sol";

contract DeployScript is Script {
    function run() external {
        // Load private key from .env
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying contracts with address:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy BluBluePost first
        console.log("1. Deploying BluBluePost...");
        BluBluePost post = new BluBluePost();
        console.log("   BluBluePost deployed to:", address(post));

        // Deploy BBToken with post contract address
        console.log("\n2. Deploying BBToken...");
        BBToken token = new BBToken(address(post));
        console.log("   BBToken deployed to:", address(token));

        // Deploy BluBlueNFT with post contract address
        console.log("\n3. Deploying BluBlueNFT...");
        BluBlueNFT nft = new BluBlueNFT(address(post));
        console.log("   BluBlueNFT deployed to:", address(nft));

        // Set token and NFT addresses in post contract
        console.log("\n4. Setting up contract references...");
        post.setTokenContract(address(token));
        post.setNFTContract(address(nft));
        console.log("   Token contract set in BluBluePost");
        console.log("   NFT contract set in BluBluePost");

        vm.stopBroadcast();

        // Verify deployments
        console.log("\n5. Verifying deployments...");

        // Verify BluBluePost
        require(post.owner() == deployer, "BluBluePost: Invalid owner");
        require(
            post.tokenContract() == address(token),
            "BluBluePost: Invalid token contract"
        );
        require(
            post.nftContract() == address(nft),
            "BluBluePost: Invalid NFT contract"
        );
        console.log("   BluBluePost verified");

        // Verify BBToken
        require(token.owner() == deployer, "BBToken: Invalid owner");
        require(
            address(token.postContract()) == address(post),
            "BBToken: Invalid post contract"
        );
        console.log("   BBToken verified");

        // Verify BluBlueNFT
        require(nft.owner() == deployer, "BluBlueNFT: Invalid owner");
        require(
            address(nft.postContract()) == address(post),
            "BluBlueNFT: Invalid post contract"
        );
        console.log("   BluBlueNFT verified");

        console.log("\n=== Deployment Summary ===");
        console.log("BluBluePost:", address(post));
        console.log("BBToken:", address(token));
        console.log("BluBlueNFT:", address(nft));
        console.log("Network:", block.chainid);
        console.log("Deployer:", deployer);
    }
}
