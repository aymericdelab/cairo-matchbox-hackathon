%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

# # you can also show the board this way:
@storage_var
func board(i : felt, j : felt) -> (res : felt):
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
