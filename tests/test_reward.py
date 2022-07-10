"""contract.cairo test file."""
import os

import pytest
from starkware.starknet.testing.starknet import Starknet

# The path to the contract source code.
CONTRACT_FILE1 = os.path.join("contracts", "board.cairo")
CONTRACT_FILE2 = os.path.join("contracts", "state_hash_value.cairo")


# The testing library uses python's asyncio. So the following
# decorator and the ``async`` keyword are needed.
@pytest.mark.asyncio
async def test_increase_balance():
    """Test increase_balance method."""
    # Create a new Starknet class that simulates the StarkNet
    # system.
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

    # state_hash = await contract1.get_state_moves_hash(5, 5, 0).call()
    # old_value = await contract2.read_state_hash_value(state_hash.result[0]).call()
    # print(old_value.result[0])

    ## play for both
    await contract1.write_board(0, 1).invoke()
    await contract1.write_board(4, 2).invoke()
    await contract1.write_board(3, 1).invoke()
    await contract1.write_board(7, 2).invoke()
    await contract1.write_board(6, 1).invoke()

    await contract1.update_state_hash_value(5+1, 1, address).invoke()

    state_hash = await contract1.get_state_moves_hash(5, 5, 0).call()
    new_value = await contract2.read_state_hash_value(state_hash.result[0]).call()
    print(new_value.result[0])