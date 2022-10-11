pragma solidity ^0.8.0;

import "./utils/Ownable.sol";
import "./SmartZKCPJudge.sol";

/// @title 
/// @author
contract SmartZKCPFactory is Ownable {

    event ExchangeCreate(address indexed judge, address indexed seller,  address indexed buyer, uint256 price, uint256 timestamp);

    mapping(address => mapping(address => mapping(uint256 => address))) public getJudges;
    address[] judges;

    /// @notice We recommend buyer to create the exchange
    function createExchange(address seller, uint256 price) external returns (address judge) {
        require(seller != address(0), 'SmartZKCP: seller is zero address');
        address buyer = msg.sender; // msg.sender is the buyer
        uint256 timestamp = block.timestamp;
        bytes memory bytecode = type(SmartZKCPJudge).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(seller, buyer, price));
        assembly {
            judge := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        ISmartZKCPJudge(judge).initialize(seller, buyer, price);
        getJudges[seller][buyer][timestamp] = judge;
        getJudges[buyer][seller][timestamp] = judge;
        judges.push(judge);
        
        emit ExchangeCreate(judge, seller, buyer, price, timestamp);
    }

    function judgesLength() external view returns (uint) {
        return judges.length;
    }

}
