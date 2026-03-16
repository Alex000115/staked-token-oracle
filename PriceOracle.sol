// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title PriceOracle
 * @dev A secure, heartbeat-driven oracle for LST price feeds.
 */
contract PriceOracle is Ownable {
    struct PriceData {
        uint256 price;
        uint256 lastUpdated;
    }

    PriceData public currentPrice;
    uint256 public constant HEARTBEAT = 1 hours;
    uint256 public constant DEVIATION_THRESHOLD = 500; // 5% in basis points

    mapping(address => bool) public isReporter;

    event PriceUpdated(uint256 indexed newPrice, uint256 timestamp);
    event ReporterStatusChanged(address indexed reporter, bool status);

    modifier onlyReporter() {
        require(isReporter[msg.sender] || msg.sender == owner(), "Not authorized");
        _;
    }

    constructor(uint256 _initialPrice) Ownable(msg.sender) {
        currentPrice = PriceData({
            price: _initialPrice,
            lastUpdated: block.timestamp
        });
        emit PriceUpdated(_initialPrice, block.timestamp);
    }

    /**
     * @notice Updates the price if the deviation or heartbeat threshold is met.
     */
    function updatePrice(uint256 _newPrice) external onlyReporter {
        require(_newPrice > 0, "Price cannot be zero");

        uint256 oldPrice = currentPrice.price;
        uint256 priceChange = _newPrice > oldPrice ? _newPrice - oldPrice : oldPrice - _newPrice;
        
        // Ensure the update is necessary (Deviation > 5% or Heartbeat > 1hr)
        bool significantChange = (priceChange * 10000) / oldPrice >= DEVIATION_THRESHOLD;
        bool heartbeatMet = block.timestamp >= currentPrice.lastUpdated + HEARTBEAT;

        require(significantChange || heartbeatMet, "Update not required");

        currentPrice = PriceData({
            price: _newPrice,
            lastUpdated: block.timestamp
        });

        emit PriceUpdated(_newPrice, block.timestamp);
    }

    /**
     * @notice Returns the latest price, ensuring it isn't stale.
     */
    function getLatestPrice() external view returns (uint256) {
        require(block.timestamp <= currentPrice.lastUpdated + (HEARTBEAT * 2), "Oracle data is stale");
        return currentPrice.price;
    }

    function setReporter(address _reporter, bool _status) external onlyOwner {
        isReporter[_reporter] = _status;
        emit ReporterStatusChanged(_reporter, _status);
    }
}
