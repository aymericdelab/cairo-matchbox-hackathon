%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.board import view_board, write_board

# # possible next boards, should be k different boards depending on the number of possible moves
@storage_var
func possible_next_boards(k : felt, i : felt, j : felt) -> (res : felt):
end

# # the best next board at the moment (only one, that will be rewrittent everytime we have found a new best board)
@storage_var
func best_next_board(i : felt, j : felt) -> (res : felt):
end

# test
# function to have access to the board for testing
@view
func view_board_copy{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    i : felt, j : felt
) -> (value : felt):
    let (value : felt) = view_board(i, j)
    return (value)
end

# # view function
@view
func view_possible_next_boards{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    k : felt, i : felt, j : felt
) -> (res : felt):
    let (res : felt) = possible_next_boards.read(k, i, j)
    return (res)
end

# # get the hash of the best next board, use it to compare it to the next_board
@view
func get_hash_best_next_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (hash : felt):
    let (board_value : felt) = best_next_board.read(0, 0)
    let (h1) = hash2{hash_ptr=pedersen_ptr}(board_value, 0)
    let (board_value : felt) = best_next_board.read(1, 0)
    let (h2) = hash2{hash_ptr=pedersen_ptr}(board_value, h1)
    let (board_value : felt) = best_next_board.read(2, 0)
    let (h3) = hash2{hash_ptr=pedersen_ptr}(board_value, h2)
    let (board_value : felt) = best_next_board.read(0, 1)
    let (h4) = hash2{hash_ptr=pedersen_ptr}(board_value, h3)
    let (board_value : felt) = best_next_board.read(1, 1)
    let (h5) = hash2{hash_ptr=pedersen_ptr}(board_value, h4)
    let (board_value : felt) = best_next_board.read(2, 1)
    let (h6) = hash2{hash_ptr=pedersen_ptr}(board_value, h5)
    let (board_value : felt) = best_next_board.read(0, 2)
    let (h7) = hash2{hash_ptr=pedersen_ptr}(board_value, h6)
    let (board_value : felt) = best_next_board.read(1, 2)
    let (h8) = hash2{hash_ptr=pedersen_ptr}(board_value, h7)
    let (board_value : felt) = best_next_board.read(2, 2)
    let (h9) = hash2{hash_ptr=pedersen_ptr}(board_value, h8)

    return (h9)
end

# # get the hash of the next board, use it to compare it to the best_next_board
@view
func get_hash_next_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(k) -> (
    hash : felt
):
    let (board_value : felt) = possible_next_boards.read(h, 0, 0)
    let (h1) = hash2{hash_ptr=pedersen_ptr}(board_value, 0)
    let (board_value : felt) = possible_next_boards.read(h, 1, 0)
    let (h2) = hash2{hash_ptr=pedersen_ptr}(board_value, h1)
    let (board_value : felt) = possible_next_boards.read(h, 2, 0)
    let (h3) = hash2{hash_ptr=pedersen_ptr}(board_value, h2)
    let (board_value : felt) = possible_next_boards.read(h, 0, 1)
    let (h4) = hash2{hash_ptr=pedersen_ptr}(board_value, h3)
    let (board_value : felt) = possible_next_boards.read(h, 1, 1)
    let (h5) = hash2{hash_ptr=pedersen_ptr}(board_value, h4)
    let (board_value : felt) = possible_next_boards.read(h, 2, 1)
    let (h6) = hash2{hash_ptr=pedersen_ptr}(board_value, h5)
    let (board_value : felt) = possible_next_boards.read(h, 0, 2)
    let (h7) = hash2{hash_ptr=pedersen_ptr}(board_value, h6)
    let (board_value : felt) = possible_next_boards.read(h, 1, 2)
    let (h8) = hash2{hash_ptr=pedersen_ptr}(board_value, h7)
    let (board_value : felt) = possible_next_boards.read(h, 2, 2)
    let (h9) = hash2{hash_ptr=pedersen_ptr}(board_value, h8)

    return (h9)
end

# test
# function to have access to the board for testing
@external
func write_board_copy{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    i : felt, j : felt, value : felt
) -> ():
    write_board(i, j, value)
    return ()
end

@external
func write_possible_next_boards{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    k : felt, i : felt, j : felt, value : felt
) -> ():
    possible_next_boards.write(k, i, j, value)
    return ()
end

@external
func create_board_copy{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    k : felt
) -> ():
    let value : felt = view_board(0, 0)
    write_possible_next_boards(k, 0, 0, value)
    let value : felt = view_board(0, 1)
    write_possible_next_boards(k, 0, 1, value)
    let value : felt = view_board(0, 2)
    write_possible_next_boards(k, 0, 2, value)
    let value : felt = view_board(1, 0)
    write_possible_next_boards(k, 1, 0, value)
    let value : felt = view_board(1, 1)
    write_possible_next_boards(k, 1, 1, value)
    let value : felt = view_board(1, 2)
    write_possible_next_boards(k, 1, 2, value)
    let value : felt = view_board(2, 0)
    write_possible_next_boards(k, 2, 0, value)
    let value : felt = view_board(2, 1)
    write_possible_next_boards(k, 2, 1, value)
    let value : felt = view_board(2, 2)
    write_possible_next_boards(k, 2, 2, value)
    return ()
end

func get_best_next_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> ():
    return ()
end

@external
func choose{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(i) -> (
    best_next_board
):
    return ()
end
