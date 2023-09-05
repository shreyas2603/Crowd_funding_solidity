// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";
contract chain {
    using PriceConverter for uint;
    uint public Total_Organizer;
    uint public Total_Events;
    struct Organizer{
        string Name;
        string Email_Id;
        bool active;
        address Organizer;
    }

    struct Event{
        string Patient_name;
        uint age;
        string Relation;
        string Prb;
        string link;
        uint deadline;
        string Hospital_name;
        string Doctor;
        uint Total_amount;
        uint Remaining_amount;
        bool active;
    }

    struct End_user{
        string Name;
        uint Amount;
        address user_address;
        string Email_id;
    }
    
    

    mapping(address=>Organizer) public Organizer_Info;
    address [] private Organizer_Log;

    mapping (address=>Event) public Event_Info;
    address [] private Event_Info_Log;

    mapping(address=>End_user) public End_user_Info;
    address [] private End_user_Log;
    function RegOrganizer(string memory _Name,string memory _Email) public {
            Organizer memory xorganizer=Organizer({
                Name:_Name,
                Email_Id:_Email,
                active:true,
                Organizer:msg.sender
            });
            Organizer_Info[msg.sender]=xorganizer;
            Organizer_Log.push(msg.sender);
            Total_Organizer++;
    }

    function RegEvent(string memory _Patient_name,uint _age,string memory _rel,string memory _link,string memory _prb,uint _deadline,string memory _Hospital_name,string memory _Docter,uint _Total_amount)public{
            require(Organizer_Info[msg.sender].active==true,"Only Organizer Can Activate Event");
            require(Event_Info[msg.sender].active==false,"You can Create Event only once");
            Event memory xEvent=Event({
                Patient_name:_Patient_name,
                age:_age,
                Relation:_rel,
                Doctor:_Docter,
                Prb:_prb,
                link:_link,
                deadline:_deadline,
                Hospital_name:_Hospital_name,
                Total_amount:_Total_amount,
                Remaining_amount:_Total_amount*1e18,
                active:true

            });
            Event_Info[msg.sender]=xEvent;
            Total_Events++;
            Event_Info_Log.push(msg.sender);
    }


    function Pay(address payable to,string memory _Name,string memory _Emailid) public payable{
           
            require(Event_Info[to].deadline>block.timestamp,"Time for the Camp is Over");
            require(Event_Info[to].Remaining_amount!=0,"Already Funded");
            uint xprice=Event_Info[to].Remaining_amount;
            //xprice=xprice*1e18;
            require(xprice>msg.value,"Please Enter Correct Amount");
            End_user memory xend_user=End_user({
                Name:_Name,
                Amount:msg.value,
                user_address:msg.sender,
                Email_id:_Emailid
            });
            End_user_Info[msg.sender]=xend_user;
             (bool callSuccess, ) = payable(to).call{value:msg.value}("");
            require(callSuccess, "Call failed");
            End_user_Log.push(msg.sender);
            xprice=xprice-msg.value.getConversionRate();
            Event_Info[to].Remaining_amount=xprice;

            if(Event_Info[to].Remaining_amount==0){
                Event_Info[to].active=false;
            }
            
    }

    function VOrganizer_Log() public view returns(address[] memory){
        return Organizer_Log;
    }
    function VEnd_user_Log() public view returns(address[] memory){
        return End_user_Log;
    }
}
//This code is contributed by Myself,Kavin and yaswanth
