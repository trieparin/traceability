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
    mapping (address => bytes32) serials;
    mapping (address => address) parties;
    mapping (address => Info) stakeholders;
    event Signed(address acceptor, address indexed requester);

    constructor(bytes32 _product, bytes32 _serial, string memory _company) {
        product = _product;
        serials[msg.sender] = _serial;
        stakeholders[msg.sender] = Info(_company, true, ROLE.MANUFACTURER);
    }

    modifier checkProduct(bytes32 _product) {
        require(_product == product, "Wrong Product");
        _;
    }

    modifier checkSerial(bytes32 _serial) {
        require(_serial == serials[msg.sender], "Wrong Serials");
        _;
    }

    modifier signAccept(address _requester) {
        require(parties[msg.sender] == _requester, "Unathorized");
        emit Signed(msg.sender, _requester);
        _;
    }

    function signRequest(
        bytes32 _product, 
        bytes32 _serial, 
        bytes32 _shipment, 
        address _acceptor
    ) external checkProduct(_product) checkSerial(_serial) {
        require(stakeholders[msg.sender].exist, "Unathorized");
        require(msg.sender != parties[_acceptor], "Unathorized");
        require(msg.sender != _acceptor, "Unathorized");
        serials[_acceptor] = _shipment;
        parties[_acceptor] = msg.sender;
    }
    
    function confirmDistribute(
        bytes32 _product, 
        bytes32 _serial, 
        address _requester, 
        string calldata _company, 
        ROLE _role
    ) external checkProduct(_product) checkSerial(_serial) signAccept(_requester) {
        require(stakeholders[msg.sender].role != ROLE.PHARMACY, "Unathorized");
        require(_role != ROLE.MANUFACTURER, "Unathorized");
        stakeholders[msg.sender] = Info(_company, true, _role);
    }

    function soldDrug(
        bytes32 _product, 
        bytes32 _serial, 
        bytes32 _stock, 
        address _customer
    ) external checkProduct(_product) checkSerial(_serial) {
        require(stakeholders[msg.sender].role == ROLE.PHARMACY, "Unathorized");
        serials[msg.sender] = _stock;
        parties[_customer] = msg.sender;
    }
}