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

    // Aqui es mi duda, cada tipo de modulo tiene sus propias settings, por ejemplo las normal conviction voting tienen sus settings, las fluid van a tener sus settings
    // como se podria hacer generico para q los parametros q reciba se manejen desde el modulo  sin el manager tener q hacer nada en especifico?
    function changeModuleSettings(string calldata _proposalType, ...... data){
      IProposalModule(proposalModules[_proposalType].implementation).setSettings(data);
    }
}
