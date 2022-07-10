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
    view_board,
    get_diff_boards,
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
func view_game_number{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    num : felt
):
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

# # start with size - 1 so for [0, 1, 2, 3, 4, 5] i = 5
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
    # tempvar reward = current_value + 2 * (9 * reward - current_value)
    tempvar discounted_reward = 9 * reward
    let (discounted_reward, _) = unsigned_div_rem(discounted_reward, 10)
    tempvar lr_value_increment = 2 * (discounted_reward - current_value)
    let (lr_value_increment, _) = unsigned_div_rem(lr_value_increment, 10)

    tempvar new_reward = current_value + lr_value_increment

    IStateHashValueContract.write_state_hash_value(
        contract_address=add, state_hash=state_hash, value=new_reward
    )

    update_state_hash_value(i - 1, new_reward, add)

    return ()
end

@external
func play{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    i : felt, add : felt
) -> ():
    alloc_locals
    # Check the human can play there
    let (v) = view_board(i)
    assert v = 0
    # Human player plays and update the state of the moves
    write_board(i, 1)
    let (k) = view_num_moves() 
    write_state_moves(k, i)
    # Check is winning state for human
    let (local win_human) = is_winning_state() 
    let (m) = view_num_moves() 
    if win_human == 0:
        write_num_moves(m+1)
        play_ai(add)
        return()
    end
    if win_human == 3:
        update_state_hash_value(m, 500000, add)
        return()
    end
    if win_human == 1:
        update_state_hash_value(m, 0, add)
        write_winner(1)
        reset_board()
        return()
    end
    return()
end

func play_ai{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(add : felt) -> ():
    alloc_locals
    # AI rolls the dice for a random move
    let (val) = make_random_move()
    if val != 10:
        let (k) = view_num_moves() 
        write_state_moves(k, val)
        write_num_moves(k+1)
        return ()
    end
    # If not random, AI chooses his move
    choose(0, 9, 0, add)
    # Best move is extracted and copied to the correct board
    let (spot) = get_diff_boards(9)
    # Update the state of the moves
    let (k) = view_num_moves() 
    write_state_moves(k, spot)
    write_board(spot, 2)
    # Check is winning state
    let (local win) = is_winning_state() 
    let (m) = view_num_moves() 
    if win == 0:
        write_num_moves(m+1)
        return()
    end
    if win == 3:
        update_state_hash_value(m, 500000, add)
        return()
    end
    if win == 2:
        update_state_hash_value(m, 1000000, add)
        write_winner(2)
        reset_board()
        return()
    end
    return()
end

# TEST
func reset_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    success : felt
):
    write_board(0, 0)
    write_board(1, 0)
    write_board(2, 0)
    write_board(3, 0)
    write_board(4, 0)
    write_board(5, 0)
    write_board(6, 0)
    write_board(7, 0)
    write_board(8, 0)
    let (num) = game_number.read()
    game_number.write(num + 1)
    write_num_moves(0)
    return (1)
end

# TEST REMOVE ALL
func write_winner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(win : felt) -> ():
    winner.write(win)
    return ()
end

func write_num_moves{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    moves : felt
) -> ():
    num_moves.write(moves)
    return ()
end

func write_state_moves{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    i : felt, value : felt
) -> ():
    state_moves.write(i, value)
    return ()
end

# returns the winner if state is in winning state
func is_winning_state{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    res : felt
):
    alloc_locals
    # lines
    let (a) = view_board(0)
    let (b) = view_board(1)
    let (c) = view_board(2)
    let (d) = view_board(3)
    let (e) = view_board(4)
    let (f) = view_board(5)
    let (g) = view_board(6)
    let (h) = view_board(7)
    let (i) = view_board(8)

    if a != 0:
        if a == b:
            if b == c:
                return (a)
            end
        end
    end
    if d != 0:
        if d == e:
            if e == f:
                return (d)
            end
        end
    end
    if g != 0:
        if g == h:
            if h == i:
                return (g)
            end
        end
    end

    # columns
    if a != 0:
        if a == d:
            if d == g:
                return (a)
            end
        end
    end
    if b != 0:
        if b == e:
            if e == h:
                return (b)
            end
        end
    end
    if c != 0:
        if c == f:
            if f == i:
                return (c)
            end
        end
    end

    # diagonals
    if a != 0:
        if a == e:
            if e == i:
                return (a)
            end
        end
    end
    if c != 0:
        if c == e:
            if e == g:
                return (c)
            end
        end
    end

    let (moves) = num_moves.read()
    if moves == 9:
        return (3)
    end
    return (0)
end

# size_minus_one is the size - 1 of the moves you want to hash
# i start at size - 1 always
func get_state_moves_hash{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    size_minus_one : felt, i : felt, hash : felt
) -> (hash : felt):
    let (state : felt) = state_moves.read(size_minus_one - i)
    let (h) = hash2{hash_ptr=pedersen_ptr}(state, hash)

    if i == 0:
        return (h)
    end

    return get_state_moves_hash(size_minus_one, i - 1, h)
end
