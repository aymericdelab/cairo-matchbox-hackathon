%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin

@storage_var
func state_hash_value(state_hash : felt) -> (value : felt):
end

@external
func write_state_hash_value{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(state_hash : felt, value : felt) -> ():
    state_hash_value.write(state_hash, value)
    return ()
end

@view
func read_state_hash_value{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(state_hash : felt) -> (value : felt):
    let (res : felt) = state_hash_value.read(state_hash)
    return (res)
end
