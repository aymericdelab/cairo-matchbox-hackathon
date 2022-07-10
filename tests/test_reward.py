"""contract.cairo test file."""
import os
import math


import pytest
from starkware.starknet.testing.starknet import Starknet

# The path to the contract source code.
CONTRACT_FILE1 = os.path.join("contracts", "board.cairo")
CONTRACT_FILE2 = os.path.join("contracts", "state_hash_value.cairo")


def calculate_new_reward(old_state_value, reward):
    discounted_reward = 9*reward
    discounted_reward = math.floor(discounted_reward/10)
    lr_value_increment = 2 * (discounted_reward - old_state_value)
    lr_value_increment = math.floor(lr_value_increment/10)
    reward = old_state_value + lr_value_increment
    return reward 

# The testing library uses python's asyncio. So the following
# decorator and the ``async`` keyword are needed.
@pytest.mark.asyncio
async def test_reward():
    """Check if the correct values are changed in the state_hash_value contract"""
    # Create a new Starknet class that simulates the StarkNet
    # system.
    print()

    starknet = await Starknet.empty()

    # Deploy the contract.
    contract1 = await starknet.deploy(
        source=CONTRACT_FILE1,
    )

    # Deploy the contract.
    contract2 = await starknet.deploy(
        source=CONTRACT_FILE2,
    )

    address = contract2.contract_address
    multiplication_factor = 1000000


    # size = nb moves
    await contract1.write_board(0, 1).invoke()
    await contract1.write_board(4, 2).invoke()
    await contract1.write_board(7, 1).invoke()
    await contract1.write_board(3, 2).invoke()
    await contract1.write_board(6, 1).invoke()
    await contract1.write_board(5, 2).invoke()


    await contract1.update_state_hash_value(5, multiplication_factor, address).invoke()

    ## starting with size-1 (5)
    state_hash = await contract1.get_state_moves_hash(5, 5, 0).call()
    new_value = await contract2.read_state_hash_value(state_hash.result[0]).call()
    print(new_value.result[0])

    state_hash = await contract1.get_state_moves_hash(4, 4, 0).call()
    new_value = await contract2.read_state_hash_value(state_hash.result[0]).call()
    print(new_value.result[0])

    state_hash = await contract1.get_state_moves_hash(3, 3, 0).call()
    new_value = await contract2.read_state_hash_value(state_hash.result[0]).call()
    print(new_value.result[0])

    state_hash = await contract1.get_state_moves_hash(2, 2, 0).call()
    new_value = await contract2.read_state_hash_value(state_hash.result[0]).call()
    print(new_value.result[0])

    state_hash = await contract1.get_state_moves_hash(1, 1, 0).call()
    new_value = await contract2.read_state_hash_value(state_hash.result[0]).call()
    print(new_value.result[0])

    state_hash = await contract1.get_state_moves_hash(0, 0, 0).call()
    new_value = await contract2.read_state_hash_value(state_hash.result[0]).call()
    print(new_value.result[0])


    # size = nb moves
    await contract1.write_board(0, 1).invoke()
    await contract1.write_board(4, 2).invoke()
    await contract1.write_board(7, 1).invoke()
    await contract1.write_board(3, 2).invoke()
    await contract1.write_board(6, 1).invoke()
    await contract1.write_board(5, 2).invoke()


    await contract1.update_state_hash_value(5, multiplication_factor, address).invoke()

    ## starting with size-1 (5)
    state_hash = await contract1.get_state_moves_hash(5, 5, 0).call()
    new_value = await contract2.read_state_hash_value(state_hash.result[0]).call()
    print(new_value.result[0])

    state_hash = await contract1.get_state_moves_hash(4, 4, 0).call()
    new_value = await contract2.read_state_hash_value(state_hash.result[0]).call()
    print(new_value.result[0])

    state_hash = await contract1.get_state_moves_hash(3, 3, 0).call()
    new_value = await contract2.read_state_hash_value(state_hash.result[0]).call()
    print(new_value.result[0])

    state_hash = await contract1.get_state_moves_hash(2, 2, 0).call()
    new_value = await contract2.read_state_hash_value(state_hash.result[0]).call()
    print(new_value.result[0])

    state_hash = await contract1.get_state_moves_hash(1, 1, 0).call()
    new_value = await contract2.read_state_hash_value(state_hash.result[0]).call()
    print(new_value.result[0])

    state_hash = await contract1.get_state_moves_hash(0, 0, 0).call()
    new_value = await contract2.read_state_hash_value(state_hash.result[0]).call()
    print(new_value.result[0])
