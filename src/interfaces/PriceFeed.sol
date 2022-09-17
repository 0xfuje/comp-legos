// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface PriceFeed {
  function getUnderlyingPrice(address cToken) external view returns (uint);
}