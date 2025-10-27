// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ProofRealm
 * @dev A decentralized proof management system to verify ownership and authenticity of documents.
 */
contract Project {
    address public owner;
    uint256 public proofCount;

    struct Proof {
        uint256 id;
        string documentHash;
        address submitter;
        uint256 timestamp;
        bool verified;
    }

    mapping(uint256 => Proof) public proofs;

    event ProofSubmitted(uint256 indexed id, address indexed submitter, string documentHash);
    event ProofVerified(uint256 indexed id, address indexed verifier);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // ✅ Function 1: Submit a proof (document hash)
    function submitProof(string memory _documentHash) public {
        proofCount++;
        proofs[proofCount] = Proof(proofCount, _documentHash, msg.sender, block.timestamp, false);
        emit ProofSubmitted(proofCount, msg.sender, _documentHash);
    }

    // ✅ Function 2: Verify a proof (only owner)
    function verifyProof(uint256 _id) public onlyOwner {
        require(_id > 0 && _id <= proofCount, "Invalid proof ID");
        require(!proofs[_id].verified, "Already verified");

        proofs[_id].verified = true;
        emit ProofVerified(_id, msg.sender);
    }

    // ✅ Function 3: Get proof details
    function getProof(uint256 _id) public view returns (Proof memory) {
        require(_id > 0 && _id <= proofCount, "Invalid proof ID");
