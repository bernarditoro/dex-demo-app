# Exchange Contract (Liquidity Pool and Swap)

This demo Solidity smart contract implements a decentralized exchange (DEX) that supports multiple liquidity pools (ETH/token pairs), allows users to add and remove liquidity, and facilitates token swaps between ETH and tokens. The contract manages ETH reserves, LP tokens, and multiple token pairs, while minting and burning LP tokens based on user liquidity contributions.

## Overview

The contract is based on the principles of automated market makers (AMMs) and supports multiple token/ETH liquidity pools. It allows users to:
- Add liquidity to a specific token/ETH pool.
- Remove liquidity from a pool.
- Swap ETH for tokens and vice versa.
- Track reserves and liquidity contribution for each token pool.

This contract was adapted from the lesson on creating a DEX from [learnweb3.io](https://learnweb3.io), with modifications to support multiple liquidity pools and manage ETH reserves and LP tokens for each pool.

## Features

1. **Liquidity Pools**:
   - Users can add and remove liquidity to specific token/ETH pairs.
   - Liquidity providers receive LP tokens proportional to their contribution, representing their share of the pool.
   - LP tokens can be burned to redeem the user's proportional amount of ETH and tokens.

2. **Token Swaps**:
   - Users can swap ETH for a token or swap tokens for ETH.
   - Swap pricing is calculated based on a constant product formula `xy=k`, with a 1% fee applied to each swap.

3. **LP Tokens**:
   - LP tokens are minted when liquidity is added and burned when liquidity is removed.
   - LP token supply and user contributions are tracked per token pool.

4. **Multiple Pool Support**:
   - The contract supports multiple liquidity pools by managing reserves and LP tokens for different token addresses.
   - User contributions to each pool are tracked individually.

## Contract Details

### Constructor

```solidity
constructor() ERC20("Exchange LP Token", "EXLPT") {}
```

Initializes the contract by inheriting from OpenZeppelin’s ERC20 contract, minting the LP token with the name "Exchange LP Token" and symbol "EXLPT".

### Adding Liquidity

```solidity
function addLiquidity(address tokenAddress, uint256 tokenAmount) external payable returns (uint256)
```

This function allows users to add liquidity to a token/ETH pool:
- The user must send ETH with the transaction and provide an amount of the token.
- If this is the first liquidity added to the pool, it sets the initial token/ETH ratio.
- Additional liquidity is added proportionally to the existing reserves.
- LP tokens are minted and sent to the user, representing their share in the pool.
- The user's liquidity contribution is tracked in the `userLiquidity` mapping.

### Removing Liquidity

```solidity
function removeLiquidity(address tokenAddress, uint256 lpTokenAmount) public returns (uint256, uint256)
```

This function allows users to remove liquidity from a pool by burning their LP tokens:
- The contract calculates the proportional amount of ETH and tokens to return to the user.
- LP tokens are burned, and the reserves are adjusted accordingly.
- The user receives their ETH and tokens.

### Token/ETH Swaps

1. **ETH to Token Swap**:
   ```solidity
   function ethToTokenSwap(address tokenAddress, uint256 minTokensToReceive) public payable
   ```
   - The user sends ETH to swap for the token.
   - The function calculates the output amount using the constant product formula.
   - Tokens are transferred to the user, and the ETH reserve is updated.

2. **Token to ETH Swap**:
   ```solidity
   function tokenToEthSwap(address tokenAddress, uint256 tokensToSwap, uint256 minEthToReceive) public
   ```
   - The user sends tokens to swap for ETH.
   - The function calculates the output ETH amount and transfers ETH to the user.

### Other Functions

- `getReserve(address tokenAddress)`: Returns the token reserve for a specific token/ETH pair.
- `getOutputAmountFromSwap`: Calculates the amount of output tokens or ETH for a swap, accounting for the 1% fee.
- `getLPAmountForToken`: Returns the amount of LP tokens the user holds for a specific token pool.

## Mappings

- **pools**: `mapping(address => uint256) public pools`  
  Stores the ETH reserve for each token pair.

- **userLiquidity**: `mapping(address => mapping(address => uint256)) public userLiquidity`  
  Tracks how much liquidity each user has contributed to each token/ETH pair.


## Installation and Testing

### Prerequisites
- Solidity version `^0.8.25`.
- OpenZeppelin’s ERC20 library is used.

### Remix Setup
1. Copy the code into Remix IDE.
2. Import the OpenZeppelin ERC20 contract.
3. Deploy the contract using the `Injected Web3` environment in Remix.
4. You can interact with the contract to add/remove liquidity, perform swaps, and track reserves.

## License

This project is licensed under the MIT License.