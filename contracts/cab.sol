pragma solidity ^0.4.0;

contract cab {
    
    constructor() public {
        
    }
    
    //utility fn to compare equality of 2 given strings
    function stringsEqual(string storage _a, string memory _b) view internal returns (bool) {
        bytes storage a = bytes(_a);
        bytes memory b = bytes(_b);
        if (a.length != b.length)
            return false;
        // @todo unroll this loop
        for (uint i = 0; i < a.length; i ++)
            if (a[i] != b[i])
                return false;
        return true;
    }
    
    struct route{
        string fromAddress;
        string toAddress;
    }
    
    mapping(uint256=>route) routeMap; // map to store seq-num and route
    mapping(uint256=>uint256) priceOfRoute; // map from seq-num to price
    mapping(uint256=>address) driverOf; // map from  seq-num to driver
    
    uint256 numOfRoutes=0;
    
    // struct driver{
    //     address driverAddress;
    //     route driverRoute;
    //     uint256 price;
    // }
    
    // struct passenger{
    //     route passengerRoute;
    // }
    
    
    function offerRide(string _fromAddress, string _toAddress, uint256 price) public {
        // driversList.push(driver(msg.sender,route(fromAddress,toAddress),price));
        bool isNewRoute = false;
        for(uint256 i = 0; i<numOfRoutes; i++){
            if(! (stringsEqual(routeMap[i].fromAddress, _fromAddress) && 
                  stringsEqual(routeMap[i].toAddress, _toAddress)         )
              ){ 
                   //when route doesn't already exists
                   isNewRoute = true;
                   break;
            }
        }
        
        if(!isNewRoute){
                if(priceOfRoute[i]>price){ //when this driver is offering a lower price for existing route
                    priceOfRoute[i]=price; //update price
                    driverOf[i]=msg.sender; //update driver
                }
            }
            else{ // entry new route into our data.
                
                routeMap[numOfRoutes].fromAddress = _fromAddress; 
                routeMap[numOfRoutes].toAddress = _toAddress;
                priceOfRoute[numOfRoutes] = price;
                driverOf[numOfRoutes] = msg.sender;
                
                numOfRoutes++;
            }
        }
        
    function searchRide(string _fromAddress, string _toAddress) view public returns (bool){
        
        bool routeFound = false;
        for(uint256 i = 0; i<numOfRoutes; i++){
            if( stringsEqual(routeMap[i].fromAddress, _fromAddress) && 
                 stringsEqual(routeMap[i].toAddress, _toAddress)){ 
                   //when route doesn't already exists
                   routeFound = true;
                   break;
            }
        }
       return routeFound; 
    }
        
}