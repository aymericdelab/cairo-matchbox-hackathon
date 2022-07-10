"""contract.cairo test file."""
import os
import re

import pytest
from starkware.starknet.testing.starknet import Starknet
from starkware.crypto.signature.signature import (
    pedersen_hash,
    private_to_stark_key,
    sign,
)
from starkware.starkware_utils.error_handling import StarkException

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
    await contract.write_board(0, 1).invoke()
    # Invoke increase_balance() twice.
    await contract.write_board(7, 2).invoke()
    # Invoke increase_balance() twice.
    await contract.write_board(2, 0).invoke()

    # Check the result of get_balance().
    execution_info = await contract.view_board(0).call()
    assert execution_info.result == (1,)

    execution_info = await contract.view_board(7).call()
    assert execution_info.result == (2,)

    execution_info = await contract.view_board(2).call()
    assert execution_info.result == (0,)

    # Should fail
    with pytest.raises(StarkException): 
        await contract.write_board(9, 0).invoke()

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

    # Invoke increase_balance() twice.
    await contract.write_board(0, 1).invoke()
    # Invoke increase_balance() twice.
    await contract.write_board(7, 1).invoke()
    # Invoke increase_balance() twice.
    await contract.write_board(2, 1).invoke()

    # Reset the board
    await contract.reset_board().invoke()

    # Read the board 
    val = await contract.view_board(0).call()
    assert val.result == (0,)
    val = await contract.view_board(1).call()
    assert val.result == (0,)
    val = await contract.view_board(2).call()
    assert val.result == (0,)
    val = await contract.view_board(3).call()
    assert val.result == (0,)
    val = await contract.view_board(4).call()
    assert val.result == (0,)
    val = await contract.view_board(5).call()
    assert val.result == (0,)
    val = await contract.view_board(6).call()
    assert val.result == (0,)
    val = await contract.view_board(7).call()
    assert val.result == (0,)
    val = await contract.view_board(8).call()
    assert val.result == (0,)

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
    execution_info = await contract.view_board(0).call()
    assert execution_info.result == (0,)

    execution_info = await contract.view_board(1).call()
    assert execution_info.result == (0,)

    execution_info = await contract.view_board(2).call()
    assert execution_info.result == (0,)

@pytest.mark.asyncio
async def test_game_number():
    """Test increase_balance method."""
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )

    val = await contract.view_game_number().call()
    assert val.result == (1,)

@pytest.mark.asyncio
async def test_last_winner():
    """Test increase_balance method."""
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )

    await contract.write_winner().invoke()
    val = await contract.view_last_winner().call()
    assert val.result == (1,)

@pytest.mark.asyncio
async def test_winning_state():
    """Test winning state of the contract"""
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    ) 

    await contract.write_board(0, 1).invoke()
    await contract.write_board(1, 1).invoke()
    await contract.write_board(2, 1).invoke()

    val = await contract.is_winning_state().call()
    assert val.result == (1,)

    await contract.reset_board().invoke()

    await contract.write_board(1, 2).invoke()
    await contract.write_board(4, 2).invoke()
    await contract.write_board(7, 2).invoke()

    val = await contract.is_winning_state().call()
    assert val.result == (2,)

    await contract.reset_board().invoke()

    await contract.write_board(0, 2).invoke()
    await contract.write_board(3, 2).invoke()
    await contract.write_board(6, 2).invoke()

    val = await contract.is_winning_state().call()
    assert val.result == (2,)

    await contract.reset_board().invoke()

    await contract.write_board(2, 2).invoke()
    await contract.write_board(5, 2).invoke()
    await contract.write_board(8, 2).invoke()

    val = await contract.is_winning_state().call()
    assert val.result == (2,)

@pytest.mark.asyncio
async def test_get_state_moves_hash():
    """Test get_state_moves_hash"""
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    ) 

    await contract.write_state_moves(0, 3).invoke()
    await contract.write_state_moves(1, 7).invoke()
    await contract.write_state_moves(2, 4).invoke()
    await contract.write_state_moves(3, 5).invoke()
    await contract.write_state_moves(4, 2).invoke()
    await contract.write_state_moves(5, 0).invoke()

    h1 = pedersen_hash(3, 0)
    h2 = pedersen_hash(7, h1)
    h3 = pedersen_hash(4, h2)
    h4 = pedersen_hash(5, h3)
    h5 = pedersen_hash(2, h4)
    h6 = pedersen_hash(0, h5)

    val = await contract.get_state_moves_hash(5, 5, 0).call()
    assert val.result == (h6,)

    val = await contract.get_state_moves_hash(4, 4, 0).call()
    assert val.result == (h5,)

    val = await contract.get_state_moves_hash(3, 3, 0).call()
    assert val.result == (h4,)

    val = await contract.get_state_moves_hash(2, 2, 0).call()
    assert val.result == (h3,)

    val = await contract.get_state_moves_hash(1, 1, 0).call()
    assert val.result == (h2,)

    val = await contract.get_state_moves_hash(0, 0, 0).call()
    assert val.result == (h1,)

