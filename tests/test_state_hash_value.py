"""contract.cairo test file."""
import os

import pytest
from starkware.starknet.testing.starknet import Starknet

# The path to the contract source code.
CONTRACT_FILE_1 = os.path.join("contracts", "board.cairo")
CONTRACT_FILE_2 = os.path.join("contracts", "state_hash_value.cairo")

# The testing library uses python's asyncio. So the following
# decorator and the ``async`` keyword are needed.
@pytest.mark.asyncio
async def test_add_state_hash_value():
    """Test test_add_state_hash_value."""
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()
    # Deploy the contracts
    contract1 = await starknet.deploy(
        source=CONTRACT_FILE_1,
    )
    contract2 = await starknet.deploy(
        source=CONTRACT_FILE_2,
    )

    ## write a new state
    await contract1.write_board(8, 1).invoke()
    ## get the hash of the board
    hash = await contract1.get_state_hash(8, 0).call()
    

    ## write the state_hash_value
    await contract2.write_state_hash_value(hash.result[0], 6).invoke()
    value = await contract2.read_state_hash_value(hash.result[0]).call()
    
    assert value.result[0] == 6
    