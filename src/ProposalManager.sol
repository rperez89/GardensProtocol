// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import {IProposalModule} from "./interfaces/IProposalModule.sol";

contract ProposalManager {
    struct ProposalModule {
        string name;
        address implementation;
        bool isFundRequestor;
    }
    struct Proposal {
      uint256 id;
      string typeName;
      uint256 proposalModuleId; // The proposal id on the specific module
    }

    mapping(string => ProposalModule) internal proposalModules;
    mapping(uint256=> Proposal) internal proposals;


    function addProposalModule(
        string calldata _name,
        address _implementation,
        bool _isFundRequestor
    ) external {
        proposalModules[_name] = ProposalModule(
            _implementation,
            _isFundRequestor
        );
    }

    function addProposal(string calldata _proposalType, ...... data){
      IProposalModule(proposalModules[_proposalType].implementation).createProposal(data);
    }

}
