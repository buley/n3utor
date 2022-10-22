pragma solidity ^0.5.16;

contract OracleInterface {

    enum DisputeOutcome {
        Pending,
        Underway,
        Draw,
        Decided
    }

    function getPendingDisputes() public view returns (bytes32[] memory);

    function getAllDisputes() public view returns (bytes32[] memory);

    function disputeExists(bytes32 _disputeId) public view returns (bool);

    function getDispute(bytes32 _disputeId) public view returns (
        bytes32 id,
        string memory name,
        string memory participants,
        uint8 participantCount,
        uint date, 
        DisputeOutcome outcome,
        int8 mediator);

    function getMostRecentDispute(bool _pending) public view returns (
        bytes32 id,
        string memory name,
        string memory participants,
        uint participantCount,
        uint date, 
        DisputeOutcome outcome,
        int8 mediator);

    function testConnection() public pure returns (bool);

    function addTestData() public; 
}
