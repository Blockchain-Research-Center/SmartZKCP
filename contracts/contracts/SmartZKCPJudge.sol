// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./ISmartZKCPJudge.sol";
import "./Config.sol";
import "./ReentrancyGuard.sol";
import "./Groth16Core.sol";
import "./Events.sol";

contract SmartZKCPJudge is ISmartZKCPJudge, ReentrancyGuard, Config, Events {

    address public factory; // factory

    // @notice variables set by the factory
    address public seller; // seller
    address public buyer; // buyer
    uint256 public price; // price

    // @notice timestamps
    uint256 public t0;
    uint256 public t1;
    uint256 public t2;

    ExchangeStatus public status; // status of the exchange

    /// @notice Contract statuses
    enum ExchangeStatus {
        uninitialized,
        initialized,
        finished,
        expired
    }

    /// @notice
    /// @param
    constructor(address _seller, address _buyer, uint256 _price) {
        require(_seller != address(0), "SmartZKCP: invalid address.");
        require(_buyer != address(0), "SmartZKCP: invalid address.");

        factory = msg.sender;
        buyer = _buyer;
        seller = _seller;
        price = _price;

        // initialize contract status
        status = ExchangeStatus.uninitialized;
    }

    /// @notice Buyer initialize the contract
    function initialize() payable nonReentrant external {
        require(msg.sender == buyer, "SmartZKCP: invalid initializer.");
        require(status == ExchangeStatus.uninitialized, "SmartZKCP: invalid contract status.");
        require(msg.value >= price, "SmartZKCP: payment not enough.");

        // set initialize timestamp
        t0 = block.timestamp;
        // update contract state
        status = ExchangeStatus.initialized;

        emit Initialized(t0);
    }

    /// @notice
    function verify(bytes calldata proof, bytes32 k) nonReentrant external {
        require(msg.sender == seller, "SmartZKCP: invalid verify invoker.");
        require(status == ExchangeStatus.initialized, "SmartZKCP: invalid contract status.");
        t1 = block.timestamp;
        require(t1 <= t0 + LIMIT_TIME_TAU, "SmartZKCP: invalid verify because of time expired.");

        bool success = Groth16Core.verify();
        if(success) {
            // transfer payment to seller
            payable(seller).transfer(price);
            // update contract state
            status = ExchangeStatus.finished;

            emit VerifySuccess(t1, proof, k);
            return;
        }

        emit VerifyFail(t1);
    }

    /// @notice Contract refunds buyer if the exchange expired without valid proof
    function refund() nonReentrant external {
        require(msg.sender == buyer, "SmartZKCP: invalid refund invoker.");
        require(status == ExchangeStatus.initialized, "SmartZKCP: invalid contract status.");
        t2 = block.timestamp;
        require(t2 > t0 + LIMIT_TIME_TAU, "SmartZKCP: invalid refund operation.");
        // refund buyer
        payable(buyer).transfer(price);
        // update contract state
        status = ExchangeStatus.expired;

        emit Refunded(t2);
    }
}
