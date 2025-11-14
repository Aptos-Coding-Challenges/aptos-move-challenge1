#[test_only]
module contract::nft_challenge_tests {
    use std::signer;
    use aptos_framework::object;
    use aptos_token_objects::collection;
    use aptos_token_objects::token;
    use contract::my_first_nft;
    use std::option;
    use aptos_framework::account;
    use aptos_framework::timestamp;

    #[test(module_signer = @contract, user = @0xCAFE)]
    fun test_mint_nft(module_signer: &signer, user: &signer) {
        let framework_signer = account::create_account_for_test(@aptos_framework);
        timestamp::set_time_has_started_for_testing(&framework_signer);
        let now = 1763028979;
        timestamp::update_global_time_for_test_secs(now);

        // init module
        my_first_nft::init_for_test(module_signer);

        let collection_object = my_first_nft::get_collection_object();

        assert!(collection::count(collection_object) == option::some(0), 0);

        let token_object = my_first_nft::mint(user);

        assert!(collection::count(collection_object) == option::some(1), 0);

        assert!(object::owner(token_object) == signer::address_of(user), 0);

        assert!(token::collection_object(token_object) == collection_object, 0);

        let custom_metadata = my_first_nft::get_custom_metadata(object::object_address(&token_object));
        assert!(custom_metadata.get_creator() == signer::address_of(user), 0);
        assert!(custom_metadata.get_created_at() == now, 0);

        // burn nft
        my_first_nft::burn(user, token_object);

        assert!(object::is_object(object::object_address(&token_object)) == false, 0);

        assert!(my_first_nft::exist_custom_metadata(object::object_address(&token_object)) == false, 0);

        assert!(collection::count(collection_object) == option::some(0), 0);
    }
}
