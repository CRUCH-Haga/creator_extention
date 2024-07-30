
/// Module: creator_extention
module creator_extention::basic_owner {
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
    use std::string::String;

    public struct Item has key, store {
        id: UID,
        name: String,
    }

    public fun new_item(name: String, ctx: &mut TxContext): Item {
        Item { id: object::new(ctx), name }
    }

    public fun place(kiosk: &mut Kiosk, cap: &KioskOwnerCap, item: Item) {
        kiosk::place(kiosk, cap, item)
    }

    public fun take(kiosk: &mut Kiosk, cap: &KioskOwnerCap, item_id: object::ID): Item {
        kiosk::take(kiosk, cap, item_id)
    }

    public fun list(kiosk: &mut Kiosk, cap: &KioskOwnerCap, item_id: object::ID, price: u64) {
        kiosk::list<Item>(kiosk, cap, item_id, price)
    }

    public fun delist(kiosk: &mut Kiosk, cap: &KioskOwnerCap, item_id: object::ID) {
        kiosk::delist<Item>(kiosk, cap, item_id)
    }

    #[allow(lint(share_owned, self_transfer))]
    /// Create new kiosk
    public fun new_kiosk(ctx: &mut TxContext) {
        let (kiosk, kiosk_owner_cap) = kiosk::new(ctx);
        transfer::public_share_object(kiosk);
        transfer::public_transfer(kiosk_owner_cap, ctx.sender());
    }
}

module creator_extention::transfer_policy {
    use sui::transfer_policy::{Self};
    use sui::package::{Self, Publisher};
    use creator_extention::basic_owner::Item;

    public struct KioskOtw has drop {}

    fun init(ctx: &mut TxContext) {
        package::claim_and_keep(KioskOtw {}, ctx)
    }

    #[allow(lint(share_owned, self_transfer))]
    public fun new_policy(publisher: &Publisher, ctx: &mut TxContext) {
        let (policy, policy_cap) = transfer_policy::new<Item>(publisher, ctx);
        transfer::public_share_object(policy);
        transfer::public_transfer(policy_cap, ctx.sender());
    }
}

module creator_extention::creator_extention {
    use sui::kiosk::{Kiosk, KioskOwnerCap};
    use sui::kiosk_extension;
    use sui::transfer_policy::{TransferPolicy};
    use creator_extention::basic_owner::Item;

    const PERMISSIONS: u128 = 1;

    public struct Extension has drop {}

    public fun add(kiosk: &mut Kiosk, cap: &KioskOwnerCap, ctx: &mut TxContext) {
        kiosk_extension::add(Extension {}, kiosk, cap, PERMISSIONS, ctx)
    }

    public fun place(kiosk: &mut Kiosk, item: Item, policy: &TransferPolicy<Item>) {
        kiosk_extension::place(Extension {}, kiosk, item, policy)
    }
}
