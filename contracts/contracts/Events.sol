pragma solidity ^0.8.0;

/// @title 
/// @author
abstract contract Events {

    event ExchangeInit(uint256 t0);

    event ExchangeVerifySuccess(uint256 t1, bytes proof, bytes32 k);

    event ExchangeVerifyFail(uint256 t1);

    event ExchangeRefund(uint256 t2);
}
