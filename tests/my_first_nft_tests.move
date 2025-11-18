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

    #[test(module_signer = @contract, user1 = @0xCAFE, user2 = @0xBEEF)]
    fun test_multiple_users_mint(module_signer: &signer, user1: &signer, user2: &signer) {
        let framework_signer = account::create_account_for_test(@aptos_framework);
        timestamp::set_time_has_started_for_testing(&framework_signer);
        let now = 1763028979;
        timestamp::update_global_time_for_test_secs(now);

        // init module
        my_first_nft::init_for_test(module_signer);

        let collection_object = my_first_nft::get_collection_object();

        assert!(collection::count(collection_object) == option::some(0), 0);

        // user1 mints first NFT
        let token1 = my_first_nft::mint(user1);
        assert!(collection::count(collection_object) == option::some(1), 0);
        assert!(object::owner(token1) == signer::address_of(user1), 1);
        let metadata1 = my_first_nft::get_custom_metadata(object::object_address(&token1));
        assert!(metadata1.get_creator() == signer::address_of(user1), 1);

        // user2 mints second NFT
        let token2 = my_first_nft::mint(user2);
        assert!(collection::count(collection_object) == option::some(2), 2);
        assert!(object::owner(token2) == signer::address_of(user2), 2);
        let metadata2 = my_first_nft::get_custom_metadata(object::object_address(&token2));
        assert!(metadata2.get_creator() == signer::address_of(user2), 2);

        // verify tokens are different
        assert!(object::object_address(&token1) != object::object_address(&token2), 3);

        // verify both tokens belong to the same collection
        assert!(token::collection_object(token1) == collection_object, 4);
        assert!(token::collection_object(token2) == collection_object, 5);

        // user1 burns their NFT
        my_first_nft::burn(user1, token1);
        assert!(collection::count(collection_object) == option::some(1), 6);
        assert!(my_first_nft::exist_custom_metadata(object::object_address(&token1)) == false, 7);

        // user2's NFT should still exist
        assert!(object::is_object(object::object_address(&token2)) == true, 8);
        assert!(my_first_nft::exist_custom_metadata(object::object_address(&token2)) == true, 9);

        // user2 burns their NFT
        my_first_nft::burn(user2, token2);
        assert!(collection::count(collection_object) == option::some(0), 10);
    }

    #[test(module_signer = @contract, user = @0xCAFE)]
    fun test_single_user_multiple_mints(module_signer: &signer, user: &signer) {
        let framework_signer = account::create_account_for_test(@aptos_framework);
        timestamp::set_time_has_started_for_testing(&framework_signer);
        let now = 1763028979;
        timestamp::update_global_time_for_test_secs(now);

        // init module
        my_first_nft::init_for_test(module_signer);

        let collection_object = my_first_nft::get_collection_object();

        // user mints multiple NFTs
        let token1 = my_first_nft::mint(user);
        assert!(collection::count(collection_object) == option::some(1), 0);

        let token2 = my_first_nft::mint(user);
        assert!(collection::count(collection_object) == option::some(2), 1);

        let token3 = my_first_nft::mint(user);
        assert!(collection::count(collection_object) == option::some(3), 2);

        // verify all tokens belong to the same user
        assert!(object::owner(token1) == signer::address_of(user), 3);
        assert!(object::owner(token2) == signer::address_of(user), 4);
        assert!(object::owner(token3) == signer::address_of(user), 5);

        // verify all tokens are different
        assert!(object::object_address(&token1) != object::object_address(&token2), 6);
        assert!(object::object_address(&token2) != object::object_address(&token3), 7);
        assert!(object::object_address(&token1) != object::object_address(&token3), 8);

        // verify all metadata has correct creator
        let metadata1 = my_first_nft::get_custom_metadata(object::object_address(&token1));
        let metadata2 = my_first_nft::get_custom_metadata(object::object_address(&token2));
        let metadata3 = my_first_nft::get_custom_metadata(object::object_address(&token3));
        assert!(metadata1.get_creator() == signer::address_of(user), 9);
        assert!(metadata2.get_creator() == signer::address_of(user), 10);
        assert!(metadata3.get_creator() == signer::address_of(user), 11);

        // burn all NFTs
        my_first_nft::burn(user, token1);
        assert!(collection::count(collection_object) == option::some(2), 12);

        my_first_nft::burn(user, token2);
        assert!(collection::count(collection_object) == option::some(1), 13);

        my_first_nft::burn(user, token3);
        assert!(collection::count(collection_object) == option::some(0), 14);
    }

    #[test(module_signer = @contract, owner = @0xCAFE, non_owner = @0xBEEF)]
    #[expected_failure]
    fun test_burn_by_non_owner_fails(module_signer: &signer, owner: &signer, non_owner: &signer) {
        let framework_signer = account::create_account_for_test(@aptos_framework);
        timestamp::set_time_has_started_for_testing(&framework_signer);
        let now = 1763028979;
        timestamp::update_global_time_for_test_secs(now);

        // init module
        my_first_nft::init_for_test(module_signer);

        // owner mints NFT
        let token = my_first_nft::mint(owner);
        assert!(object::owner(token) == signer::address_of(owner), 0);

        // non_owner tries to burn - this should fail
        my_first_nft::burn(non_owner, token);
    }

    #[test(module_signer = @contract, user1 = @0xCAFE, user2 = @0xBEEF, user3 = @0xDEAD)]
    fun test_three_users_independent_mints(module_signer: &signer, user1: &signer, user2: &signer, user3: &signer) {
        let framework_signer = account::create_account_for_test(@aptos_framework);
        timestamp::set_time_has_started_for_testing(&framework_signer);
        let now = 1763028979;
        timestamp::update_global_time_for_test_secs(now);

        // init module
        my_first_nft::init_for_test(module_signer);

        let collection_object = my_first_nft::get_collection_object();

        // all three users mint NFTs
        let token1 = my_first_nft::mint(user1);
        let token2 = my_first_nft::mint(user2);
        let token3 = my_first_nft::mint(user3);

        // verify collection count
        assert!(collection::count(collection_object) == option::some(3), 0);

        // verify ownership
        assert!(object::owner(token1) == signer::address_of(user1), 1);
        assert!(object::owner(token2) == signer::address_of(user2), 2);
        assert!(object::owner(token3) == signer::address_of(user3), 3);

        // verify creators in metadata
        let metadata1 = my_first_nft::get_custom_metadata(object::object_address(&token1));
        let metadata2 = my_first_nft::get_custom_metadata(object::object_address(&token2));
        let metadata3 = my_first_nft::get_custom_metadata(object::object_address(&token3));
        assert!(metadata1.get_creator() == signer::address_of(user1), 4);
        assert!(metadata2.get_creator() == signer::address_of(user2), 5);
        assert!(metadata3.get_creator() == signer::address_of(user3), 6);

        // verify all tokens are unique
        assert!(object::object_address(&token1) != object::object_address(&token2), 7);
        assert!(object::object_address(&token2) != object::object_address(&token3), 8);
        assert!(object::object_address(&token1) != object::object_address(&token3), 9);

        // each user burns their own NFT
        my_first_nft::burn(user1, token1);
        assert!(collection::count(collection_object) == option::some(2), 10);

        my_first_nft::burn(user2, token2);
        assert!(collection::count(collection_object) == option::some(1), 11);

        my_first_nft::burn(user3, token3);
        assert!(collection::count(collection_object) == option::some(0), 12);
    }
}
