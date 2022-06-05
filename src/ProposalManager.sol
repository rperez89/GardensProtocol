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
        string typeName;
        uint256 proposalModuleId; // The proposal id on the specific module
    }

    uint256 proposalCounter;

    mapping(string => ProposalModule) internal proposalModules;
    mapping(uint256 => Proposal) internal proposals;

    event ProposalAdded(
        address indexed entity,
        uint256 indexed id,
        string proposalType,
        uint256 indexed proposalModulesId
    );

    function addProposalModule(
        string calldata _name,
        address _implementation,
        bool _isFundRequestor
    ) external {
        proposalModules[_name] = ProposalModule(
            _name,
            _implementation,
            _isFundRequestor
        );
    }

    function addProposal(
        string calldata _proposalType,
        string calldata _title,
        bytes calldata _link,
        uint256 _requestedAmount,
        address _beneficiary
    ) external {
        uint256 proposalModuleId = IProposalModule(
            proposalModules[_proposalType].implementation
        ).addProposal(_title, _link, _requestedAmount, _beneficiary);

        proposals[proposalCounter++] = Proposal(
            _proposalType,
            proposalModuleId
        );

        emit ProposalAdded(
            msg.sender,
            proposalCounter,
            _proposalType,
            proposalModuleId
        );
    }
}
