%lang starknet

# # start with num_plays + 1
@external
func update_state_hash_value{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    i : felt, reward : felt
) -> ():
    if i == 0:
        let (reward : felt) = 1
        return (reward)
    end

    let (state_hash : felt) = get_state_hash()
    let (current_value : felt) = get_state_hash_value(state_hash)

    update_state_hash_value(i - 1, reward)

    # # learning rate = 0.2 -> 2
    # # decay rate = 0.9 -> 9
    let (reward : felt) = current_value + 2 * (9 * reward - current_value)

    return (reward)
end
