pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;

import "./TrustedForwarder.sol";
import "./BaseRelayRecipient.sol";
import "./utils/GsnUtils.sol";

/**
 * batch forwarder support calling a method sendBatch in the forwarder itself.
 * NOTE: the "target" of the request should be the BatcherForwarder itself
 */
contract TrustedBatchForwarder is TrustedForwarder, BaseRelayRecipient {

    constructor() public {
        //needed for sendBatch
        trustedForwarder = address(this);
    }

    function sendBatch(address[] calldata targets, bytes[] calldata encodedFunctions) external {
        require(targets.length == encodedFunctions.length);
        address sender = _msgSender();
        for (uint i = 0; i < targets.length; i++) {
            // solhint-disable-next-line avoid-low-level-calls
            (bool success, bytes memory ret) = targets[i].call(abi.encodePacked(encodedFunctions[i], sender));
            // TODO: currently, relayed transaction does not report exception string. when it does, this
            // will propagate the inner call exception description
            require(success, GsnUtils.getError(ret));
        }
    }
}