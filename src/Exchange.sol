// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
    // Mapping from token address to eth reserve
    mapping(address => uint256) public pools;

    // Mapping to track user liquidity contributions per token pair
    mapping(address => mapping(address => uint256)) public userLiquidity; // user -> tokenAddress -> liquidity

    constructor() ERC20("Exchange LP Token", "EXLPT") {}

    function getReserve(address tokenAddress) public view returns (uint256) {
        return ERC20(tokenAddress).balanceOf(address(this));
    }

    function addLiquidity(address tokenAddress, uint256 tokenAmount) external payable returns (uint256) {
        uint256 ethReserve = pools[tokenAddress];
        uint256 tokenReserve = getReserve(tokenAddress);

        ERC20 token = ERC20(tokenAddress);

        uint256 lpTokensToMint;

        if (tokenReserve == 0 && ethReserve == 0) {
            require(msg.value > 0 && tokenAmount > 0, "Initial liquidity cannot be 0");

            // Transfer the token from the user to the exchange
            token.transferFrom(msg.sender, address(this), tokenAmount);

            // lpTokensToMint = ethReserveBalance = msg.value
            lpTokensToMint = msg.value;
        }

        else {
            // If the reserve is not empty
            uint256 minTokenAmountRequired = (msg.value * tokenReserve) / ethReserve;

            require(tokenAmount >= minTokenAmountRequired, "Insufficient amount of tokens provided");

            token.approve(msg.sender, minTokenAmountRequired);

            require(token.transferFrom(msg.sender, address(this), minTokenAmountRequired), "Failed to transfer tokens");

            // Calculate the amount of LP tokens to be minted
            lpTokensToMint = (totalSupply() * msg.value) / ethReserve;

        }

        // Mint LP tokens to the user
        _mint(msg.sender, lpTokensToMint);

        // Update eth reserve
        pools[tokenAddress] += msg.value;

        // Track user's liquidity contribution for the token pair
        userLiquidity[msg.sender][tokenAddress] += lpTokensToMint;

        return lpTokensToMint;
    }

    // getOutputAmountFromSwap calculates the amount of output token to be received based on xy = (x + dx)(y - dy)
    function getOutputAmountFromSwap(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) public pure returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0, "Reserve must be greater than 0");

        uint256 inputAmountWithFee = inputAmount * 99; // Fee is 1%

        uint256 numerator = inputAmountWithFee * outputReserve;
        uint256 denominator = (inputReserve * 100) + inputAmountWithFee;

        return numerator / denominator;
    }

    function ethToTokenSwap(address tokenAddress, uint256 minTokensToReceive) public payable {
        uint256 ethReserve = pools[tokenAddress];
        uint256 tokenReserve = getReserve(tokenAddress);

        uint256 tokensToReceive = getOutputAmountFromSwap(
            msg.value,
            ethReserve,
            tokenReserve
        );

        require(tokensToReceive >= minTokensToReceive, "Tokens received are less than minimum tokens expected");

        ERC20(tokenAddress).transfer(msg.sender, tokensToReceive);

        pools[tokenAddress] += msg.value;
    }

    function tokenToEthSwap(address tokenAddress, uint256 tokensToSwap, uint256 minEthToReceive) public {
        uint256 tokenReserve = getReserve(tokenAddress);
        uint256 ethReserve = pools[tokenAddress];

        ERC20 token = ERC20(tokenAddress);

        uint256 ethToReceive = getOutputAmountFromSwap(
            tokensToSwap,
            tokenReserve,
            ethReserve
        );

        require(ethToReceive >= minEthToReceive, "ETH received is less than minimum ETH expected");

        require(token.transferFrom(msg.sender, address(this), tokensToSwap), "Failed to transfer tokens");

        payable(msg.sender).transfer(ethToReceive);

        pools[tokenAddress] -= ethToReceive;
    }

    function getLPAmountForToken(address tokenAddress) public view returns (uint256) {
        return userLiquidity[msg.sender][tokenAddress];
    }

    function removeLiquidity(address tokenAddress, uint256 lpTokenAmount) public returns (uint256, uint256) {
        require(getLPAmountForToken(tokenAddress) >= lpTokenAmount && lpTokenAmount > 0, "Insufficient liquidity provided");

        uint256 ethReserve = pools[tokenAddress];
        uint256 lpTokenTotalSupply = totalSupply();

        uint256 ethToReturn = (lpTokenAmount * ethReserve) / lpTokenTotalSupply;
        uint256 tokenToReturn = (lpTokenAmount * getReserve(tokenAddress)) / lpTokenTotalSupply;

        // Burn LP tokens from user
        _burn(msg.sender, lpTokenAmount);

        ERC20(tokenAddress).transfer(msg.sender, tokenToReturn);
        payable(msg.sender).transfer(ethToReturn);

        // Update user's liquidity balance
        userLiquidity[msg.sender][tokenAddress] -= lpTokenAmount;

        return (ethToReturn, tokenToReturn);
    }
}