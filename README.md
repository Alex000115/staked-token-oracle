# Staked Token Oracle

An expert-level decentralized oracle system designed to provide accurate price feeds for Liquid Staking Tokens (LSTs) and other high-volatility crypto assets. This repository focuses on security, gas efficiency, and manipulation resistance.

### Features
* **Heartbeat Mechanism**: Updates are only required if the price deviates beyond a certain percentage or a specific time has elapsed.
* **Circuit Breakers**: Automatically pauses the feed if price fluctuations exceed safe thresholds (e.g., flash loan protection).
* **Multi-Source Aggregation**: Capability to fetch and average data from multiple DEX pools or off-chain reporters.
* **Manipulation Resistance**: Uses Time-Weighted Average Price (TWAP) logic to mitigate spot price manipulation.

### How to Use
1. Deploy `PriceOracle.sol` with the address of the asset pair and the desired heartbeat interval.
2. Authorized "Reporters" call `updatePrice` to push new data to the contract.
3. Consumers (Lending protocols, DEXs) call `getLatestPrice` to receive a verified, fresh price.
