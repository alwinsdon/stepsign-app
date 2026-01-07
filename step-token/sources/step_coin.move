/// STEP Token - StepSign Incentive Token
/// A simple coin for rewarding fitness activity
module step_token::step_coin {
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::url;

    /// The STEP Coin type
    public struct STEP_COIN has drop {}

    /// Initialize the STEP coin
    /// Called once when the module is published
    fun init(witness: STEP_COIN, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency<STEP_COIN>(
            witness,
            6, // decimals
            b"STEP",
            b"StepSign Token",
            b"Earn STEP tokens by walking and exercising with StepSign smart insoles",
            option::some(url::new_unsafe_from_bytes(b"https://stepsign.app/logo.png")),
            ctx
        );
        
        // Transfer the treasury cap to the sender (deployer)
        // This allows the deployer to mint new tokens
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx));
        
        // Freeze the metadata so it can't be changed
        transfer::public_freeze_object(metadata);
    }

    /// Mint new STEP tokens
    /// Only the holder of the TreasuryCap can mint
    public entry fun mint(
        treasury_cap: &mut TreasuryCap<STEP_COIN>,
        amount: u64,
        recipient: address,
        ctx: &mut TxContext
    ) {
        let coin = coin::mint(treasury_cap, amount, ctx);
        transfer::public_transfer(coin, recipient);
    }

    /// Burn STEP tokens
    public entry fun burn(
        treasury_cap: &mut TreasuryCap<STEP_COIN>,
        coin: Coin<STEP_COIN>
    ) {
        coin::burn(treasury_cap, coin);
    }

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(STEP_COIN {}, ctx);
    }
}







