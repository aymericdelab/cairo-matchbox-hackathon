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



    ## first party
    number_of_moves = 6
    ## play for both
    await contract1.write_board(0, 1).invoke()
    await contract1.write_board(4, 2).invoke()
    await contract1.write_board(3, 1).invoke()
    await contract1.write_board(7, 2).invoke()
    await contract1.write_board(6, 1).invoke()
    await contract1.write_board(6, 2).invoke()

    old_state_values = []
    for i in reversed(range(0, number_of_moves+1)):
        state_hash = await contract1.get_state_moves_hash(i, i, 0).call()
        old_value = await contract2.read_state_hash_value(state_hash.result[0]).call()
        #old_state_values.append(old_value.result[0])
        old_state_values.insert(0,old_value.result[0])

    print('Old values ...', old_state_values)

    await contract1.update_state_hash_value(number_of_moves+1, multiplication_factor, address).invoke()

    for i in reversed(range(0, number_of_moves+1)):
        old_state_value = old_state_values[i] 
        state_hash = await contract1.get_state_moves_hash(i, i, 0).call()
        new_value = await contract2.read_state_hash_value(state_hash.result[0]).call()
        if i%2 == 0:
            print('Human Player: ')
            print(new_value.result[0])
            assert new_value.result[0] == 0
        else:
            print('The AI: ')
            print('In the contract: ', new_value.result[0])
            print('In the test: ', new_value.result[0])
            assert new_value.result[0] != 0
            if i == number_of_moves:
                new_reward = calculate_new_reward(old_state_value, multiplication_factor)
            else:
                new_reward = calculate_new_reward(old_state_value, new_reward)
            assert new_reward ==  new_value.result[0]


    # ## second party
    # number_of_moves = 5
    # ## play for both
    # await contract1.write_board(0, 2).invoke()
    # await contract1.write_board(4, 1).invoke()
    # await contract1.write_board(3, 2).invoke()
    # await contract1.write_board(7, 1).invoke()
    # await contract1.write_board(6, 2).invoke()

    # old_state_values = []
    # for i in reversed(range(0, number_of_moves+1)):
    #     state_hash = await contract1.get_state_moves_hash(i, i, 0).call()
    #     old_value = await contract2.read_state_hash_value(state_hash.result[0]).call()
    #     #old_state_values.append(old_value.result[0])
    #     old_state_values.insert(0,old_value.result[0])

    # print('Old values ...', old_state_values)

    # await contract1.update_state_hash_value(number_of_moves+1, multiplication_factor, address).invoke()

    # for i in reversed(range(0, number_of_moves+1)):
    #     old_state_value = old_state_values[i] 
    #     state_hash = await contract1.get_state_moves_hash(i, i, 0).call()
    #     new_value = await contract2.read_state_hash_value(state_hash.result[0]).call()
    #     if i%2 == 0:
    #         print('Human Player: ')
    #         print(new_value.result[0])
    #         assert new_value.result[0] == 0
    #     else:
    #         print('The AI: ')
    #         print('In the contract: ', new_value.result[0])
    #         print('In the test: ', new_value.result[0])
    #         assert new_value.result[0] != 0
    #         if i == number_of_moves:
    #             new_reward = calculate_new_reward(old_state_value, multiplication_factor)
    #         else:
    #             new_reward = calculate_new_reward(old_state_value, new_reward)
    #         assert new_reward ==  new_value.result[0]
