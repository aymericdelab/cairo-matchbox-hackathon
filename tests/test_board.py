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


# The testing library uses python's asyncio. So the following
# decorator and the ``async`` keyword are needed.
@pytest.mark.asyncio
async def test_write_board():
    """Test increase_balance method."""
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )

    # Invoke increase_balance() twice.
    await contract.write_board(0, 0, 0).invoke()
    # Invoke increase_balance() twice.
    await contract.write_board(3, 1, 1).invoke()
    # Invoke increase_balance() twice.
    await contract.write_board(0, 2, 0).invoke()

    # Check the result of get_balance().
    execution_info = await contract.read_board(0, 0).call()
    assert execution_info.result == (0,)

    execution_info = await contract.read_board(3, 1).call()
    assert execution_info.result == (1,)

    execution_info = await contract.read_board(0, 2).call()
    assert execution_info.result == (0,)

# The testing library uses python's asyncio. So the following
# decorator and the ``async`` keyword are needed.
@pytest.mark.asyncio
async def test_initial_board():
    """Test increase_balance method."""
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )

    # Check the result of get_balance().
    execution_info = await contract.read_board(0, 0).call()
    assert execution_info.result == (0,)

    execution_info = await contract.read_board(0, 1).call()
    assert execution_info.result == (0,)

    execution_info = await contract.read_board(0, 2).call()
    assert execution_info.result == (0,)

