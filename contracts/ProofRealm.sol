// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ProofRealm {
    struct Proof {
        address submitter;
        uint256 timestamp;
        string metadata;  // Optional — e.g. IPFS CID, description, document type
    }

    // Mapping from proof ID to Proof
    mapping(uint256 => Proof) private proofs;
    // Mapping from document hash to proof ID — to allow lookup by hash
    mapping(bytes32 => uint256) private hashToProofId;

    uint256 private nextProofId = 1;

    // Events
    event ProofRegistered(uint256 indexed proofId, address indexed submitter, uint256 timestamp, string metadata, bytes32 docHash);
    event ProofMetadataUpdated(uint256 indexed proofId, string newMetadata);

    /// @notice Register a new proof by providing a document hash and optional metadata.
    /// @param docHash The keccak256 hash of the document.
    /// @param metadata Optional metadata or link (e.g. IPFS CID).
    /// @return proofId The id assigned to the new proof.
    function registerProof(bytes32 docHash, string memory metadata) external returns (uint256 proofId) {
        require(docHash != bytes32(0), "Invalid document hash");
        require(hashToProofId[docHash] == 0, "Proof already exists for this hash");

        proofId = nextProofId++;
        proofs[proofId] = Proof({
            submitter: msg.sender,
            timestamp: block.timestamp,
            metadata: metadata
        });
        hashToProofId[docHash] = proofId;

        emit ProofRegistered(proofId, msg.sender, block.timestamp, metadata, docHash);
        return proofId;
    }

    /// @notice Get proof details by proof ID.
    /// @param proofId The id of the proof to fetch.
    function getProof(uint256 proofId) external view returns (address submitter, uint256 timestamp, string memory metadata) {
        Proof memory p = proofs[proofId];
        require(p.timestamp != 0, "Proof not found");
        return (p.submitter, p.timestamp, p.metadata);
    }

    /// @notice Find a proof ID by document hash, if registered.
    /// @param docHash The hash to look up.
    /// @return proofId The proof ID, or 0 if not found.
    function findProofByHash(bytes32 docHash) external view returns (uint256 proofId) {
        return hashToProofId[docHash];
    }

    /// @notice Allow the original submitter to update metadata (e.g. attach IPFS link later).
    /// @param proofId The proof ID to update.
    /// @param newMetadata The updated metadata string.
    function updateMetadata(uint256 proofId, string memory newMetadata) external {
        Proof storage p = proofs[proofId];
        require(p.submitter == msg.sender, "Only submitter can update metadata");
        require(p.timestamp != 0, "Proof not found");
        p.metadata = newMetadata;
        emit ProofMetadataUpdated(proofId, newMetadata);
    }

    /// @notice Returns total number of proofs registered so far.
    function totalProofs() external view returns (uint256) {
        return nextProofId - 1;
    }
}
