// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract Traceability {
    enum ROLE {
        MANUFACTURER,
        DISTRIBUTOR,
        PHARMACY
    }

    struct Info {
        string company;
        bool exist;
        ROLE role;
    }

    bytes32 product;
    mapping (address => Info) stakeholders;
    mapping (address => bytes32) serials;
    mapping (address => address) signed;
    event Signed(address accepter, address indexed requester);

    constructor(bytes32 _productHash, bytes32 _serialHash, string memory _company) {
        product = _productHash;
        stakeholders[msg.sender] = Info(_company, true, ROLE.MANUFACTURER);
        serials[msg.sender] = _serialHash;
    }

    modifier signAccept(address _requester) {
        require(signed[msg.sender] == _requester, "Unathorized");
        emit Signed(msg.sender, _requester);
        _;
    }

    function signRequest(address _acceptor) internal {
        require(stakeholders[msg.sender].exist, "Unathorized");
        require(msg.sender != signed[_acceptor], "Unathorized");
        require(msg.sender != _acceptor, "Unathorized");
        signed[_acceptor] = msg.sender;
    }
    
    function checkProduct(bytes32 _product) external view returns (bool) {
        return _product == product;
    }

    modifier checkSerial(bytes32 _serial) {
        require(_serial == serials[msg.sender], "Wrong Serials");
        _;
    }

    function setNewSerial(bytes32 _serial, bytes32 _newSerial) external checkSerial(_serial) {
        serials[msg.sender] = _newSerial;
    }
}