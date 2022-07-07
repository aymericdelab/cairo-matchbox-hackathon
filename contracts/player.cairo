# SPDX-License-Identifier: MIT
# OpenZeppelin Contracts for Cairo v0.2.0 (token/erc20/ERC20.cairo)

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

@constructor
func constructor{
    syscall_ptr: felt*, 
    pedersen_ptr: HashBuiltin*, 
    range_check_ptr
}():
return ()
end

@storage_var
func board(line: felt, row: felt) -> (tictac: felt):
end

@view
func view_board{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(line: felt, row: felt) -> (val: felt):
    let(val) = board.read(line, row)
    return (val)
end

@external
func reset{syscall_ptr: felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (success: felt):
    board.write(0,0,0)
    board.write(0,1,0)
    board.write(0,2,0)
    board.write(1,0,0)
    board.write(1,1,0)
    board.write(1,2,0)
    board.write(2,0,0)
    board.write(2,1,0)
    board.write(2,2,0)
    return(1)
end