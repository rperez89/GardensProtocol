// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IProposalModule {
    struct Proposal {
        uint256 proposalId;
    }

    function createProposal(bytes memory _proposalParams)
        external
        returns (uint256);

    function getProposal(uint256 _proposalId)
        external
        returns (Proposal memory);

    function canExecute(uint256 _proposalId) external returns (bool);

    function setSettings(bytes memory _initializeParams) external;
}
