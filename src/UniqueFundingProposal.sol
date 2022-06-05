// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import {Module} from "zodiac/core/Module.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IAvatar} from "zodiac/interfaces/IAvatar.sol";

contract UniqueFundingProposal is Module {
    using SafeERC20 for ERC20;

    ERC20 public stakeToken;
    address public requestToken;
    uint256 public decay;
    uint256 public maxRatio;
    uint256 public weight;
    uint256 public minThresholdStakePercentage;

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
}
