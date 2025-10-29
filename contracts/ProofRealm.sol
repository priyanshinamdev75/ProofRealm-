? Function 1: Submit a proof (document hash)
    function submitProof(string memory _documentHash) public {
        proofCount++;
        proofs[proofCount] = Proof(proofCount, _documentHash, msg.sender, block.timestamp, false);
        emit ProofSubmitted(proofCount, msg.sender, _documentHash);
    }

    ? Function 3: Get proof details
    function getProof(uint256 _id) public view returns (Proof memory) {
        require(_id > 0 && _id <= proofCount, "Invalid proof ID");
// 
update
// 
