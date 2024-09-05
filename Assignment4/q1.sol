// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FindHash {
    function findHash(uint256 nonce) public pure returns (bytes32) {
        bytes32 hash = keccak256(abi.encodePacked(nonce));
        return hash;
    }

    function checkIfStartsWith00000(bytes32 hash) public pure returns (bool) {
        return uint256(hash) < 2**236; // This will ensure hash starts with a set of leading 0s
    }
}
