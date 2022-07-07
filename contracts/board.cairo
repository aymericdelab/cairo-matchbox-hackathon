%lang starknet

from starkware.cairo.common.hash import hash2
from starkware.cairo.common.cairo_builtins import HashBuiltin

# # you can also show the board this way:
@storage_var
func board(i : felt, j : felt) -> (res : felt):
end

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    board.write(0, 0, 0)
    board.write(0, 0, 0)
    board.write(0, 0, 0)
    board.write(1, 1, 0)
    board.write(1, 1, 0)
    board.write(1, 1, 0)
    board.write(2, 2, 0)
    board.write(2, 2, 0)
    board.write(2, 2, 0)
    return ()
end

@external
func write_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    i : felt, j : felt, value : felt
) -> ():
    board.write(i, j, value)
    return ()
end

@view
func read_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    i : felt, j : felt
) -> (board_value : felt):
    let (board_value_at_position_i_j : felt) = board.read(i, j)
    return (board_value_at_position_i_j)
end

@storage_var
func state_hash_value(state_hash : felt) -> (value : felt):
end

# # retrieve state hash from a board
@view
func getStateHash{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    hash : felt
):
    let (board_value : felt) = board.read(0, 0)
    let (h1) = hash2{hash_ptr=pedersen_ptr}(board_value, 0)
    let (board_value : felt) = board.read(1, 0)
    let (h2) = hash2{hash_ptr=pedersen_ptr}(board_value, h1)
    let (board_value : felt) = board.read(2, 0)
    let (h3) = hash2{hash_ptr=pedersen_ptr}(board_value, h2)
    let (board_value : felt) = board.read(0, 1)
    let (h4) = hash2{hash_ptr=pedersen_ptr}(board_value, h3)
    let (board_value : felt) = board.read(1, 1)
    let (h5) = hash2{hash_ptr=pedersen_ptr}(board_value, h4)
    let (board_value : felt) = board.read(2, 1)
    let (h6) = hash2{hash_ptr=pedersen_ptr}(board_value, h5)
    let (board_value : felt) = board.read(0, 2)
    let (h7) = hash2{hash_ptr=pedersen_ptr}(board_value, h6)
    let (board_value : felt) = board.read(1, 2)
    let (h8) = hash2{hash_ptr=pedersen_ptr}(board_value, h7)
    let (board_value : felt) = board.read(2, 2)
    let (h9) = hash2{hash_ptr=pedersen_ptr}(board_value, h8)

    return (h9)
end
