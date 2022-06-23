// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import {Module} from "zodiac/core/Module.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IProposalModule} from "./interfaces/IProposalModule.sol";

contract UniqueFundingProposal is Module, IProposalModule {
    using SafeERC20 for ERC20;

    string private constant ERROR_PROPOSAL_DOES_NOT_EXIST =
        "PROPOSAL_DOES_NOT_EXIST";
    string private constant ERROR_AMOUNT_CAN_NOT_BE_ZERO =
        "AMOUNT_CAN_NOT_BE_ZERO";
    string private constant ERROR_PROPOSAL_NOT_ACTIVE = "PROPOSAL_NOT_ACTIVE";

    ERC20 public stakeToken;
    address public requestToken;
    uint256 public decay;
    uint256 public maxRatio;
    uint256 public weight;
    uint256 public minThresholdStakePercentage;
    uint256 public proposalCounter;
    uint256 public totalStaked;

    struct Proposal {
        address submitter;
        address beneficiary;
        uint256 requestedAmount;
        uint256 stakedTokens;
        ProposalStatus proposalStatus;
        // mapping(address => uint256) userStake;
        // uint256 parametersCounter;
    }

    mapping(uint256 => Proposal) internal proposals;
    mapping(address => uint256) internal totalUserStake;
    mapping(address => mapping(uint256 => uint256)) userProposalStake;

    event ProposalAdded(
        address indexed entity,
        uint256 indexed id,
        string title,
        bytes link,
        uint256 amount,
        address beneficiary
    );

    modifier proposalExists(uint256 _proposalId) {
        require(
            _proposalId == 1 || proposals[_proposalId].submitter != address(0),
            ERROR_PROPOSAL_DOES_NOT_EXIST
        );
        _;
    }

    constructor(
        address _owner,
        ERC20 _stakeToken,
        address _requestToken,
        uint256 _decay,
        uint256 _maxRatio,
        uint256 _weight,
        uint256 _minThresholdStakePercentage
    ) {
        bytes memory initializeParams = abi.encode(
            _owner,
            _stakeToken,
            _requestToken,
            _decay,
            _maxRatio,
            _weight,
            _minThresholdStakePercentage
        );
        setUp(initializeParams);
    }

    function setUp(bytes memory initializeParams) public override initializer {
        __Ownable_init();
        (
            address _owner,
            ERC20 _stakeToken,
            address _requestToken,
            uint256 _decay,
            uint256 _maxRatio,
            uint256 _weight,
            uint256 _minThresholdStakePercentage
        ) = abi.decode(
                initializeParams,
                (address, ERC20, address, uint256, uint256, uint256, uint256)
            );

        setAvatar(_owner);
        setTarget(_owner);
        stakeToken = _stakeToken;
        requestToken = _requestToken;
        decay = _decay;
        maxRatio = _maxRatio;
        weight = _weight;
        minThresholdStakePercentage = _minThresholdStakePercentage;
        transferOwnership(_owner);
    }

    /**
     * @notice Add proposal `_title` for  `@tokenAmount((self.requestToken(): address), _requestedAmount)` to `_beneficiary`
     * @param _title Title of the proposal
     * @param _link IPFS or HTTP link with proposal's description
     * @param _requestedAmount Tokens requested
     * @param _beneficiary Address that will receive payment
     */
    function addProposal(
        string calldata _title,
        bytes calldata _link,
        uint256 _requestedAmount,
        address _beneficiary
    ) public returns (uint256) {
        proposals[proposalCounter++] = Proposal(
            msg.sender,
            _beneficiary,
            _requestedAmount,
            0,
            ProposalStatus.Active
        );

        emit ProposalAdded(
            msg.sender,
            proposalCounter,
            _title,
            _link,
            _requestedAmount,
            _beneficiary
        );
        return proposalCounter;
    }

    /**
     * @notice Stake `@tokenAmount((self.stakeToken(): address), _amount)` on proposal #`_proposalId`
     * @param _proposalId Proposal id
     * @param _amount Amount of tokens staked
     */
    function stakeToProposal(uint256 _proposalId, uint256 _amount) external {
        _stake(_proposalId, _amount, msg.sender);
    }

    /**
     * @dev Stake an amount of tokens on a proposal
     * @param _proposalId Proposal id
     * @param _amount Amount of staked tokens
     * @param _from Account from which we stake
     */
    function _stake(
        uint256 _proposalId,
        uint256 _amount,
        address _from
    ) internal proposalExists(_proposalId) {
        Proposal storage proposal = proposals[_proposalId];
        require(_amount > 0, ERROR_AMOUNT_CAN_NOT_BE_ZERO);
        require(
            proposal.proposalStatus == ProposalStatus.Active,
            ERROR_PROPOSAL_NOT_ACTIVE
        );

        uint256 unstakedAmount = stakeToken.balanceOf(_from).sub(
            totalUserStake[_from]
        );
        if (_amount > unstakedAmount) {
            _withdrawInactiveStakedTokens(_amount.sub(unstakedAmount), _from);
        }

        require(
            totalUserStake[_from].add(_amount) <= stakeToken.balanceOf(_from),
            ERROR_STAKING_MORE_THAN_AVAILABLE
        );

        uint256 previousStake = proposal.stakedTokens;
        proposal.stakedTokens = proposal.stakedTokens.add(_amount);
        proposal.voterStake[_from] = proposal.voterStake[_from].add(_amount);
        totalUserStake[_from] = totalUserStake[_from].add(_amount);
        totalStaked = totalStaked.add(_amount);

        if (proposal.blockLast == 0) {
            proposal.blockLast = getBlockNumber64();
        } else {
            _calculateAndSetConviction(proposal, previousStake);
        }

        _updateVoterStakedProposals(_proposalId, _from);

        emit StakeAdded(
            _from,
            _proposalId,
            _amount,
            proposal.voterStake[_from],
            proposal.stakedTokens,
            proposal.convictionLast
        );
    }
}
