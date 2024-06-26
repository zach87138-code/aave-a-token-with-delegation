import {EthereumScript} from 'aave-helpers/ScriptUtils.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {IPool, ATokenWithDelegation} from '../src/contracts/ATokenWithDelegation.sol';
import {IAaveIncentivesController} from 'aave-v3-origin/contracts/interfaces/IAaveIncentivesController.sol';

contract DeployAAaveToken is EthereumScript {
  function run() external broadcast {
    ATokenWithDelegation aAaveToken = new ATokenWithDelegation(IPool(address(AaveV3Ethereum.POOL)));

    aAaveToken.initialize(
      IPool(address(AaveV3Ethereum.POOL)),
      AaveV3EthereumAssets.AAVE_UNDERLYING,
      address(AaveV3Ethereum.COLLECTOR),
      IAaveIncentivesController(AaveV3Ethereum.DEFAULT_INCENTIVES_CONTROLLER),
      18,
      'Aave Ethereum AAVE',
      'aEthAAVE',
      bytes('')
    );
  }
}
