%lang starknet

from starkware.cairo.common.hash import hash2
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_nn_le


# # you can also show the board this way:
@storage_var
func board(i : felt) -> (res : felt):
end

@storage_var
func game_number() -> (num : felt):
end

@storage_var
func last_winner() -> (winner : felt):
end

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    return ()
end

@view
func view_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(i : felt) -> (board_value : felt):
    let (val) = board.read(i)
    return (val)
end

@view
func view_game_number{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (num : felt):
    let (num) = game_number.read()
    return (num)
end

@view
func view_last_winner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (winner : felt):
    let (num) = last_winner.read()
    return (num)
end

# # retrieve state hash from a board
@view
func get_state_hash{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(size : felt, hash : felt) -> (hash : felt):
    let (board_value : felt) = board.read(8-size)
    let (h) = hash2{hash_ptr=pedersen_ptr}(board_value, hash)

    if size == 0 :
        return (h)
    end

    return get_state_hash(size-1, h)
end

# TEST
@external
func reset_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (success : felt):
    board.write(0, 0)
    board.write(1, 0)
    board.write(2, 0)
    board.write(3, 0)
    board.write(4, 0)
    board.write(5, 0)
    board.write(6, 0)
    board.write(7, 0)
    board.write(8, 0)
    let (num) = game_number.read()
    game_number.write(num + 1)
    return (1)
end

# TEST
@external
func write_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(i : felt, value : felt) -> ():
    assert_nn_le(i, 8)
    assert_nn_le(value, 2)
    board.write(i, value)
    return ()
end

# TEST REMOVE ALL
@external
func write_winner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> ():
    let (win) = last_winner.read()
    last_winner.write(win + 1)
    return ()
end

# target: the target for the winner check (3 or 6)
@external
func is_winning_state{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(target : felt) -> (res : felt):
    # lines
    let (one) = board.read(0)
    let (two) = board.read(1)
    let (three) = board.read(2)
    let sum = one + two + three
    if sum == target:
        return (1)
    end
    let (one) = board.read(3)
    let (two) = board.read(4)
    let (three) = board.read(5)
    let sum = one + two + three
    if sum == target:
        return (1)
    end
    let (one) = board.read(0)
    let (two) = board.read(3)
    let (three) = board.read(6)
    let sum = one + two + three
    if sum == target:
        return (1)
    end

    # columns
    let (one) = board.read(1)
    let (two) = board.read(4)
    let (three) = board.read(7)
    let sum = one + two + three
    if sum == target:
        return (1)
    end
    let (one) = board.read(2)
    let (two) = board.read(5)
    let (three) = board.read(8)
    let sum = one + two + three
    if sum == target:
        return (1)
    end
    let (one) = board.read(6)
    let (two) = board.read(7)
    let (three) = board.read(8)
    let sum = one + two + three
    if sum == target:
        return (1)
    end

    # diagonals
    let (one) = board.read(0)
    let (two) = board.read(4)
    let (three) = board.read(8)
    let sum = one + two + three
    if sum == target:
        return (1)
    end
    let (one) = board.read(2)
    let (two) = board.read(4)
    let (three) = board.read(6)
    let sum = one + two + three
    if sum == target:
        return (1)
    end
    return (0)
end