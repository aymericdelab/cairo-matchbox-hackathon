"""contract.cairo test file."""
import os

import pytest
from starkware.starknet.testing.starknet import Starknet
from starkware.crypto.signature.signature import (
    pedersen_hash,
    private_to_stark_key,
    sign,
)

# The path to the contract source code.
CONTRACT_FILE = os.path.join("contracts", "board.cairo")


@pytest.mark.asyncio
async def test_state_hash():
    """Test increase_balance method."""
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )

    state_hash = await starknet.deploy(
        source="contracts/state_hash_value.cairo",
    )

    await contract.play(2, state_hash.contract_address).invoke()
    for i in range(9):
        val = await contract.view_board(i).call()
        print(val.result)

    print("NEXT")
    await contract.play(5, state_hash.contract_address).invoke()
    for i in range(9):
        val = await contract.view_board(i).call()
        print(val.result)

    print("NEXT")
    await contract.play(8, state_hash.contract_address).invoke()
    for i in range(9):
        val = await contract.view_board(i).call()
        print(val.result)