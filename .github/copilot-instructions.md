# Use when: editing Solidity, Foundry tests, Certora specs, or storage layout in this repository. Follow these conventions for aToken, delegation, proxy compatibility, and test/lint/build commands.

# Repository Guidelines

## Build, test, and lint

- `make build` runs `forge build --sizes --via-ir`.
- `make test` runs the Foundry suite with verbose traces. For one test, use a path and test-name filter, for example:
  `forge test --match-path tests/ATokenWithDelegation.t.sol --match-test test_mintAffectsDelegation -vvv`
- The integration tests fork Ethereum mainnet at a fixed block and need `RPC_MAINNET` in `.env` (see `.env.example`). Run one with:
  `forge test --match-path tests/ATokenWithDelegationIntegration.t.sol --match-test testTransferAlsoMovesDelegation -vvv`
- `yarn lint --check` checks formatting with Prettier. Solidity and TypeScript formatting options are in `.prettierrc`.

## Architecture

- `AToken` is the Aave v3 interest-bearing token implementation: it handles pool-only mint/burn operations, scaled balances and index-based displayed balances, underlying transfers, transfer validation, and EIP-712 permits. Its accounting is layered through `ScaledBalanceTokenBase`, `MintableIncentivizedERC20`, and `IncentivizedERC20`.
- `ATokenWithDelegation` combines `AToken` with `BaseDelegation` from the `aave-token-v3` dependency. Its `_transfer`, `_mint`, and `_burn` overrides update delegated voting/proposition balances alongside the token balances, including transfers initiated for liquidation; preserve this synchronization when changing token accounting or delegation behavior.
- This contract is intended as an upgradeable aToken implementation. Existing inherited storage layout matters; inspect `diffs/` and the `storage-diff` target in the `Makefile` before changing storage declarations or inheritance.
- `tests/ATokenWithDelegation.t.sol` covers delegation behavior using the shared mock-based `DelegationBaseTest`; `tests/ATokenWithDelegationIntegration.t.sol` exercises the implementation through the deployed proxy on a mainnet fork. `certora/` contains formal verification harnesses, rules, and configurations.

## Conventions

- Solidity dependencies are brought in through Foundry submodules and `remappings.txt`; prefer the configured import paths and existing upstream abstractions over duplicating dependency logic.
- Keep proxy storage additions and inheritance changes deliberate: the project tracks upstream Aave implementation differences and storage layouts in `diffs/`.
- Preserve the inherited pool authorization and transfer-validation behavior when changing public entry points or internal token hooks.
- Foundry unit tests use `forge-std/Test.sol`; test functions use Foundry's `test...` discovery naming, and integration tests that depend on fork state should remain separate from mock-based unit tests.
