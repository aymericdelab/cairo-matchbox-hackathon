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
CONTRACT_FILE = os.path.join("contracts", "choose_next_state.cairo")


@pytest.mark.asyncio
async def test_copy_board():
    ''' test the copy of a board in another storage_var'''
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()


    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )

    ## create a copy of the board in another storage_var
    copy_number = 2
    await contract.write_board(6, 1).invoke()
    await contract.write_board(5, 2).invoke()
    await contract.create_possible_next_boards(copy_number, 8).invoke()

    board_copy_value = await contract.view_possible_next_boards(copy_number, 6).call()
    assert board_copy_value.result == (1,)
    board_copy_value = await contract.view_possible_next_boards(copy_number, 5).call()
    assert board_copy_value.result == (2,)


@pytest.mark.asyncio
async def test_get_hash_possible_next_boards():
    ''' test storage hashing '''
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )
    
    # Invoke increase_balance() twice.
    await contract.write_possible_next_boards(10, 2, 2).invoke()
    await contract.write_possible_next_boards(10, 4, 1).invoke()

    h1 = pedersen_hash(0, 0)
    h2 = pedersen_hash(0, h1)
    h3 = pedersen_hash(2, h2)
    h4 = pedersen_hash(0, h3)
    h5 = pedersen_hash(1, h4)
    h6 = pedersen_hash(0, h5)
    h7 = pedersen_hash(0, h6)
    h8 = pedersen_hash(0, h7)
    h9 = pedersen_hash(0, h8)

    # Check the result of get_balance().
    execution_info = await contract.get_hash_possible_next_board(10, 8, 0).call()
    assert execution_info.result == (h9,)

@pytest.mark.asyncio
async def test_get_hash_best_next_board():
    ''' test storage hashing '''
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )
    
    # Invoke increase_balance() twice.
    await contract.write_best_next_board(1, 2).invoke()
    await contract.write_best_next_board(5, 1).invoke()
    await contract.write_best_next_board(8, 1).invoke()

    h1 = pedersen_hash(0, 0)
    h2 = pedersen_hash(2, h1)
    h3 = pedersen_hash(0, h2)
    h4 = pedersen_hash(0, h3)
    h5 = pedersen_hash(0, h4)
    h6 = pedersen_hash(1, h5)
    h7 = pedersen_hash(0, h6)
    h8 = pedersen_hash(0, h7)
    h9 = pedersen_hash(1, h8)
    print(h9)

    # Check the result of get_balance().
    execution_info = await contract.get_hash_best_next_board(8, 0).call()
    assert execution_info.result == (h9,)

@pytest.mark.asyncio
async def test_get_best_next_board():
    ''' test get_best_next_board '''
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract_choose = await starknet.deploy(
        source=CONTRACT_FILE,
    ) 
    contract_state_hash = await starknet.deploy(
        source="contracts/state_hash_value.cairo",
    ) 

    await contract_choose.write_best_next_board(1, 2).invoke()
    await contract_choose.write_best_next_board(5, 1).invoke()
    await contract_choose.write_best_next_board(8, 1).invoke()

    await contract_choose.write_possible_next_boards(4, 2, 2).invoke()
    await contract_choose.write_possible_next_boards(4, 4, 1).invoke()

    h1 = pedersen_hash(0, 0)
    h2 = pedersen_hash(2, h1)
    h3 = pedersen_hash(0, h2)
    h4 = pedersen_hash(0, h3)
    h5 = pedersen_hash(0, h4)
    h6 = pedersen_hash(1, h5)
    h7 = pedersen_hash(0, h6)
    h8 = pedersen_hash(0, h7)
    hbnb = pedersen_hash(1, h8)

    h1 = pedersen_hash(0, 0)
    h2 = pedersen_hash(0, h1)
    h3 = pedersen_hash(2, h2)
    h4 = pedersen_hash(0, h3)
    h5 = pedersen_hash(1, h4)
    h6 = pedersen_hash(0, h5)
    h7 = pedersen_hash(0, h6)
    h8 = pedersen_hash(0, h7)
    hpnb = pedersen_hash(0, h8)

    await contract_state_hash.write_state_hash_value(hbnb, 10).invoke()
    await contract_state_hash.write_state_hash_value(hpnb, 12).invoke()

    await contract_choose.get_best_next_board(4, contract_state_hash.contract_address).invoke()

    val = await contract_choose.view_best_next_board(0).call()
    assert val.result == (0,)
    val = await contract_choose.view_best_next_board(1).call()
    assert val.result == (0,)
    val = await contract_choose.view_best_next_board(2).call()
    assert val.result == (2,)
    val = await contract_choose.view_best_next_board(3).call()
    assert val.result == (0,)
    val = await contract_choose.view_best_next_board(4).call()
    assert val.result == (1,)
    val = await contract_choose.view_best_next_board(5).call()
    assert val.result == (0,)
    val = await contract_choose.view_best_next_board(6).call()
    assert val.result == (0,)
    val = await contract_choose.view_best_next_board(7).call()
    assert val.result == (0,)
    val = await contract_choose.view_best_next_board(8).call()
    assert val.result == (0,)

@pytest.mark.asyncio
async def test_choose():
    ''' test choose '''
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract_choose = await starknet.deploy(
        source=CONTRACT_FILE,
    ) 
    contract_state_hash = await starknet.deploy(
        source="contracts/state_hash_value.cairo",
    ) 


    await contract_choose.write_board(0, 1).invoke()
    await contract_choose.write_board(2, 2).invoke()
    await contract_choose.write_board(4, 1).invoke()
    await contract_choose.write_board(5, 1).invoke()
    await contract_choose.write_board(6, 2).invoke()

    h1 = pedersen_hash(1, 0)
    h2 = pedersen_hash(1, h1)
    h3 = pedersen_hash(2, h2)
    h4 = pedersen_hash(0, h3)
    h5 = pedersen_hash(1, h4)
    h6 = pedersen_hash(1, h5)
    h7 = pedersen_hash(2, h6)
    h8 = pedersen_hash(0, h7)
    s1 = pedersen_hash(0, h8)

    h1 = pedersen_hash(1, 0)
    h2 = pedersen_hash(0, h1)
    h3 = pedersen_hash(2, h2)
    h4 = pedersen_hash(1, h3)
    h5 = pedersen_hash(1, h4)
    h6 = pedersen_hash(1, h5)
    h7 = pedersen_hash(2, h6)
    h8 = pedersen_hash(0, h7)
    s2 = pedersen_hash(0, h8)

    h1 = pedersen_hash(1, 0)
    h2 = pedersen_hash(0, h1)
    h3 = pedersen_hash(2, h2)
    h4 = pedersen_hash(0, h3)
    h5 = pedersen_hash(1, h4)
    h6 = pedersen_hash(1, h5)
    h7 = pedersen_hash(2, h6)
    h8 = pedersen_hash(1, h7)
    s3 = pedersen_hash(0, h8)

    h1 = pedersen_hash(1, 0)
    h2 = pedersen_hash(0, h1)
    h3 = pedersen_hash(2, h2)
    h4 = pedersen_hash(0, h3)
    h5 = pedersen_hash(1, h4)
    h6 = pedersen_hash(1, h5)
    h7 = pedersen_hash(2, h6)
    h8 = pedersen_hash(0, h7)
    s4 = pedersen_hash(1, h8)

    await contract_state_hash.write_state_hash_value(s1, 10).invoke()
    await contract_state_hash.write_state_hash_value(s2, 30).invoke()
    await contract_state_hash.write_state_hash_value(s3, 15).invoke()
    await contract_state_hash.write_state_hash_value(s4, 31).invoke()

    await contract_choose.choose(0, 9, 0, contract_state_hash.contract_address).invoke()
    
    val = await contract_choose.view_best_next_board(0).call()
    assert val.result == (1,)
    val = await contract_choose.view_best_next_board(1).call()
    assert val.result == (0,)
    val = await contract_choose.view_best_next_board(2).call()
    assert val.result == (2,)
    val = await contract_choose.view_best_next_board(3).call()
    assert val.result == (0,)
    val = await contract_choose.view_best_next_board(4).call()
    assert val.result == (1,)
    val = await contract_choose.view_best_next_board(5).call()
    assert val.result == (1,)
    val = await contract_choose.view_best_next_board(6).call()
    assert val.result == (2,)
    val = await contract_choose.view_best_next_board(7).call()
    assert val.result == (0,)
    val = await contract_choose.view_best_next_board(8).call()
#     assert val.result == (1,) 

@pytest.mark.asyncio
async def test_get_diff_boards():
    ''' test get_diff_boards '''
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    ) 

    await contract.write_board(1, 1).invoke()
    await contract.write_board(2, 2).invoke()
    await contract.write_board(4, 1).invoke()
    await contract.write_board(5, 1).invoke()
    await contract.write_board(6, 2).invoke()

    await contract.write_best_next_board(0, 2).invoke()
    await contract.write_best_next_board(1, 1).invoke()
    await contract.write_best_next_board(2, 2).invoke()
    await contract.write_best_next_board(4, 1).invoke()
    await contract.write_best_next_board(5, 1).invoke()
    await contract.write_best_next_board(6, 2).invoke()

    val = await contract.get_diff_boards(8).call()
    assert val.result == (0,)

    await contract.write_best_next_board(0, 0).invoke()
    await contract.write_best_next_board(8, 1).invoke()
    val = await contract.get_diff_boards(8).call()
    assert val.result == (8,)


    await contract.write_best_next_board(8, 0).invoke()
    await contract.write_best_next_board(1, 0).invoke()
    val = await contract.get_diff_boards(8).call()
    assert val.result == (1,)

@pytest.mark.asyncio
async def test_circle_valid_moves():
    ''' test circle_valid_moves '''
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    ) 

    await contract.circle_valid_moves(21).invoke()
    val = await contract.view_board(5).call()
    assert val.result == (2,)

    await contract.circle_valid_moves(17).invoke()
    val = await contract.view_board(1).call()
    assert val.result == (2,)
    
    await contract.circle_valid_moves(17).invoke()
    val = await contract.view_board(2).call()
    assert val.result == (2,)

@pytest.mark.asyncio
async def test_make_random_move():
    ''' test make_random_move '''
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    ) 

    val = await contract.make_random_move().invoke()
    assert val.result == (1,)
    val = await contract.view_board(0).call()
    assert val.result == (2,)

    val = await contract.make_random_move().invoke()
    assert val.result == (1,)
    val = await contract.view_board(1).call()
    assert val.result == (2,)

    val = await contract.make_random_move().invoke()
    assert val.result == (1,)
    val = await contract.view_board(2).call()
    assert val.result == (2,)

    val = await contract.make_random_move().invoke()
    assert val.result == (1,)
    val = await contract.view_board(3).call()
    assert val.result == (2,)