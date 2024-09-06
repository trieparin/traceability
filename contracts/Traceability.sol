// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract Traceability {
    enum ROLE {
        MANUFACTURER,
        PACKAGER,
        DISTRIBUTOR,
        PHARMACY
    }

    struct Info {
        string company;
        ROLE role;
    }

    bytes32 product;
    mapping (address => Info) stakeholders;
    mapping (address => bytes32) serials;

    constructor(bytes32 _productHash, bytes32 _serialHash, string memory _company) {
        product = _productHash;
        stakeholders[msg.sender] = Info(_company, ROLE.MANUFACTURER);
        serials[msg.sender] = _serialHash;
    }
}