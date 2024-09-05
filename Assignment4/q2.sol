// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FindHashWithPrefix {
    function findHash(string memory input) public pure returns (bytes32) {
        bytes32 hash = keccak256(abi.encodePacked(input));
        return hash;
    }

    function checkIfStartsWith00000(bytes32 hash) public pure returns (bool) {
        return uint256(hash) < 2**236; // This ensures the hash starts with a number of leading 0s
    }
    
    function findPrefixHash(string memory prefix, uint256 nonce) public pure returns (bytes32) {
        string memory combined = string(abi.encodePacked(prefix, uint2str(nonce)));
        return keccak256(abi.encodePacked(combined));
    }
    
    function uint2str(uint _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
