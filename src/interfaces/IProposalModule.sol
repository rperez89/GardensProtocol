// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IProposalModule {
    enum ProposalStatus {
        Active, // A vote that has been reported to Agreements
        Cancelled, // A vote that has been cancelled
        Executed // A vote that has been executed
    }

    struct Proposal {
        address submitter;
        address beneficiary;
        uint256 requestedAmount;
        uint256 stakedTokens;
        ProposalStatus proposalStatus;
        // mapping(address => uint256) userStake;
        // uint256 parametersCounter;
    }

    // struct additionalProposalParameters {
    //     string name;
    //     uint256 intParm;
    //     address addressParm;
    //     bool booleanParm;
    //     string stringParm;
    //     bytes bytesParm;
    // }

    // mapping(uint256 => additionalProposalParameters) proposalParameters;

    // mapping(uint256 => Proposal) internal proposals;

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

    function getProposal(uint256 _proposalId)
        external
        view
        returns (
            address submitter,
            address beneficiary,
            uint256 requestedAmount,
            uint256 stakedTokens,
            ProposalStatus proposalStatus,
            uint256 parametersCounter
        );

    function getProposalUserStake(uint256 _proposalId, address _voter)
        external
        view
        returns (uint256);
}
