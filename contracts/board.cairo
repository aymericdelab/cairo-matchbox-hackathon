%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.math import assert_nn_le, unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le
from starkware.starknet.common.syscalls import get_block_timestamp

from contracts.choose_next_state import ( 
        make_random_move, 
        choose, 
        write_board, 
        view_board
    )

@contract_interface
namespace IStateHashValueContract:
    func read_state_hash_value(state_hash : felt) -> (value : felt):
    end

    func write_state_hash_value(state_hash : felt, value : felt) -> ():
    end
end

# # you can also show the board this way:
@storage_var
func game_number() -> (num : felt):
end

@storage_var
func winner() -> (winner : felt):
end

@storage_var
func num_moves() -> (value : felt):
end

@storage_var
func state_moves(i : felt) -> (value : felt):
end

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    return ()
end

@view
func view_game_number{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (num : felt):
    let (num) = game_number.read()
    return (num)
end

@view
func view_winner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    winner : felt
):
    let (num) = winner.read()
    return (num)
end

@view
func view_num_moves{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    moves : felt
):
    let (num) = num_moves.read()
    return (num)
end

@view
func view_state_moves{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    i : felt
) -> (state : felt):
    let (val) = state_moves.read(i)
    return (val)
end

# # retrieve state hash from a board
@view
func get_state_hash{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    size : felt, hash : felt
) -> (hash : felt):
    let (board_value : felt) = board.read(8 - size)
    let (h) = hash2{hash_ptr=pedersen_ptr}(board_value, hash)

    if size == 0:
        return (h)
    end

    return get_state_hash(size - 1, h)
end

# # start with num_plays + 1
@external
func update_state_hash_value{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    i : felt, reward : felt, add : felt
) -> ():
    if i == 0:
        return ()
    end
    tempvar val = i / 2
    let (even : felt) = is_le(val, i)

    if even == 1:
        update_state_hash_value(i - 1, reward, add)
        return ()
    end

    let (state_hash : felt) = get_state_moves_hash(i, i, 0)
    let (current_value : felt) = IStateHashValueContract.read_state_hash_value(
        contract_address=add, state_hash=state_hash
    )
    # # learning rate = 0.2 -> 2
    # # decay rate = 0.9 -> 9
    tempvar reward = current_value + 2 * (9 * reward - current_value)

    update_state_hash_value(i - 1, reward, add)

    return ()
end

@external
func play{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(i : felt, add : felt) -> ():
    write_board(i, 1)
    let (val) = make_random_move()
    if val == 1:
        return()
    end
    choose(0, 9, 0, add)
    let (spot) = get_diff_boards(9)
    write_board(spot, 2)
end

# TEST
@external
func reset_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    success : felt
):
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

# TEST REMOVE ALL
@external
func write_winner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> ():
    let (win) = winner.read()
    winner.write(win + 1)
    return ()
end

@external
func write_num_moves{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    moves : felt
) -> ():
    num_moves.write(moves)
    return ()
end

@external
func write_state_moves{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    i : felt, value : felt
) -> ():
    state_moves.write(i, value)
    return ()
end

# returns the winner if state is in winning state
@external
func is_winning_state{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (res : felt):
    alloc_locals
    # lines
    let (a) = board.read(0)
    let (b) = board.read(1)
    let (c) = board.read(2)
    let (d) = board.read(3)
    let (e) = board.read(4)
    let (f) = board.read(5)
    let (g) = board.read(6)
    let (h) = board.read(7)
    let (i) = board.read(8)

    if a != 0:
        if a == b:
            if b == c:
                return(a)
            end
        end
    end
    if d != 0:
        if d == e:
            if e == f:
                return(d)
            end
        end
    end
    if g != 0:
        if g == h:
            if h == i:
                return(g)
            end
        end
    end

    # columns
    if a != 0:
        if a == d:
            if d == g:
                return(a)
            end
        end
    end
    if b != 0:
        if b == e:
            if e == h:
                return(b)
            end
        end
    end
    if c != 0:
        if c == f:
            if f == i:
                return(c)
            end
        end
    end

    # diagonals
    if a != 0:
        if a == e:
            if e == i:
                return(a)
            end
        end
    end
    if c != 0:
        if c == e:
            if e == g:
                return(c)
            end
        end
    end

    let (moves) = num_moves.read()
    if moves == 9:
        return(2)
    end
    return (0)
end

# size is the size of the moves you want to hash
# i start at size always
@external
func get_state_moves_hash{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    size : felt, i : felt, hash : felt
) -> (hash : felt):
    let (state : felt) = state_moves.read(size - i)
    let (h) = hash2{hash_ptr=pedersen_ptr}(state, hash)

    if i == 0:
        return (h)
    end

    return get_state_moves_hash(size, i - 1, h)
end
