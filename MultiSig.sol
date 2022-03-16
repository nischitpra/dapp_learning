// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */


contract MultiSig {

    struct Proposal {
        string topic;
        string description;
        address targetContract;
        string targetMethodName;
        string targetParams;
        // not using addres[] voters because there is no list in solidity and we dont want to use array. we need to get size of list for processing
        mapping (address => bool) voters;
        uint execThreshold;
        bool isExecuted;
    }

    /**
    * later can create api to set safe users based on voters as well
    * using array of address is not possible because solidity doesn't provide contains method so will use a map instead
    * re: mapping also doesnt have method contains. need to check value explicitly for validation
    */
    mapping (address => bool) public safeUsers;

    mapping (string => Proposal) public proposalMap;

    constructor() {
        safeUsers[address(0xE52772e599b3fa747Af9595266b527A31611cebd)] = true;
        safeUsers[address(0xc3B8b734d09e82670224c82074B4e778943d9867)] = true;
        safeUsers[address(0xA0e44Be4C5fbA68D03C1295fE162B74DC6ec3053)] = true;
        safeUsers[address(0x8D264d965b4484DC4f478aCAcEcCc024Ac21D346)] = true;
    }

    // solidity doesn't allow returning mapping so creating a helper method to check if specific address exists in map
    function doesUserExist(address a) public view returns (bool){
        return safeUsers[a];
    }

    // helper method to check if specific proposal exists by topic
    function doesProposalExist(string memory topic) public view returns (bool) {
        return this.compareString(proposalMap[topic].topic, topic);
    }

    function getEthBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function createProposal(
        string memory topic, 
        string memory description, 
        address targetContract, 
        string memory targetMethodName, 
        string memory targetParams, 
        uint execThreshold
    ) public {
        require(safeUsers[msg.sender] == true, "unauthorized User");
        require(execThreshold <= 4 && execThreshold > 1, "impossible execution threshold");
        // all keys exist in solidity
        Proposal storage proposal = proposalMap[topic];
        require(execThreshold == 0,"proposal already created");
        proposal.topic = topic;
        proposal.description = description;
        proposal.targetContract = targetContract;
        proposal.targetMethodName = targetMethodName;
        proposal.targetParams = targetParams;
        proposal.execThreshold = execThreshold;
        proposal.isExecuted = false;
        // todo: might no need this 
        // proposalMap[topic] = proposal;
    }

    function vote(string memory topic) public {
        require(safeUsers[msg.sender] == true, "unauthorized user");
        require(this.compareString(proposalMap[topic].topic, topic), "proposal not found");
        Proposal storage proposal = proposalMap[topic];
        proposal.voters[msg.sender] = true;

        this.execProposal(proposal);
    }

    /**
    * need to make these private. but private methods cannot be called from public method? getting some weird error
    */
    // this is always called from vote function which is a public function 
    // .call();
    function execProposal(Proposal storage proposal) private {
        if(!proposal.voters.length >= proposal.execThreshold) return;
        if(proposal.isExecuted) return;
        // make transaction to target contract
        (bool status, bytes memory result) = proposal.targetContract.call(abi.encodeWithSignature(proposal.targetMethodName, proposal.targetParams));
        if(!status) {
            require(true, "could not complete request to target contract");
        }
        proposal.isExecuted = true;
    }

    function compareString(string memory s1, string memory s2) private pure returns (bool) {
        bytes memory bs1 = bytes(s1);
        bytes memory bs2 = bytes(s2);
        return (bs1.length == bs2.length) && (keccak256(bs1) == keccak256(bs2));
    }

}
