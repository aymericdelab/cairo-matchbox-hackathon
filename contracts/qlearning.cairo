%lang starknet

from starkware.cairo.common.hash import hash2
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin

# # board
struct Board_row:
    member first_column : felt
    member second_column : felt
    member third_column : felt
end
let (Board : Board_row*) = alloc()
assert Board[0] = Board_row(first_column=0, second_column=0, third_column=0)
assert Board[1] = Board_row(first_column=0, second_column=0, third_column=0)
assert Board[2] = Board_row(first_column=0, second_column=0, third_column=0)

# # you can also show the board this way:
@storage_var
func _my_array(i : felt) -> (res : felt):
end

@external
func write_my_array{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> ():
    _my_array.write(0, 123)
    _my_array.write(1, 456)
    _my_array.write(2, 789)
    return ()
end

# Define a storage variable.
@storage_var
func balance() -> (res : felt):
end

# Increases the balance by the given amount.
@external
func increase_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    amount : felt
):
    let (res) = balance.read()
    balance.write(res + amount)
    return ()
end

# # isEnd
# # false = 0, true = 1
let isEnd : felt = 1
# # # board Hash
let boardHash : felt = 'undefined'
let playerSymbol : felt = -1
let playerSymbol : felt = 1

@external
func setup_game{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> ():
    let isEnd : felt = 1
    let boardHash : felt = 'undefined'
    # # player that is playing now (either -1 or 1)
    let playerSymbol : felt = -1
    let playerSymbol : felt = 1
    return ()
end

# # retrieve state hash from a board
@view
func getStateHash{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(state) -> ():
    let (Board : Board_row*) = alloc()
    assert Board[0] = Board_row(first_column=0, second_column=0, third_column=0)
    assert Board[1] = Board_row(first_column=0, second_column=0, third_column=0)
    assert Board[2] = Board_row(first_column=0, second_column=0, third_column=0)

    let (h1) = hash2{hash_ptr=pedersen_ptr}(Board[0].first_column, 0)
    let (h2) = hash2{hash_ptr=pedersen_ptr}(Board[0].second_column, h1)
    let (h3) = hash2{hash_ptr=pedersen_ptr}(Board[0].second_column, h2)
    let (h4) = hash2{hash_ptr=pedersen_ptr}(Board[1].first_column, h3)
    let (h5) = hash2{hash_ptr=pedersen_ptr}(Board[1].second_column, h4)
    let (h6) = hash2{hash_ptr=pedersen_ptr}(Board[1].third_column, h5)
    let (h7) = hash2{hash_ptr=pedersen_ptr}(Board[2].first_column, h6)
    let (h8) = hash2{hash_ptr=pedersen_ptr}(Board[2].second_column, h7)
    let (h9) = hash2{hash_ptr=pedersen_ptr}(Board[2].third_column, h8)

    return ()
end

# # struct with game info
@view
func winner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (winner : felt):
    # # ... winner logic ...

    # # not sure how to change that temp variable
    let isEnd : felt = 1
    # # either return -1 if tie, 0 if continues, 1 if there is a winner
    return (1)
end

# # im here
# @view
# func availablePositions{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
# params
# ) -> (availablePositions_len : felt, availablePositions : felt*):
# let (availablePositions : felt*) = alloc()
# return (availablePositions.size, availablePositions)
# end
