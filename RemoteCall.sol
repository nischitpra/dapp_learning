// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract RemoteCall {
    address target = address(0x406AB5033423Dcb6391Ac9eEEad73294FA82Cfbc);

    function addItem(string memory item) public {
        (bool success, bytes memory res) = target.call(abi.encodeWithSignature("addItem(string)",item));
        if(!success) {
            require(false, "could not add item");
        }
    }

    function itemsSize() public returns(uint)  {
        (bool success, bytes memory res) = target.call(abi.encodeWithSignature("itemsSize()"));
        if(!success) {
            require(false, "could not add item");
        }
        return toUint256(res, 0);
    }

    function toUint256(bytes memory _bytes, uint _start) internal pure returns (uint) {
        require(_bytes.length >= (_start + 32), "Read out of bounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

}