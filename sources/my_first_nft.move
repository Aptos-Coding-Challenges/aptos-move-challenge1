/// Challenge module where you must finish NFT mint/burn flows using Aptos token objects.
/// You are allowed to edit the constants below to customize metadata, but tests expect
/// the public APIs to follow the original behavior.
module contract::my_first_nft {
    use std::option;
    use std::signer;
    use std::string;
    use aptos_framework::object;
    use aptos_framework::object::Object;

    use aptos_token_objects::collection;
    use aptos_token_objects::royalty;
    use aptos_token_objects::token;

    const ERROR_NOWNER: u64 = 1;
    const ERROR_EVENT_MISSING: u64 = 2;

    /// You may tweak these constants if you want to experiment with custom metadata values.
    /// Tests cover the behavior of the functions, not the literal strings.
    const ResourceAccountSeed: vector<u8> = b"mfers";
    const CollectionDescription: vector<u8> = b"mfers are generated entirely from hand drawings by sartoshi. this project is in the public domain; feel free to use mfers any way you want.";
    const CollectionName: vector<u8> = b"mfers";
    const CollectionURI: vector<u8> = b"ipfs://QmWmgfYhDWjzVheQyV2TnpVXYnKR25oLWCB2i9JeBxsJbz";
    const TokenURI: vector<u8> = b"ipfs://bafybeiearr64ic2e7z5ypgdpu2waasqdrslhzjjm65hrsui2scqanau3ya/";
    const TokenPrefix: vector<u8> = b"mfer #";



    struct SignerCapabilityStore has key { extend_ref: object::ExtendRef }

    struct CollectionRefsStore has key { collection_object: Object<collection::Collection>, mutator_ref: collection::MutatorRef }

    struct TokenRefsStore has key {
        mutator_ref: token::MutatorRef,
        burn_ref: token::BurnRef,
        extend_ref: object::ExtendRef,
        transfer_ref: option::Option<object::TransferRef>,
    }

    struct CustomMetadata has key, copy, drop {
        creator: address,
        created_at: u64,
    }

    #[event]
    struct MintEvent has drop, store {
        owner: address,
        token_id: address,
        content: string::String,
    }

    #[event]
    struct BurnEvent has drop, store {
        owner: address,
        token_id: address,
        content: string::String,
    }

    fun init_module(sender: &signer) {
        let collection_creator_cref = object::create_named_object(sender, b"");
        let collection_creator_extend_ref = object::generate_extend_ref(&collection_creator_cref);
        let collection_creator_signer = &object::generate_signer(&collection_creator_cref);
        
        let collection_cref = collection::create_unlimited_collection(
            collection_creator_signer,
            string::utf8(CollectionDescription),
            string::utf8(CollectionName),
            option::some(royalty::create(5, 100, signer::address_of(sender))),
            string::utf8(CollectionURI),
        );

        let collection_signer = &object::generate_signer(&collection_cref);

        let collection_mutator_ref = collection::generate_mutator_ref(&collection_cref);
        
        move_to(
            collection_signer,
            CollectionRefsStore { collection_object: object::object_from_constructor_ref(&collection_cref), mutator_ref: collection_mutator_ref },
        );

        move_to(
            collection_creator_signer,
            SignerCapabilityStore { extend_ref: collection_creator_extend_ref },
        );
    }

    /// ==========================================================================
    /// Challenge TODOs
    /// ==========================================================================
    /// Your goal is to finish the user-facing NFT lifecycle:
    /// 1. `mint` must create a numbered token inside the collection created in
    ///    `init_module`, store the per-token refs/metadata, emit `MintEvent`,
    ///    and hand the object back to the caller.
    /// 2. `burn` must be callable only by the current owner, emit `BurnEvent`,
    ///    delete the stored metadata and refs, and invoke the token burn ref.
    /// 3. `get_custom_metadata` must return the stored `CustomMetadata` for an
    ///    object address (useful inside tests).
    ///
    /// Look at `tests/my_first_nft_tests.move` for the exact expectations.

    /// Implement the full mint flow:
    /// - Use the stored collection refs to create a numbered token.
    /// - Persist a `TokenRefsStore` + `CustomMetadata` under the token object address.
    /// - Emit `MintEvent` and return the token object.
    public fun mint(
        sender: &signer,
    ): Object<CustomMetadata> {
        abort 0
    }

    /// Implement the burn flow:
    /// - Assert the caller currently owns the object.
    /// - Emit `BurnEvent`, delete the metadata/refs, and call `token::burn`.
    public fun burn(
        sender: &signer,
        object: Object<CustomMetadata>,
    ){
        abort 0
    }


    #[view]
    /// Helper expected by tests; read-only borrow of stored metadata.
    public fun get_custom_metadata(addr: address): CustomMetadata {
        abort 0
    }

    public fun exist_custom_metadata(addr: address): bool {
        exists<CustomMetadata>(addr)
    }

    public fun get_creator(self: &CustomMetadata): address {
        self.creator
    }

    public fun get_created_at(self: &CustomMetadata): u64 {
        self.created_at
    }

    public fun get_collection_creator_address(): address {
        object::create_object_address(&@contract, b"")
    }

    public fun get_collection_object(): Object<collection::Collection> {
        object::address_to_object(collection::create_collection_address(
            &get_collection_creator_address(),
            &string::utf8(CollectionName),
        ))
    }

    #[test_only]
    public fun init_for_test(sender: &signer) {
        init_module(sender);
    }
}
