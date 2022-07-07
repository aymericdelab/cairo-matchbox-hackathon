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
    
    # Invoke increase_balance() twice.
    await contract.write_board(2, 2, 1).invoke()

    h1 = pedersen_hash(0, 0)
    h2 = pedersen_hash(0, h1)
    h3 = pedersen_hash(0, h2)
    h4 = pedersen_hash(0, h3)
    h5 = pedersen_hash(0, h4)
    h6 = pedersen_hash(0, h5)
    h7 = pedersen_hash(0, h6)
    h8 = pedersen_hash(0, h7)
    h9 = pedersen_hash(1, h8)

    # Check the result of get_balance().
    execution_info = await contract.get_state_hash().call()
    print('Hash starknet')
    print(execution_info.result)
    print()
    print()
    print(' Hash Python')
    print(h9)

    assert execution_info.result == (h9,)