"""contract.cairo test file."""
import os

import pytest
from starkware.starknet.testing.starknet import Starknet

# The path to the contract source code.
CONTRACT_FILE = os.path.join("contracts", "player.cairo")

# The testing library uses python's asyncio. So the following
# decorator and the ``async`` keyword are needed.
@pytest.mark.asyncio
async def test_reset_board():
    """Test increase_balance method."""
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )

    # Reset the board
    await contract.reset().invoke()

    # Read the board 
    val = await contract.view_board(0,0).call()
    assert val.result == (0,)
    val = await contract.view_board(0,1).call()
    assert val.result == (0,)
    val = await contract.view_board(0,2).call()
    assert val.result == (0,)
    val = await contract.view_board(1,0).call()
    assert val.result == (0,)
    val = await contract.view_board(1,1).call()
    assert val.result == (0,)
    val = await contract.view_board(1,2).call()
    assert val.result == (0,)
    val = await contract.view_board(2,0).call()
    assert val.result == (0,)
    val = await contract.view_board(2,1).call()
    assert val.result == (0,)
    val = await contract.view_board(2,2).call()
    assert val.result == (0,)