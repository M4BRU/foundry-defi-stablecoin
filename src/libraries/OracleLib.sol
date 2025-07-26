// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @title OracleLib
 * @author Lucas MAbru-Colson
 * @notice Used to check the chainlinkl Oracle for stale data
 * if a price is stale, trhe function will revert and render the dscengine unusable,
 * we want dscengine to freeeze if prices become stale.
 * 
 * so if chainlink wertwork explodes, the moneyis locked in the protocol
 */

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library OracleLib{
    error OracleLib__StalePrice();

    uint256 private constant TIMEOUT = 3 hours; // 3*60*60 = 10800s
    function staleCheckLatestRoundData(AggregatorV3Interface priceFeed) public view returns(uint80, int256,uint256, uint256, uint80){
        
        (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    ) = priceFeed.latestRoundData();

    uint256 secondSince = block.timestamp - updatedAt;
    if(secondSince > TIMEOUT){
        revert OracleLib__StalePrice();
    }
    return(roundId, answer, startedAt, updatedAt, answeredInRound);
    }
}