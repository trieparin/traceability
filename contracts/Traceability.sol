// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

contract Traceability {
    enum ROLE {
        MANUFACTURER,
        DISTRIBUTOR,
        PHARMACY
    }

    struct Stakeholder {
        bytes32 catalog;
        bool exist;
        ROLE role;
    }

    bytes32 product;
    bytes32 serialize;
    mapping (address => Stakeholder) stakeholders;
    mapping (address => mapping (address => bytes32)) distributes;
    mapping (address => address) relations;
    event Signed(address acceptor, address indexed requester);

    constructor(
        bytes32 _product, 
        bytes32 _serialize, 
        bytes32 _catalog
    ) {
        product = _product;
        serialize = _serialize;
        stakeholders[msg.sender] = Stakeholder(_catalog, true, ROLE.MANUFACTURER);
    }

    modifier validate(bytes32 _product, bytes32 _serialize, bytes32 _catalog) {
        require(product == _product, "Error: Wrong Product");
        require(serialize == _serialize, "Error: Wrong Serialize");
        require(stakeholders[msg.sender].catalog == _catalog, "Error: Wrong Catalog");
        _;
    }

    modifier auth(address _acceptor) {
        require(stakeholders[msg.sender].exist, "Error: Unathorized");
        require(msg.sender != _acceptor, "Error: Not Allow");
        _;
    }

    modifier sign(address _requester) {
        require(relations[msg.sender] == _requester, "Error: Unathorized");
        emit Signed(msg.sender, _requester);
        _;
    }

    function shipmentRequest(
        bytes32 _product, 
        bytes32 _serialize, 
        bytes32 _catalog, 
        bytes32 _update, 
        bytes32 _shipment, 
        address _acceptor, 
        ROLE _role
    ) external validate(_product, _serialize, _catalog) auth(_acceptor) {
        require(stakeholders[msg.sender].role != ROLE.PHARMACY, "Error: Unathorized");
        require(relations[_acceptor] != msg.sender, "Error: Not Allow");
        require(_role != ROLE.MANUFACTURER, "Error: Not Allow");
        stakeholders[msg.sender].catalog = _update;
        stakeholders[_acceptor] = Stakeholder(_shipment, false, _role);
        relations[_acceptor] = msg.sender;
    }
    
    function shipmentConfirm(
        bytes32 _product, 
        bytes32 _serialize, 
        bytes32 _catalog, 
        bytes32 _distribute, 
        address _requester
    ) external validate(_product, _serialize, _catalog) sign(_requester) {
        distributes[_requester][msg.sender] = _distribute;
        stakeholders[msg.sender].exist = true;
    }

    function sellDrug(
        bytes32 _product, 
        bytes32 _serialize, 
        bytes32 _catalog, 
        bytes32 _update, 
        bytes32 _drug,
        address _patient
    ) external validate(_product, _serialize, _catalog) auth(_patient) {
        require(stakeholders[msg.sender].role == ROLE.PHARMACY, "Error: Unathorized");
        stakeholders[msg.sender].catalog = _update;
        distributes[msg.sender][_patient] = _drug;
    }

    function checkAuth(address _stakeholder) external view returns (ROLE) {
        require(relations[msg.sender] == _stakeholder, "Error: Unathorized");
        return stakeholders[msg.sender].role;
    }

    function checkInfo(bytes32 _product, bytes32 _serialize) external view returns (bool) {
        require(product == _product, "Error: Wrong Product");
        require(serialize == _serialize, "Error: Wrong Serialize");
        return  true;
    }

    function checkDistribute(
        bytes32 _distribute, 
        address _sender, 
        address _receiver
    ) external view returns (bool) {
        require(distributes[_sender][_receiver] == _distribute, "Error: Wrong Distribution");
        return true;
    }

    function checkDrug(
        bytes32 _drug, 
        address _pharmacy
    ) external view returns (bool) {
        require(distributes[_pharmacy][msg.sender] == _drug, "Error: Wrong Drug");
        return true;
    }
}
