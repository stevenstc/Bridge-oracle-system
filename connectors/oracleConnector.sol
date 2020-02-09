pragma solidity ^0.5.8;


contract Oracle {
    
    event Log1(address sender, bytes32 cid, uint timestamp, string _datasource, string _arg, uint feelimit, byte proofType);
    event Log2(address sender, bytes32 cid, uint timestamp, string _datasource, string _arg1, string _arg2, uint feelimit, byte proofType);
    event logN(address sender, bytes32 cid, uint timestamp, string _datasource, bytes args, uint feelimit, byte proofType);

    mapping(address => byte) internal addr_proofType;

    mapping(address => uint) internal reqc;

    mapping(address => byte) public cbAddresses;    
    uint public basePrice;
    uint256 public maxBandWidthPrice;
    uint256 public defaultFeeLimit;


    address private owner;

    constructor() internal {
    	owner = msg.sender;
    }


    modifier onlyAdmin() {
    	require(owner == msg.sender);
    	_;
    }

    function setMaxBandWidthPrice(uint256 new_maxBandWidthPrice) external onlyAdmin {
        maxBandWidthPrice = new_maxBandWidthPrice;
    }

    function setDefaultFeeLimit(uint256 new_defaultFeeLimit) external onlyAdmin {
        defaultFeeLimit = new_defaultFeeLimit;
    }

    function addCbAddress(address newCbAddress, byte addressType) external onlyAdmin{
        addCbAddress(newCbAddress, addressType, hex'');
    }
    
    function addCbAddress(address newCbAddress, byte addressType, bytes memory proof) public onlyAdmin{
        cbAddresses[newCbAddress] = addressType;
    }

    function removeCbAddress(address newCbAddress) external onlyAdmin {
        delete cbAddresses[newCbAddress];
    }

    function addDSource(string calldata dsname, uint multiplier) external
    {
        addDSource(dsname, 0x00, multiplier);
    }

    function addDSource(string memory dsname, byte proofType, uint multiplier) public onlyAdmin
    {
        
    }
    
    function cbAddress() internal view returns(address _cbAddress) {
        if(cbAddresses[tx.origin] != 0)
            _cbAddress = tx.origin;
    }

    function setBasePrice(uint new_baseprice) external onlyAdmin {
        basePrice = new_baseprice;
    }

    function setBasePrice(uint new_baseprice, bytes calldata proofID) external onlyAdmin {
        basePrice = new_baseprice;
    }

    function getPrice(string memory _datasource) public returns(uint _dsPrice) {
        return getPrice(_datasource, msg.sender);
    }

    function getPrice(string memory _datasource, uint _feeLimit) public returns(uint _dsprice) {
        return getPrice(_datasource, _feeLimit, msg.sender);
    }

    function getPrice(string memory _datasource, address _addr) private returns(uint _dsprice) {
        return getPrice(_datasource, defaultFeeLimit, _addr);
    }

    function getPrice(string memory _datasource, uint _feeLimit, address _addr) private returns(uint _dsprice) {
        require(_feelimit <= 1000000000);
        _dsprice = price[sha256(_datasource, add_proofType[_addr])];
        _dsprice += maxBandWidthPrice + _feeLimit;
        return _dsprice;
    }

    function costs(string memory datasource, uint feelimit) private returns(uint price) {
        price = getPrice(datasource, feelimit, msg.sender);

        if (msg.value >= price) {
            uint diff = msg.value - price;
            if (diff > 0) {
                if (!msg.sender.transfer(diff)) {
                    revert();
                }
            }
        } else revert();
    }

    function setProofType(byte _proofType) external {
    	addr_proofType[msg.sender] = _proofType;
    }

	function withdrawFunds(address _addr) external onlyAdmin {
		_addr.send(this.balance);
	}

	function query(string calldata _datasource, string calldata _arg) external payable returns(bytes32 _id) {
		//set feeLimit tron blockchain
	 	return query1(0, _datasource, _arg, defaultFeeLimit);
    }

    function query(uint _timestamp, string calldata _datasource, string calldata _arg) payable external returns(bytes32 _id) {
    	return query1(_timestamp, _datasource, _arg, defaultFeeLimit);
    }

    function query_withFeeLimit(uint _timestamp, string calldata _datasource, string calldata _arg, uint _feelimit) external payable returns(bytes32 _id) {
    	return query1(_timestamp, _datasource, _arg, _feelimit);
    }

    function query2(uint _timestamp, string calldata _datasource, string calldata _arg1, string calldata _arg2) external payable returns(bytes32 _id) {
    	return query2(_timestamp, _datasource, _arg1, _arg2, defaultFeeLimit);
    }

    function query2_withFeeLimit(uint _timestamp, string calldata _datasource, string calldata _arg1, string calldata _arg2, uint _feeLimit) external payable returns(bytes32 _id) {
    	return query2(_timestamp, _datasource, _arg1, _arg2, _feeLimit);
    }

    function queryN(string memory _datasource, bytes _args) external payable returns(bytes32 _id) {
        return queryN(0, _datasource, _args, defaultFeeLimit);
    }
    
    function queryN(uint _timestamp, string memory _datasource, bytes _args) external payable returns(bytes32 _id) {
        return queryN(_timestamp, _datasource, _args, defaultFeeLimit);
    }

    function query1(uint _timestamp, string memory _datasource, string memory _arg, uint _feeLimit) public payable returns(bytes32 _id) {
        costs(_datasource, _feeLimit);
        bytes memory cl = bytes(abi.encodePacked(msg.sender));
        bytes memory co = bytes(abi.encodePacked(this));
        bytes memory n = toBytes(reqc[msg.sender]);
        bytes memory concat = abi.encodePacked(co, cl, n);
        _id = sha256(concat);
    	reqc[msg.sender]++;
	  	emit Log1(msg.sender, _id, _timestamp, _datasource, _arg, _feeLimit, addr_proofType[msg.sender]);
	  	return _id;
    }

    function query2(uint _timestamp, string memory _datasource, string memory _arg1, string memory _arg2, uint _feeLimit) public payable returns(bytes32 _id) {
    	costs(_datasource, _feeLimit);
        bytes memory cl = bytes(abi.encodePacked(msg.sender));
        bytes memory co = bytes(abi.encodePacked(this));
        bytes memory n = toBytes(reqc[msg.sender]);
        bytes memory concat = abi.encodePacked(co, cl, n);
        _id = sha256(concat);
        reqc[msg.sender]++;
	  	emit Log2(msg.sender, _id, _timestamp, _datasource, _arg1, _arg2, _feeLimit, addr_proofType[msg.sender]);
	  	return _id;
    }

    function queryN(uint _timestamp, string memory _datasource, bytes _args, uint _feelimit) public payable returns(bytes32 _id) {
        costs(_datasource, _feeLimit);
        bytes memory cl = bytes(abi.encodePacked(msg.sender));
        bytes memory co = bytes(abi.encodePacked(this));
        bytes memory n = toBytes(reqc[msg.sender]);
        bytes memory concat = abi.encodePacked(co, cl, n);
        _id = sha256(concat);
        reqc[msg.sender]++;
        emit logN(msg.sender, _id, _timestamp, _datasource, _args, _feelimit, addr_proofType[msg.sender]);
        return _id;
    }

    

    function toBytes(uint256 x) public returns (bytes memory b) {
        b = new bytes(32);
        assembly {
        mstore(add(b, 32), x) 
    }
}



}