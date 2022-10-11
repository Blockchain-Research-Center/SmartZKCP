pragma solidity ^0.8.0;

/// @title 
/// @author
interface ISmartZKCPJudge {

    function initialize(address _seller, address _buyer, uint256 _price) external;

    function init() payable external;

    function verify(bytes calldata proof, bytes32 k) external;

    function refund() external;

}
