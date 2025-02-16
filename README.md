# BluBlue Smart Contracts

Smart contract implementation for the BluBlue decentralized social media platform.

> 🏆 This project is part of the **Indonesia Hacker House Hackathon 2025**, organized by [Blockdev.id](https://blockdev.id) and [Manta Network](https://manta.network).

## Team Members

- **Pitchdeck & Documentation**:

  - Mr Punk (Duniaweb3)
  - Bayy
  - Eliska

- **Flowchart**:

  - Andika

- **Smart Contract**:

  - Ihsan

- **Backend**:

  - Saddam Machmud

- **Frontend & Wireframe**:
  - Bayy

## Smart Contracts Overview

### BluBluePost Contract

- Manages social media posts
- Handles like/unlike functionality
- Tracks post engagement metrics
- Links posts to NFTs

### BluBlueNFT Contract

- ERC-721 implementation for post NFTs
- Mints NFTs for popular posts
- Stores metadata and IPFS links
- Manages NFT transfers and ownership

### BBToken Contract

- ERC-20 implementation for platform tokens
- Rewards users for engagement
- Handles token distribution
- Implements token economics

## Tech Stack

- Solidity ^0.8.20
- Hardhat
- OpenZeppelin Contracts
- Ethers.js
- Chai (Testing)

## Getting Started

1. Install dependencies:

```bash
npm install
# or
yarn install
```

2. Set up environment variables:

```bash
cp .env.example .env
```

3. Run tests:

```bash
npx hardhat test
```

4. Deploy contracts:

```bash
npx hardhat run scripts/deploy.ts --network <network-name>
```

## Contract Architecture

```
contracts/
├── BluBluePost.sol      # Post management contract
├── BluBlueNFT.sol       # NFT implementation
├── BBToken.sol          # Token implementation
└── interfaces/          # Contract interfaces
```

## Development Roadmap

### Phase 1: Core Contracts

- Contract architecture design
- Basic post functionality
- Unit tests implementation
- Local deployment setup

### Phase 2: Token Integration

- BBToken implementation
- Token distribution logic
- Reward mechanisms
- Economic parameters

### Phase 3: NFT System

- NFT contract implementation
- Metadata management
- IPFS integration
- Minting rules

### Phase 4: Advanced Features

- Governance features
- Staking mechanisms
- Advanced reward systems
- Security enhancements

### Phase 5: Optimization

- Gas optimization
- Contract upgrades
- Multi-chain support
- Performance improvements

## Testing

Run the full test suite:

```bash
npx hardhat test
```

Generate coverage report:

```bash
npx hardhat coverage
```

## Security

- All contracts are thoroughly tested
- Follow Solidity best practices
- Implement access control
- Use OpenZeppelin secure contracts

## Contributing

Please read our [Contributing Guide](./CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.
