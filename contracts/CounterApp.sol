pragma solidity ^0.4.24;

import "@aragon/os/contracts/apps/AragonApp.sol";
import "@aragon/os/contracts/lib/math/SafeMath.sol";

contract CounterApp is AragonApp {
    using SafeMath for uint256;

    /// Events
    event Increment(address indexed entity, uint256 step);
    event Decrement(address indexed entity, uint256 step);

    /// State
    uint256 public value;

    /// ACL
    bytes32 constant public INCREMENT_ROLE = keccak256("INCREMENT_ROLE");
    bytes32 constant public DECREMENT_ROLE = keccak256("DECREMENT_ROLE");

    function initialize() onlyInit public {
        initialized();
    }

    /**
     * @notice Increment the counter by `step`
     * @param step Amount to increment by
     */
    function increment(uint256 step) auth(INCREMENT_ROLE) external {
        value = value.add(step);
        emit Increment(msg.sender, step);
    }

    /**
     * @notice Decrement the counter by `step`
     * @param step Amount to decrement by
     */
    function decrement(uint256 step) auth(DECREMENT_ROLE) external {
        value = value.sub(step);
        emit Decrement(msg.sender, step);
    }
}
