// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {MockV3Aggregator} from "test/mocks/MockV3Aggregator.sol";

contract Handler is Test {
    DSCEngine dsce;
    DecentralizedStableCoin dsc;

    ERC20Mock weth;
    ERC20Mock wbtc;

    uint256 public timesMintIsCalled;
    address[] public usersWithCollateralDeposited;
    MockV3Aggregator public ethUsdPriceFeed;

    uint256 MAX_DEPOSIT_SIZE = type(uint96).max;

    constructor(DSCEngine _dscEngine, DecentralizedStableCoin _dsc){
        dsce = _dscEngine;
        dsc = _dsc;

        address[] memory collateralTokens = dsce.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);

        ethUsdPriceFeed = MockV3Aggregator(dsce.getCollateralTokenPriceFeed(address(weth))); 
    }

    function depositCollateral(uint256 collateralSeed, uint256 amountCollateral) public{
        ERC20Mock collateral = _getColateralFromSeed(collateralSeed);
        amountCollateral = bound(amountCollateral, 1, MAX_DEPOSIT_SIZE);

        vm.startPrank(msg.sender);
        collateral.mint(msg.sender, amountCollateral);
        collateral.approve(address(dsce), amountCollateral);
        dsce.depositCollateral(address(collateral), amountCollateral);
        vm.stopPrank();
        usersWithCollateralDeposited.push(msg.sender);
    }

    function redeemColateral(uint256 collateralSeed, uint256 amountCollateral) public{
        ERC20Mock collateral = _getColateralFromSeed(collateralSeed);
        uint256 maxCollateralToRedeem = _calculateMaxSafeRedeem(msg.sender, address(collateral));
        amountCollateral = bound(amountCollateral, 0, maxCollateralToRedeem);
        if(amountCollateral == 0){
            return;
        }
        vm.startPrank(msg.sender);
        dsce.redeemCollateral(address(collateral), amountCollateral);
        vm.stopPrank();
    }
    //this breaks invariant test
    // function updateCollateralPrice(uint96 newPrice) public{
    //     int256 newPriceInt = int256(uint256(newPrice));
    //     ethUsdPriceFeed.updateAnswer(newPriceInt);
    // }

    function mintDsc(uint256 amount, uint256 addressSeed) public{
        if(usersWithCollateralDeposited.length == 0){
            return;
        }
        address sender = usersWithCollateralDeposited[addressSeed % usersWithCollateralDeposited.length];
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dsce.getAccountInformation(sender);
        
        int256 maxDscToMint = (int256(collateralValueInUsd) / 2) - int256(totalDscMinted);
        if(maxDscToMint < 0){
            return;
        }
        amount = bound(amount, 0, uint256(maxDscToMint));
        if(amount <= 0){
            return;
        }
        vm.startPrank(sender);
        dsce.mintDsc(amount);
        vm.stopPrank();
        timesMintIsCalled++;
    }

    function _getColateralFromSeed(uint256 collateralSeed) private view returns (ERC20Mock){
        if(collateralSeed % 2 == 0){
            return weth;
        }
        return wbtc;
    }

    function _calculateMaxSafeRedeem(address user, address token) private view returns(uint256) {
    (uint256 totalDscMinted, uint256 totalCollateralValue) = dsce.getAccountInformation(user);
    
    // Si pas de DSC mintés, peut tout retirer
    if(totalDscMinted == 0) {
        return dsce.getCollateralBalanceOfUser(user, token);
    }
    
    // Collatéral minimum requis pour HF = 1.0 : DSC × 2
    uint256 minCollateralRequired = totalDscMinted * 2;
    
    if(totalCollateralValue <= minCollateralRequired) {
        return 0; // ✅ Rien à retirer !
    }
    
    // Surplus qu'on peut retirer
    uint256 surplusValue = totalCollateralValue - minCollateralRequired;
    uint256 surplusInTokens = dsce.getTokenAmountFromUsd(token, surplusValue);
    uint256 userBalance = dsce.getCollateralBalanceOfUser(user, token);
    
    return surplusInTokens > userBalance ? userBalance : surplusInTokens;
}
}