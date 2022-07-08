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


# The testing library uses python's asyncio. So the following
# decorator and the ``async`` keyword are needed.
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

    ## check if the import works
    await contract.write_board_copy(0, 0, 1).invoke()
    execution_info = await contract.view_board_copy(0, 0).call()
    assert execution_info.result == (1,)

    ## check if the import works
    await contract.write_board_copy(1, 2, 2).invoke()
    execution_info = await contract.view_board_copy(1, 2).call()
    assert execution_info.result == (2,)

    ## create a copy of the board in another storage_var
    copy_number = 2
    await contract.create_board_copy(copy_number).invoke()

    board_copy_value = await contract.view_possible_next_boards(copy_number, 0, 0).call()
    assert board_copy_value.result == (1,)
    board_copy_value = await contract.view_possible_next_boards(copy_number, 1, 2).call()
    assert board_copy_value.result == (2,)

    





