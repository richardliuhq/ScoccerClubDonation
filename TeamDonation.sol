
pragma solidity ^0.4.18;

contract Owned {
    address owner;

    constructor() payable public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier isPassAudit(bool passed) {
        require(passed);
        _;
    }

    function bytes32ToStr(bytes32 _bytes32) internal pure returns (string){

        // string memory str = string(_bytes32);
        // TypeError: Explicit type conversion not allowed from "bytes32" to "string storage pointer"
        // thus we should fist convert bytes32 to bytes (to dynamically-sized byte array)

        bytes memory bytesArray = new bytes(32);
        for (uint256 i; i < 32; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    function bytesToBytes32(bytes b, uint offset) private pure returns (bytes32) {
        bytes32 out;

        for (uint i = 0; i < 32; i++) {
            out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    function stringToBytes32(bytes memory source) internal pure returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }
    function uint2str(uint i) internal pure returns (string){
        if (i == 0) return "0";
        uint j = i;
        uint length;
        while (j != 0){
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
contract ClubTeam is Owned {
    bool public isAuditPassed =true;
    uint256 public totalAmount;
    bool isUnderMaintain;
    uint withdrawDate;

    uint public players;
    bytes32 public teamName;
    bytes32 coachName;
    
    function toggleMaintain() onlyOwner public {
      // You can add an additional modifier that restricts stopping a contract to be based on another action, such as a vote of users
      isUnderMaintain = !isUnderMaintain;
    }
    
    //Circuit Breakers (Pause contract functionality)
    modifier isNotUnderMaintain { if (!isUnderMaintain) _; }

    event log_audit(
        uint256 thisBalance,
        uint256 totalAmount
    );

    constructor(uint _players, bytes32 _teamName, bytes32 _coachName) public {
        players=_players;
        teamName=_teamName;
        coachName=_coachName;
        withdrawDate=now;
    }
    

    uint constant WITHDRAWWAITPERIOD = 28 days; // 4 weeks

    function audit() public{
        //Check if the balance matched;
        emit log_audit(address(this).balance,totalAmount);
        if (totalAmount == address(this).balance){
            isAuditPassed=true;
        }else{
            isAuditPassed=false;
        }
    }

    function getBalance() view public returns(uint256){
        return address(this).balance;
    }

    function() public payable{
        require (isAuditPassed);
        require (totalAmount + msg.value > totalAmount);
        totalAmount +=msg.value;
    }
    function withDraw() public onlyOwner isNotUnderMaintain payable{
        uint WithDrawAmount = address(this).balance/2;
        //Speed Bumps (Delay contract actions)
        if (WithDrawAmount >0 && now>withdrawDate + WITHDRAWWAITPERIOD) {
            withdrawDate = now;
            owner.transfer(address(this).balance);
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

contract ScoccerClub is Owned {
    //this contract creates specified team contract so that each team can receive funds from donator
    struct Team {
        uint players;
        bytes32 teamName;
        bytes32 coachName;
        uint256 amount;
        address teamAddress;
    }

    uint counter;
    mapping(uint => Team) teams;
    uint[] public teamAccts;
    bytes32[] public allTeams;

    event log_teamInfo(
        uint num,
        bytes32 teamName,
        bytes32 coachName,
        uint players,
        address teamAddress
    );

    function createTeam(uint _players, bytes32 _teamName, bytes32 _coachName) onlyOwner public {
        address newTeamAddress = new ClubTeam(_players,_teamName,_coachName);
        Team storage newTeam = teams[counter];
        newTeam.players = _players;
        newTeam.teamName = _teamName;
        newTeam.coachName = _coachName;
        teamAccts.push(counter);
        bytes memory c = append(bytes32ToStr(_teamName),bytes32ToStr(";"),bytes32ToStr(_coachName),bytes32ToStr(";"),uint2str(_players));
        allTeams.push(stringToBytes32(c));
        emit log_teamInfo(counter,_teamName,_coachName,_players,newTeamAddress);
        counter++;
    }

    function getAllTeams() view public returns(uint[]) {
        return teamAccts;
    }

    function getAllTeamsinText() view public returns(bytes32[]) {
        return allTeams;
    }

    function getTeamInfo(uint _counter) view public returns (uint, bytes32, bytes32, uint256) {
        return (teams[_counter].players, teams[_counter].teamName, teams[_counter].coachName,teams[_counter].amount);
    }

    function countTeams() view public returns (uint) {
        return teamAccts.length;
    }

    function  append(string a, string b, string c, string d,string e) public pure returns (bytes) {
        return abi.encodePacked(a, b,c,d,e);
    }

    function() public payable{
    }

}