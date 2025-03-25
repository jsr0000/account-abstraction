# Account Abstraction Implementation

This project demonstrates the implementation of Account Abstraction (AA) on both Ethereum and zkSync networks. Account Abstraction is a key feature of ERC-4337 that allows for smart contract wallets with programmable logic, enabling features like social recovery, transaction batching, and custom authentication methods.

## Overview

The project includes implementations for:
- Basic Account Abstraction on Ethereum
- Basic Account Abstraction on zkSync
- Deployment scripts and transaction testing
- User Operation (UserOp) handling and processing

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Solidity ^0.8.0
- Node.js (for testing and deployment scripts)

## Project Structure

```
├── src/
│   ├── ethereum/     # Ethereum AA implementation
│   └── zksync/       # zkSync AA implementation
├── test/             # Test files
├── script/           # Deployment and interaction scripts
└── lib/              # Dependencies
```

## Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/account-abstraction.git
cd account-abstraction
```

2. Install dependencies:
```bash
forge install
```

3. Build the project:
```bash
forge build
```

## Usage

### Testing

Run the test suite:
```bash
forge test
```

### Deployment

Deploy to Ethereum:
```bash
forge script script/DeployEthereum.s.sol --rpc-url <your-rpc-url> --broadcast
```

Deploy to zkSync:
```bash
forge script script/DeployZkSync.s.sol --rpc-url <your-rpc-url> --broadcast
```

## Features

- Smart contract wallet implementation
- EntryPoint contract for handling UserOps
- Paymaster integration support
- Social recovery capabilities
- Transaction batching support

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.


