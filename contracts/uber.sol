pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

contract CabSharing {
    
    uint riderCount = 0;
    uint driverCount = 0;
    uint ridesCount = 0;
    uint currrides = 0;
    uint ownerBalance = 0;
    
    string occupied = "occupied";
    string available = "available";
    
    address owner;
    Rider[] riderList;
    Driver[] driverList;
    Ride[] ridesList;
    
    mapping(address => uint) addressRiderIDMapping;
    mapping(address => uint) addressDriverIDMapping;
    
    struct Rider{
        address riderAddr;
        uint riderID;
        uint wallet;
        uint rideID;
        string currentStatus;
        // uint Ratings;
        // uint RidesCompleted;
    }
    
    struct Driver {
        address driverAddr;
        uint driverID;
        uint perkm;
        uint rideID;
        uint wallet;
        string currentStatus;
        // uint Ridescompleted;
        // uint Ratings;
    }
    
    struct Ride {
        uint rideID;
        uint riderID;
        uint driverID;
        uint totalCost;
        uint[] bids;
        
        bool rideStart;
        bool rideFinish;
        bool riderPaymentPermission;
        bool paymentFinish;
        
        string source;
        string destination;
    }
    
    constructor() public payable{
       owner = msg.sender;
    }
    
    function registerDriver(uint _perkm) public payable returns(string) {
        require(addressDriverIDMapping[msg.sender] == 0,"You are already registered as Driver.");
        require(addressRiderIDMapping[msg.sender] == 0, "You are already registered as Rider.");
        
        driverCount++;
        driverList.push(Driver({
            driverID : driverCount,
            driverAddr : msg.sender,
            rideID : 0,
            perkm : _perkm,
            currentStatus : available,
            wallet : 0
        }));
        
        addressDriverIDMapping[msg.sender] = driverCount;
        return "You are registered as Driver.";
    }
    
    function registerRider() public payable returns(string) {
        require(addressDriverIDMapping[msg.sender] == 0,"You are already registered as Driver.");
        require(addressRiderIDMapping[msg.sender] == 0, "You are already registered as Rider.");
        
        riderCount++;
        riderList.push(Rider({
            riderID : riderCount,
            riderAddr : msg.sender,
            wallet : msg.value,
            rideID : 0,
            currentStatus : available
        }));
        
        addressRiderIDMapping[msg.sender] = riderCount;
        return "You are registered as Rider.";
    }
    
    function requestRide(string _dest, string _source) public returns(string , string) {
        require(addressDriverIDMapping[msg.sender] == 0,"Only Rider can request for a ride.");
        require(addressRiderIDMapping[msg.sender] != 0 , "You are not registered as Rider.");
        require(driverCount > 0 , "No Driver is available.");
        
        string temp1 = riderList[addressRiderIDMapping[msg.sender]-1].currentStatus;
        require(stringCompare(temp1, available) ,"You are not allowed to make multiple requests at a time.");
        
        uint[] temp;
        temp.length = 0;
        ridesCount++;
        currrides++;
        
        ridesList.push(Ride({
            source : _source,
            destination : _dest,
            riderID : addressRiderIDMapping[msg.sender],
            driverID : 0,
            rideID : ridesCount,
            rideStart : false,
            rideFinish : false,
            riderPaymentPermission : false,
            paymentFinish : false,
            totalCost : 0,
            bids : temp
        }));
        
        riderList[addressRiderIDMapping[msg.sender]-1].rideID = ridesCount;
        
        string memory id1 = uintToString(ridesCount);
        return ("Your Rideid is : ",id1);
    }
        
    function viewAllRideRequests() public returns(string[] _ride_data){
        require(addressDriverIDMapping[msg.sender] != 0 , "Only Driver can view all ride requests.");
        
        string[] ride_data;
    
        for(uint i=0;i<ridesCount;i++){
            if(ridesList[i].rideStart == false){
                uint tempid = ridesList[i].rideID;
                string memory id = uintToString(tempid);
                string src = ridesList[i].source;
                string dest = ridesList[i].destination;
                ride_data.push(strConcat(id,src,dest,"",""));
            }
        }
        
        return (ride_data);
    }
    
    function placeBids(uint _rideID) public returns(string){ 
        
        require(addressDriverIDMapping[msg.sender] != 0,"Only Driver can place a bid.");
        require(ridesList.length > 0 ,"No ride requests currently.");
        require(ridesList[_rideID-1].rideStart == false ,"Ride has already started. You can't place bid now.");
        
        string temp2 = driverList[addressDriverIDMapping[msg.sender]-1].currentStatus;
        require(stringCompare(temp2, available) ,"You are not allowed to make multiple bids at a time. Try again after finishing your current ride.");
        
        ridesList[_rideID-1].bids.push(addressDriverIDMapping[msg.sender]);
        return "Bid placed successfully";
    }
    
    // Function used by rider to view all the responses for the requested ride
    function viewResponses() public returns (uint[] response_data){
        require(addressRiderIDMapping[msg.sender] != 0 , "Only Rider can view responses.");
        return ridesList[riderList[addressRiderIDMapping[msg.sender]-1].rideID-1].bids;
    }
    
    // Function where rider selects a driver for the ride
    function selectDriver(uint _driverID) public returns(string){
        
        require(addressRiderIDMapping[msg.sender] != 0 , "Only Rider can select Driver.");
        require(ridesList.length > 0 ,"No ride requests currently.");
        
        uint _rideID = riderList[addressRiderIDMapping[msg.sender]-1].rideID;
        require(ridesList[_rideID-1].bids.length > 0 , "No Driver has accepted your request yet.");
        
        uint flag = 0;
        uint flag2 = 0;
        
        for(uint j=0 ; j < ridesList[_rideID-1].bids.length ; j++) {
            if(ridesList[_rideID-1].bids[j] == _driverID) {
                flag = 1;
            }
        }
        require(flag == 1 , "This Driver is not available.");
        
        for(uint j2=0 ; j2 < ridesList.length ; j2++) {
            if(ridesList[j2].rideID == _rideID) {
                flag2 = 1;
            }
        }
        require(flag2 == 1 , "Invalid Rideid. Please enter valid rideid.");
        
        require( driverList[_driverID-1].perkm <= riderList[ridesList[_rideID-1].riderID-1].wallet , "Insufficient Balance.");
        
        riderList[ridesList[_rideID-1].riderID-1].wallet -= driverList[_driverID-1].perkm;
        riderList[addressRiderIDMapping[msg.sender]-1].currentStatus = occupied;
        
        ridesList[_rideID-1].driverID = _driverID;
        ridesList[_rideID-1].totalCost = driverList[_driverID-1].perkm;
        ridesList[_rideID-1].rideStart = true;
        
        driverList[_driverID-1].currentStatus = occupied;
        driverList[_driverID-1].rideID = _rideID;
        
        return "Driver selected successfully. Ride starts.";
        
    }
    
    //Function to set the ride as finished
    function setRideFinish() public returns(string){
        require(addressDriverIDMapping[msg.sender] != 0 ,"Only Driver can set this.");
        uint _rideID = driverList[addressDriverIDMapping[msg.sender]-1].rideID;
        require( ridesList[_rideID-1].driverID == addressDriverIDMapping[msg.sender] , "Invalid Rideid. Please enter valid rideid.");
        
        ridesList[_rideID-1].rideFinish = true;
        return "Ride Finishes.";
    }
    
    function getBalanceRider() public view returns(uint){
        require(addressRiderIDMapping[msg.sender] != 0 , "Rider's wallet can be accessed only by rider.");
        return riderList[addressRiderIDMapping[msg.sender]-1].wallet;
    }
    
    // Function to know agreement of both driver and rider
    function SetRiderPaymentPermission(string _yesno) public payable  {
        require(addressRiderIDMapping[msg.sender] != 0 , "Only Rider can set this permission.");
        uint _rideID = riderList[addressRiderIDMapping[msg.sender]-1].rideID;
        require(ridesList[_rideID-1].rideFinish == true ,"Driver hasn't finished ride yet.");
        
        if(stringCompare(_yesno,"true") == true) {
            driverList[ridesList[_rideID-1].driverID-1].currentStatus = available;
            riderList[addressRiderIDMapping[msg.sender]-1].currentStatus = available;
            ridesList[_rideID-1].riderPaymentPermission = true;
            currrides -= 1;
            
        }
        else{
            driverList[ridesList[_rideID-1].driverID-1].currentStatus = available;
            riderList[addressRiderIDMapping[msg.sender]-1].currentStatus = available;
            ridesList[_rideID-1].rideFinish = false;
            ridesList[_rideID-1].riderPaymentPermission = false;
            riderList[ridesList[_rideID-1].riderID-1].wallet += ridesList[_rideID-1].totalCost;
            ridesList[_rideID-1].totalCost = 0;
            currrides -= 1;
        }
    }
    
    function withdrawMoney_Driver() public payable returns(string _paymentdone){
        require(addressDriverIDMapping[msg.sender] != 0,"Only Driver can call this function.");
        
        uint _rideID = driverList[addressDriverIDMapping[msg.sender]-1].rideID;
        require(ridesList[_rideID-1].riderPaymentPermission == true ,"Rider hasn't finished ride yet.");
        require(ridesList[_rideID-1].rideFinish == true ,"Driver hasn't finished ride yet.");
        
        driverList[ridesList[_rideID-1].driverID-1].wallet += ridesList[_rideID-1].totalCost;
        msg.sender.transfer(ridesList[_rideID-1].totalCost);
        ridesList[_rideID-1].totalCost = 0;
        return ("Payment done successfully");
    }
    
    // Functions used as secondary logic
    function uintToString(uint v) constant internal returns (string str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        
        bytes memory s = new bytes(i + 1);
        for (uint j = 0; j <= i; j++) {
            s[j] = reversed[i - j];
        }
        str = string(s);
    }
    
    function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }
    
    function stringCompare (string _str1, string _str2) internal returns (bool){
        bytes memory given1 = bytes(_str1);
        bytes memory answered1 = bytes(_str2);
        return keccak256(given1) == keccak256(answered1);
    }   
}