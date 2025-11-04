// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title ProofRealm
 * @notice A decentralized ecosystem for storing, verifying, and managing cryptographic proofs.
 *         ProofRealm allows users to submit digital proofs that can later be validated by
 *         authorized verifiers or through community consensus.
 *
 * @dev Designed for dApps requiring immutable proof tracking such as academic credentials,
 *      legal evidence, NFT authenticity, and supply chain verifications.
 */
contract ProofRealm {
    address public admin;
    uint256 public proofCount;

    enum ProofStatus {
        Pending,
        Verified,
        Rejected
    }

    struct Proof {
        uint256 id;
        address submitter;
        string dataHash;    // Hash or content reference (e.g., IPFS CID)
        string metadataURI; // Optional metadata (description, file reference)
        uint256 timestamp;
        ProofStatus status;
    }

    mapping(uint256 => Proof) public proofs;
    mapping(address => uint256[]) public userProofs;

    event ProofSubmitted(uint256 indexed id, address indexed submitter, string dataHash);
    event ProofVerified(uint256 indexed id, address indexed verifier);
    event ProofRejected(uint256 indexed id, address indexed verifier);
    event OwnershipTransferred(address indexed previousAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /**
     * @notice Submit a new proof for verification.
     * @param _dataHash The content hash or digital proof reference.
     * @param _metadataURI Additional metadata or file reference.
     */
    function submitProof(string memory _dataHash, string memory _metadataURI) external {
        require(bytes(_dataHash).length > 0, "Data hash cannot be empty");

        proofCount++;
        proofs[proofCount] = Proof({
            id: proofCount,
            submitter: msg.sender,
            dataHash: _dataHash,
            metadataURI: _metadataURI,
            timestamp: block.timestamp,
            status: ProofStatus.Pending
        });

        userProofs[msg.sender].push(proofCount);

        emit ProofSubmitted(proofCount, msg.sender, _dataHash);
    }

    /**
     * @notice Verify a submitted proof.
     * @param _id ID of the proof to verify.
     */
    function verifyProof(uint256 _id) external onlyAdmin {
        Proof storage proof = proofs[_id];
        require(proof.status == ProofStatus.Pending, "Proof already verified or rejected");

        proof.status = ProofStatus.Verified;
        emit ProofVerified(_id, msg.sender);
    }

    /**
     * @notice Reject a submitted proof.
     * @param _id ID of the proof to reject.
     */
    function rejectProof(uint256 _id) external onlyAdmin {
        Proof storage proof = proofs[_id];
        require(proof.status == ProofStatus.Pending, "Proof already verified or rejected");

        proof.status = ProofStatus.Rejected;
        emit ProofRejected(_id, msg.sender);
    }

    /**
     * @notice Retrieve proof details by ID.
     * @param _id The proof ID.
     * @return The full proof details.
     */
    function getProof(uint256 _id) external view returns (Proof memory) {
        require(_id > 0 && _id <= proofCount, "Invalid proof ID");
        return proofs[_id];
    }

    /**
     * @notice Get all proof IDs submitted by a specific user.
     * @param _user Address of the proof submitter.
     * @return Array of proof IDs.
     */
    function getUserProofs(address _user) external view returns (uint256[] memory) {
        return userProofs[_user];
    }

    /**
     * @notice Transfer contract admin rights to another address.
     * @param _newAdmin The new admin address.
     */
    function transferOwnership(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0), "Invalid new admin address");
        emit OwnershipTransferred(admin, _newAdmin);
        admin = _newAdmin;
    }
}
