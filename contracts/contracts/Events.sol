pragma solidity ^0.8.0;

/// @title 
/// @author
contract Events {

    event Initialized(uint256 t0);

    event VerifySuccess(uint256 t1, bytes proof, bytes32 k);

    event VerifyFail(uint256 t1);

    event Refunded(uint256 t2);
}
