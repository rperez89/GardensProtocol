// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import {IProposalModule} from "./interfaces/IProposalModule.sol";

contract ProposalManager {
    struct ProposalModule {
        address implementation;
        bool isFundRequestor;
    }

    mapping(string => ProposalModule) internal proposalModules;

    // more variables i.e proposals mapping that maps an identifier with each module proposal mapping

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

    // Here is my doubt, how would you call to change the settings on the specific module without knowing the specific attributes that that specific module needs?
    // Maybe this is a bad architecture decision from scratch?
    function changeModuleSettings(string calldata _proposalType, ...... data){
      IProposalModule(proposalModules[_proposalType].implementation).setSettings(data);
    }
}
