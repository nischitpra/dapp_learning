// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract MappingTest {
    struct Proposal {
        string topic;
        string description;
        address targetContract;
        uint count;
    }

    mapping (string=>Proposal) public proposals;

    string[] public items;

    uint public gas;
    uint public gasprice;

    function addItem(string memory item) public {
        require(!compareString(item, ""), "item cannot be empty");
        items.push(item);
        gasprice = tx.gasprice;
    }

    function itemsSize() public view returns(uint)  {
        return items.length;
    }

    function setProposal(string memory topic, string memory description, address targetContract) public {
        Proposal storage p = proposals[topic];
        require(
            compareString(p.topic, "") && 
            compareString(p.description, "") && 
            p.targetContract == address(0) && 
            p.count == 0, 
            "Proposal already exists"
        );
        p.topic = topic;
        p.description = description;
        p.targetContract = targetContract;
    }

    function getProposal(string memory topic) public view returns(Proposal memory) {
        require(compareString(topic, ""), "topic is empty");
        return proposals[topic];
    }
    
    function compareString(string memory s1, string memory s2) public pure returns (bool) {
        bytes memory bs1 = bytes(s1);
        bytes memory bs2 = bytes(s2);
        return (bs1.length == bs2.length) && (keccak256(bs1) == keccak256(bs2));
    }

}