%lang starknet


from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.math import assert_nn_le
from starkware.cairo.common.math_cmp import is_le

from contracts.board import view_board, write_board
from contracts.state_hash_value import read_state_hash_value

@contract_interface
namespace IStateHashValueContract:
    func read_state_hash_value(state_hash : felt) -> (value : felt):
    end

    func write_state_hash_value(state_hash : felt, value : felt) -> ():
    end
end

# # possible next boards, should be k different boards depending on the number of possible moves
@storage_var
func possible_next_boards(k : felt, i : felt) -> (res : felt):
end

# # the best next board at the moment (only one, that will be rewrittent everytime we have found a new best board)
@storage_var
func best_next_board(i : felt) -> (res : felt):
end

@storage_var
func board_copy(i : felt) -> (res : felt):
end

# test
# function to have access to the board for testing
# # view function
@view
func view_possible_next_boards{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(k : felt, i : felt) -> (res : felt):
    let (res : felt) = possible_next_boards.read(k, i)
    return (res)
end

@view
func view_best_next_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(i : felt) -> (res : felt):
    let (res : felt) = best_next_board.read(i)
    return (res)
end

@view
func view_board_copy{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(i : felt) -> (value : felt):
    let (value : felt) = board_copy.read(i)
    return (value)
end

# # get the hash of the best next board, use it to compare it to the next_board
@external
func get_hash_best_next_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(size : felt, hash : felt) -> (hash : felt):
    let (board_value : felt) = best_next_board.read(8-size)
    let (h) = hash2{hash_ptr=pedersen_ptr}(board_value, hash)

    if size == 0 :
        return (h)
    end

    return get_hash_best_next_board(size-1, h)
end

# # get the hash of the next board, use it to compare it to the best_next_board
@external
func get_hash_possible_next_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(k : felt, size : felt, hash : felt) -> ( hash : felt):
    let (board_value : felt) = possible_next_boards.read(k, 8-size)
    let (h) = hash2{hash_ptr=pedersen_ptr}(board_value, hash)

    if size == 0 :
        return (h)
    end

    return get_hash_possible_next_board(k, size-1, h)
end

# test
# function to have access to the board for testing
@external
func write_possible_next_boards{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}( k : felt, i : felt, value : felt) -> ():
    assert_nn_le(i, 8)
    assert_nn_le(value, 2)
    possible_next_boards.write(k, i, value)
    return ()
end

@external
func write_best_next_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(i : felt, value : felt) -> ():
    assert_nn_le(i, 8)
    assert_nn_le(value, 2)
    best_next_board.write(i, value)
    return ()
end

@external
func write_board_copy{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(i : felt, value : felt) -> ():
    assert_nn_le(i, 8)
    assert_nn_le(value, 2)
    board_copy.write(i, value)
    return ()
end

@external
func create_possible_next_boards{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(k : felt, size : felt) -> ():
    let value : felt = view_board_copy(size) 
    write_possible_next_boards(k, size, value)

    if size == 0:
        return ()
    end

    return create_possible_next_boards(k, size-1) 
end

@external
func create_best_next_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(k : felt, size : felt) -> ():
    let value : felt = view_possible_next_boards(k, size) 
    write_best_next_board(size, value)

    if size == 0:
        return ()
    end

    return create_best_next_board(k, size-1) 
end

@external
func test_best_next_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(k : felt) -> (res : felt):
   alloc_locals
    let (local h1) = get_hash_best_next_board(8, 0)
    let (local h2) = get_hash_possible_next_board(k, 8, 0)
    return (h1)
end

@external
func get_best_next_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(k : felt, add : felt) -> ():
    alloc_locals
    let (local h1) = get_hash_best_next_board(8, 0)
    let (local h2) = get_hash_possible_next_board(k, 8, 0)
    let (bnb) = IStateHashValueContract.read_state_hash_value(contract_address=add, state_hash=h1)
    let (pnb) = IStateHashValueContract.read_state_hash_value(contract_address=add, state_hash=h2)
    let (le) = is_le(pnb, bnb)
    if le == 1:
        return ()
    end
    create_best_next_board(k, 8)
    return ()
end

@external
func choose{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> ():
    return ()
end
