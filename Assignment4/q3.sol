// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FindNonceForTransactions {
    function findHash(string memory input, uint256 nonce) public pure returns (bytes32) {
        string memory combined = string(abi.encodePacked(input, uint2str(nonce)));
        return keccak256(abi.encodePacked(combined));
    }

    function checkIfStartsWith00000(bytes32 hash) public pure returns (bool) {
        return uint256(hash) < 2**236; // To simulate starting with "00000"
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
