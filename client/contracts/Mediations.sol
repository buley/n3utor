pragma solidity ^0.4.17;

import "./OracleInterface.sol";
import "./Ownable.sol";

contract Mediations is Ownable {
    
    mapping(address => bytes32[]) private userToOffers;
    mapping(bytes32 => Offer[]) private disputeToOffers;

    address internal mediationOracleAddr = 0;
    OracleInterface internal mediationOracle = OracleInterface(mediationOracleAddr);

    uint internal minimumOffer = 1000000000000;

    struct Offer {
        address user;
        bytes32 disputeId;
        uint amount; 
        uint8 offerValue;
    }

    enum ResolvableOutcome {
        Disputant1,
        Disputant2
    }

    function _offerIsValid(address _user, bytes32 _disputeId, uint8 _offerValue) private view returns (bool) {
        return true;
    }

    function _disputeOpenForResolution(bytes32 _disputeId) private view returns (bool) {
        return true;
    }

    function setOracleAddress(address _oracleAddress) external onlyOwner returns (bool) {
        mediationOracleAddr = _oracleAddress;
        mediationOracle = OracleInterface(mediationOracleAddr);
        return mediationOracle.testConnection();
    }

    function getOracleAddress() external view returns (address) {
        return mediationOracleAddr;
    }

    function getResolvableDisputes() public view returns (bytes32[]) {
        return mediationOracle.getPendingDisputes();
    }

    function getDispute(bytes32 _disputeId) public view returns (
        bytes32 id,
        string name, 
        string participants,
        uint8 participantCount,
        uint date, 
        OracleInterface.DisputeOutcome outcome,
        int8 mediator) {
        return mediationOracle.getDispute(_disputeId);
    }

    function getMostRecentDispute() public view returns (
        bytes32 id,
        string name, 
        string participants,
        uint participantCount, 
        uint date, 
        OracleInterface.DisputeOutcome outcome,
        int8 mediator) {
        return mediationOracle.getMostRecentDispute(true);
    }

    function makeOffer(bytes32 _disputeId, uint8 _offerValue) public payable {

        require(msg.value >= minimumOffer, "Offer amount must be >= minimum offer");

        require(mediationOracle.disputeExists(_disputeId), "Specified dispute not found");

        require(_offerIsValid(msg.sender, _disputeId, _offerValue), "Offer is not valid");

        require(_disputeOpenForResolution(_disputeId), "Dispute not open for resolution");

        address(this).transfer(msg.value);

        Offer[] storage offers = disputeToOffers[_disputeId];
        offers.push(Offer(msg.sender, _disputeId, msg.value, _offerValue))-1;

        bytes32[] storage userOffers = userToOffers[msg.sender];
        userOffers.push(_disputeId);
    }

    function testOracleConnection() public view returns (bool) {
        return mediationOracle.testConnection();
    }
}