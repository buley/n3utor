pragma solidity ^0.5.16;

import "./Ownable.sol";
import "./DateLib.sol";

contract MediationOracle is Ownable {
    Dispute[] disputes;
    mapping(bytes32 => uint) disputeIdToIndex;

    using DateLib for DateLib.DateTime;

    struct Dispute {
        bytes32 id;
        string name;
        string participants;
        uint8 participantCount;
        uint date;
        DisputeOutcome outcome;
        int8 mediator;
    }

    enum DisputeOutcome {
        Pending,
        Underway,
        Draw,
        Decided
    }

    function _getDisputeIndex(bytes32 _disputeId) private view returns (uint) {
        return disputeIdToIndex[_disputeId]-1;
    }
    function disputeExists(bytes32 _disputeId) public view returns (bool) {
        if (disputes.length == 0)
            return false;
        uint index = disputeIdToIndex[_disputeId];
        return (index > 0); 
    }

    function addDispute(string memory _name, string memory _participants, uint8 _participantCount, uint _date) onlyOwner public returns (bytes32) {

        bytes32 id = keccak256(abi.encodePacked(_name, _participantCount, _date));

        require(!disputeExists(id));
        
        uint newIndex = disputes.push(Dispute(id, _name, _participants, _participantCount, _date, DisputeOutcome.Pending, -1))-1;
        disputeIdToIndex[id] = newIndex+1;
        
        return id;
    }

    function declareOutcome(bytes32 _disputeId, DisputeOutcome _outcome, int8 _mediator) onlyOwner external {

        require(disputeExists(_disputeId));

        uint index = _getDisputeIndex(_disputeId);
        Dispute storage theDispute = disputes[index];

        if (_outcome == DisputeOutcome.Decided)
            require(_mediator >= 0 && theDispute.participantCount > uint8(_mediator));

        theDispute.outcome = _outcome;
        
        if (_outcome == DisputeOutcome.Decided)
            theDispute.mediator = _mediator;
    }

    function getPendingDisputes() public view returns (bytes32[] memory) {
        uint count = 0; 

        for (uint i = 0; i < disputes.length; i++) {
            if (disputes[i].outcome == DisputeOutcome.Pending)
                count++; 
        }

        bytes32[] memory output = new bytes32[](count);

        if (count > 0) {
            uint index = 0;
            for (uint n = disputes.length; n > 0; n--) {
                if (disputes[n-1].outcome == DisputeOutcome.Pending)
                    output[index++] = disputes[n-1].id;
            }
        } 

        return output; 
    }

    function getAllDisputes() public view returns (bytes32[] memory) {
        bytes32[] memory output = new bytes32[](disputes.length);

        if (disputes.length > 0) {
            uint index = 0;
            for (uint n = disputes.length; n > 0; n--) {
                output[index++] = disputes[n-1].id;
            }
        }
        
        return output; 
    }

    function getDispute(bytes32 _disputeId) public view returns (
        bytes32 id,
        string memory name,
        string memory participants,
        uint8 participantCount,
        uint date, 
        DisputeOutcome outcome,
        int8 mediator) {
        
        if (disputeExists(_disputeId)) {
            Dispute storage theDispute = disputes[_getDisputeIndex(_disputeId)];
            return (theDispute.id, theDispute.name, theDispute.participants, theDispute.participantCount, theDispute.date, theDispute.outcome, theDispute.mediator);
        }
        else {
            return (_disputeId, "", "", 0, 0, DisputeOutcome.Pending, -1);
        }
    }

    function getMostRecentDispute(bool _pending) public view returns (
        bytes32 id,
        string memory name,
        string memory participants,
        uint8 participantCount,
        uint date, 
        DisputeOutcome outcome,
        int8 mediator) {

        bytes32 disputeId = 0;
        bytes32[] memory ids;

        if (_pending) {
            ids = getPendingDisputes();
        } else {
            ids = getAllDisputes();
        }
        if (ids.length > 0) {
            disputeId = ids[0];
        }
        
        return getDispute(disputeId);
    }

    function testConnection() public pure returns (bool) {
        return true; 
    }

    function getAddress() public view returns (address) {
        return address(this);
    }

    function addTestData() external onlyOwner {
        addDispute("Pacquiao vs. MayWeather", "Pacquiao|Mayweather", 2, DateLib.DateTime(2018, 8, 13, 0, 0, 0, 0, 0).toUnixTimestamp());
        addDispute("Macquiao vs. Payweather", "Macquiao|Payweather", 2, DateLib.DateTime(2018, 8, 15, 0, 0, 0, 0, 0).toUnixTimestamp());
        addDispute("Pacweather vs. Macarthur", "Pacweather|Macarthur", 2, DateLib.DateTime(2018, 9, 3, 0, 0, 0, 0, 0).toUnixTimestamp());
        addDispute("Macarthur vs. Truman", "Macarthur|Truman", 2, DateLib.DateTime(2018, 9, 3, 0, 0, 0, 0, 0).toUnixTimestamp());
        addDispute("Macaque vs. Pregunto", "Macaque|Pregunto", 2, DateLib.DateTime(2018, 9, 21, 0, 0, 0, 0, 0).toUnixTimestamp());
        addDispute("Farsworth vs. Wernstrom", "Farsworth|Wernstrom", 2, DateLib.DateTime(2018, 9, 29, 0, 0, 0, 0, 0).toUnixTimestamp());
        addDispute("Fortinbras vs. Hamlet", "Fortinbras|Hamlet", 2, DateLib.DateTime(2018, 10, 10, 0, 0, 0, 0, 0).toUnixTimestamp());
        addDispute("Foolicle vs. Pretendo", "Foolicle|Pretendo", 2, DateLib.DateTime(2018, 11, 11, 0, 0, 0, 0, 0).toUnixTimestamp());
        addDispute("Parthian vs. Scythian", "Parthian|Scythian", 2, DateLib.DateTime(2018, 11, 12, 0, 0, 0, 0, 0).toUnixTimestamp());
    }
}
