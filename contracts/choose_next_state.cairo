%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.math import assert_nn_le, unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le
from starkware.starknet.common.syscalls import get_block_timestamp

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
func size_possible() -> (size : felt):
end

@storage_var
func board(i : felt) -> (res : felt):
end

# test
# function to have access to the board for testing
func view_possible_next_boards{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(k : felt, i : felt) -> (res : felt):
    let (res : felt) = possible_next_boards.read(k, i)
    return (res)
end

func view_best_next_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(i : felt) -> (res : felt):
    let (res : felt) = best_next_board.read(i)
    return (res)
end

func view_size{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (size : felt):
    let (size) = size_possible.read()
    return (size)
end

@view
func view_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(i : felt) -> (board_value : felt):
    let (val) = board.read(i)
    return (val)
end

# test
# function to have access to the board for testing
func write_possible_next_boards{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}( k : felt, i : felt, value : felt) -> ():
    assert_nn_le(i, 8)
    assert_nn_le(value, 2)
    possible_next_boards.write(k, i, value)
    return ()
end

# test
func write_best_next_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(i : felt, value : felt) -> ():
    assert_nn_le(i, 8)
    assert_nn_le(value, 2)
    best_next_board.write(i, value)
    return ()
end

func write_size{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(size : felt) -> ():
    size_possible.write(size)
    return()
end

# TEST
func write_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(i : felt, value : felt) -> ():
    assert_nn_le(i, 8)
    assert_nn_le(value, 2)
    board.write(i, value)
    return ()
end

func reset_best_next_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> ():
    write_best_next_board(0, 0)
    write_best_next_board(1, 0)
    write_best_next_board(2, 0)
    write_best_next_board(3, 0)
    write_best_next_board(4, 0)
    write_best_next_board(5, 0)
    write_best_next_board(6, 0)
    write_best_next_board(7, 0)
    write_best_next_board(8, 0)
    return()
end

# # get the hash of the best next board, use it to compare it to the next_board
func get_hash_best_next_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(size : felt, hash : felt) -> (hash : felt):
    let (board_value : felt) = best_next_board.read(8-size)
    let (h) = hash2{hash_ptr=pedersen_ptr}(board_value, hash)

    if size == 0 :
        return (h)
    end

    return get_hash_best_next_board(size-1, h)
end

# # get the hash of the next board, use it to compare it to the best_next_board
func get_hash_possible_next_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(k : felt, size : felt, hash : felt) -> ( hash : felt):
    let (board_value : felt) = possible_next_boards.read(k, 8-size)
    let (h) = hash2{hash_ptr=pedersen_ptr}(board_value, hash)

    if size == 0 :
        return (h)
    end

    return get_hash_possible_next_board(k, size-1, h)
end

func create_possible_next_boards{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(k : felt, size : felt) -> ():
    let value : felt = view_board(size) 
    write_possible_next_boards(k, size, value)

    if size == 0:
        return ()
    end

    return create_possible_next_boards(k, size-1) 
end

func create_best_next_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(k : felt, size : felt) -> ():
    let value : felt = view_possible_next_boards(k, size) 
    write_best_next_board(size, value)

    if size == 0:
        return ()
    end

    return create_best_next_board(k, size-1) 
end

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

# Start with k=0, i=9, last=0 and add=state_hash_value contract address
func choose{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(k : felt, i : felt, last : felt, add : felt) -> ():
    alloc_locals
    create_possible_next_boards(k, 8)

    if i == 0:
        return()
    end
    
    let (val) = view_possible_next_boards(k, 9-i)
    if val != 0:
        choose(k, i-1, last, add)
        return()
    end
    
    write_possible_next_boards(k, 9-i, 2)
    choose(k+1, i-1, i, add)
    write_size(k+1)
    get_best_next_board(k, add)
    return ()
end

func get_diff_boards{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(size : felt) -> (val : felt):
    if size == 0:
        return(size)
    end
    let (best) = view_best_next_board(size)
    let (board) = view_board(size)
    if best == board:
        let (val : felt) = get_diff_boards(size-1)
        return(val) 
    end
    return (size)
end

func do_random{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (spot : felt):
    alloc_locals
    let (block_timestamp) = get_block_timestamp()
    let (_, local mod) = unsigned_div_rem(block_timestamp, 100)
    let (s) = circle_valid_moves(mod)
    return(s) 
end

func make_random_move{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (rand : felt):
    alloc_locals
    let (block_timestamp) = get_block_timestamp()
    let (_, local mod) = unsigned_div_rem(block_timestamp, 100)
    let (val) = is_le(mod, 30)
    if val == 1:
        let (spot) = circle_valid_moves(mod)
        return (spot)
    end
    return(10)
end

func circle_valid_moves{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(val : felt) -> (spot : felt):
    alloc_locals
    let (_, local mod) = unsigned_div_rem(val, 9) 
    let (b) = view_board(mod)
    if b == 0:
        write_board(mod, 2) 
        return(mod)
    end
    let (spot) = circle_valid_moves(mod+1)
    return(spot)
end

# give size as 9 for a 3*3 game
func check_empty{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(size : felt) -> (empty : felt):
    if size == 0:
        return (1)
    end
    let (b) = view_best_next_board(size-1)
    if b == 0:
        let (re) = check_empty(size-1)
        return (re)      
    end
    return (0)
end