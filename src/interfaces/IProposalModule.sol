// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IProposalModule {
    enum ProposalStatus {
        Active, // A vote that has been reported to Agreements
        Cancelled, // A vote that has been cancelled
        Executed // A vote that has been executed
    }

    function addProposal(
        string calldata _title,
        bytes calldata _link,
        uint256 _requestedAmount,
        address _beneficiary
    ) external returns (uint256);

    function canExecute(uint256 _proposalId) external returns (bool);

    function stakeToProposal(uint256 _proposalId, uint256 _amount) external;

    function withdrawFromProposal(uint256 _proposalId, uint256 _amount)
        external;

    function executeProposal(uint256 _proposalId) external;

    function cancelProposal(uint256 _proposalId) external;

    function getProposalUserStake(uint256 _proposalId, address _voter)
        external
        view
        returns (uint256);
}
