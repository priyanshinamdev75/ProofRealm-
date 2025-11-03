// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title ProofRealm
 * @notice A decentralized verification system that allows users to submit proofs 
 *         and verifiers to validate them for authenticity and integrity.
 */
contract Project {
    address public admin;
    uint256 public proofCount;

    struct Proof {
        uint256 id;
        address submitter;
        string dataHash;
        string description;
        uint256 timestamp;
        bool verified;
    }

    mapping(uint256 => Proof) public proofs;

    event ProofSubmitted(uint256 indexed id, address indexed submitter, string dataHash, string description);
    event ProofVerified(uint256 indexed id, address indexed verifier);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        a
