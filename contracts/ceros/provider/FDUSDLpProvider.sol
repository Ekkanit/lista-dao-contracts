// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IDao} from "../interfaces/IDao.sol";
import {ICertToken} from "../interfaces/ICertToken.sol";
import {BaseLpTokenProvider} from "./BaseLpTokenProvider.sol";


contract FDUSDLpProvider is BaseLpTokenProvider {

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _admin,
        address _proxy,
        address _pauser,
        address _collateralToken,
        address _ceToken,
        address _daoAddress
    ) public initializer {
        require(_admin != address(0), "admin is the zero address");
        require(_proxy != address(0), "proxy is the zero address");
        require(_pauser != address(0), "pauser is the zero address");
        require(_collateralToken != address(0), "collateralToken is the zero address");
        require(_ceToken != address(0), "ceToken is the zero address");
        require(_daoAddress != address(0), "daoAddress is the zero address");

        __Pausable_init();
        __ReentrancyGuard_init();
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(PROXY, _proxy);
        _grantRole(PAUSER, _pauser);

        ceToken = _ceToken;
        collateralToken = ICertToken(_collateralToken);
        dao = IDao(_daoAddress);

        IERC20(ceToken).approve(_daoAddress, type(uint256).max);
    }

    /**
    * DEPOSIT
    * deposit given amount of ceToken to provider
    * given amount collateral token will be mint to caller's address
    * @param _amount amount to deposit
    */
    function provide(uint256 _amount)
        external
        override
        whenNotPaused
        nonReentrant
        returns (uint256)
    {
        return _provide(_amount);
    }

    /**
    * deposit given amount of ceToken to provider
    * given amount collateral token will be mint to delegateTo
    * @param _amount amount to deposit
    * @param _delegateTo target address of collateral tokens
    */
    function provide(uint256 _amount, address _delegateTo)
        external
        override
        whenNotPaused
        nonReentrant
        returns (uint256)
    {
        return _provide(_amount, _delegateTo);
    }

    /**
    * delegate all collateral tokens to given address
    * @param _newDelegateTo new target address of collateral tokens
    */
    function delegateAllTo(address _newDelegateTo)
        external
        override
        whenNotPaused
        nonReentrant
    {
        _delegateAllTo(_newDelegateTo);
    }

    /**
     * RELEASE
     * withdraw given amount of ceToken to recipient address
     * given amount collateral token will be burned from caller's address
     *
     * @param _recipient recipient address
     * @param _amount amount to release
     */
    function release(address _recipient, uint256 _amount)
        external
        override
        whenNotPaused
        nonReentrant
        returns (uint256)
    {
        return _release(_recipient, _amount);
    }

    /**
     * DAO FUNCTIONALITY
     * transfer given amount of ceToken to recipient
     * called by AuctionProxy.buyFromAuction
     *
     * @param _recipient recipient address
     * @param _amount amount to liquidate
     */
    function liquidation(address _recipient, uint256 _amount)
        external
        override
        nonReentrant
        whenNotPaused
        onlyRole(PROXY)
    {
        _liquidation(_recipient, _amount);
    }

    /**
     * burn given amount of collateral token from account
     * called by AuctionProxy.startAuction
     *
     * @param _account collateral token holder
     * @param _amount amount to burn
     */
    function daoBurn(address _account, uint256 _amount)
        external
        override
        nonReentrant
        whenNotPaused
        onlyRole(PROXY)
    {
        _daoBurn(_account, _amount);
    }

    /**
     * mint given amount of collateral token to account
     * @param _account collateral token receiver
     * @param _amount amount to mint
     */
    function daoMint(address _account, uint256 _amount)
        external
        override
        nonReentrant
        whenNotPaused
        onlyRole(PROXY)
    {
        _daoMint(_account, _amount);
    }
}
