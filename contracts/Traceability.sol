// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract Traceability {
    enum ROLE {
        MANUFACTURER,
        DISTRIBUTOR,
        PHARMACY
    }

    struct Stakeholder {
        string company;
        bool exist;
        ROLE role;
    }

    bytes32 product;
    bytes32 serialize;
    mapping (address => Stakeholder) stakeholders;
    mapping (address => bytes32) distributes;
    mapping (address => address) parties;
    event Signed(address acceptor, address indexed requester);

    constructor(
        bytes32 _product, 
        bytes32 _serialize, 
        string memory _manufacturer
    ) {
        product = _product;
        serialize = _serialize;
        distributes[msg.sender] = _serialize;
        stakeholders[msg.sender] = Stakeholder(_manufacturer, true, ROLE.MANUFACTURER);
    }

    modifier validate(bytes32 _product, bytes32 _serialize, bytes32 _distribute) {
        require(_product == product, "Error: Wrong Product");
        require(_serialize == serialize, "Error: Wrong Serialize");
        require(_distribute == distributes[msg.sender], "Error: Wrong Distribution");
        _;
    }

    modifier auth(address _acceptor) {
        require(stakeholders[msg.sender].exist, "Error: Unathorized");
        require(msg.sender != _acceptor, "Error: Unathorized");
        _;
    }

    modifier sign(address _requester) {
        require(parties[msg.sender] == _requester, "Error: Unathorized");
        emit Signed(msg.sender, _requester);
        _;
    }

    function shipmentRequest(
        bytes32 _product, 
        bytes32 _serialize, 
        bytes32 _distribute, 
        bytes32 _shipment, 
        address _acceptor,
        string calldata _company,
        ROLE _role
    ) external validate(_product, _serialize, _distribute) auth(_acceptor) {
        require(stakeholders[msg.sender].role != ROLE.PHARMACY, "Error: Unathorized");
        require(msg.sender != parties[_acceptor], "Error: Unathorized");
        require(_role != ROLE.MANUFACTURER, "Error: Unathorized");
        distributes[_acceptor] = _shipment;
        parties[_acceptor] = msg.sender;
        stakeholders[_acceptor] = Stakeholder(_company, false, _role);
    }
    
    function shipmentConfirm(
        bytes32 _product, 
        bytes32 _serialize, 
        bytes32 _distribute, 
        address _requester
    ) external validate(_product, _serialize, _distribute) sign(_requester) {
        stakeholders[msg.sender].exist = true;
    }

    function sellDrug(
        bytes32 _product, 
        bytes32 _serialize, 
        bytes32 _stock, 
        bytes32 _remain, 
        bytes32 _sold, 
        address _patient
    ) external validate(_product, _serialize, _stock) auth(_patient) {
        require(stakeholders[msg.sender].role == ROLE.PHARMACY, "Error: Unathorized");
        distributes[msg.sender] = _remain;
        distributes[_patient] = _sold;
        parties[_patient] = msg.sender;
    }
}