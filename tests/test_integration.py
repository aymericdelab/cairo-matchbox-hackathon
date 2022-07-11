"""contract.cairo test file."""
import os

import pytest
import random
from starkware.starknet.testing.starknet import Starknet
from starkware.crypto.signature.signature import (
    pedersen_hash,
    private_to_stark_key,
    sign,
)

# The path to the contract source code.
CONTRACT_FILE = os.path.join("contracts", "board.cairo")

def rand_gen():
    rand = []
    while len(rand) < 9: 
        i = random.randint(0, 8)
        if not (i in rand):
            rand.append(i) 
    return rand


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

    await contract.write_board(1, 1).invoke()
    await contract.write_board(4, 1).invoke()
    await contract.write_board(5, 1).invoke()
    await contract.write_board(6, 1).invoke()
    await contract.write_board(2, 2).invoke()
    await contract.write_board(3, 2).invoke()
    await contract.write_board(7, 2).invoke()
    await contract.write_board(8, 2).invoke()

    await contract.write_num_moves(8).invoke()
    val = await contract.is_winning_state().call()
    print("WINNING STATE", val.result)
    val = await contract.view_num_moves().call()
    print("NUM MOVES", val.result)

    await contract.play(0, state_hash.contract_address).invoke()
    for i in range(9):
        val = await contract.view_board(i).call()
        print(val.result[0])

    # await contract.play(0, state_hash.contract_address).invoke()
    # spots = [0]
    # for i in range(9):
    #     val = await contract.view_board(i).call()
    #     if val.result[0] == 2:
    #         spots.append(i)
    #     print(val.result[0])

    # print("NEXT", spots)
    # rand = rand_gen()
    # for i in rand:
    #     if not (i in spots):
    #         await contract.play(i, state_hash.contract_address).invoke()
    #         break
    # spots = []
    # for i in range(9):
    #     val = await contract.view_board(i).call()
    #     if val.result[0] != 0:
    #         spots.append(i)
    #     print(val.result[0])

    # print("NEXT")
    # rand = rand_gen()
    # for i in rand:
    #     if not (i in spots):
    #         await contract.play(i, state_hash.contract_address).invoke()
    #         break
    # spots = []
    # for i in range(9):
    #     val = await contract.view_board(i).call()
    #     if val.result[0] != 0:
    #         spots.append(i)
    #     print(val.result[0])