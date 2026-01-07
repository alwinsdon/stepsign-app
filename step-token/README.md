# STEP Token - Move Package

A simple fungible token (coin) on Sui for the StepSign incentive system.

## Features

- **Mintable**: Treasury holder can mint new tokens
- **Burnable**: Treasury holder can burn tokens
- **Transferable**: Standard Sui coin, can be sent/received
- **6 decimals**: Standard precision (1 STEP = 1,000,000 base units)

## Structure

```
step-token/
├── Move.toml          # Package manifest
└── sources/
    └── step_coin.move # STEP coin implementation
```

## Deployment

### Option 1: Sui Playground (Easiest - No CLI needed)

1. Go to https://suiexplorer.com/devnet/deploy
2. Upload `Move.toml` and `sources/step_coin.move`
3. Click "Deploy"
4. Save the **Package ID** and **Treasury Cap Object ID**

### Option 2: Sui CLI (If installed)

```bash
cd step-token
sui client publish --gas-budget 100000000
```

Save the output:
- **Package ID**: `0x...` (needed for backend)
- **Treasury Cap ID**: Object ID of type `TreasuryCap<STEP_COIN>`

## Usage

### Mint tokens (from backend)

```typescript
const tx = new Transaction();
tx.moveCall({
  target: `${PACKAGE_ID}::step_coin::mint`,
  arguments: [
    tx.object(TREASURY_CAP_ID),
    tx.pure.u64(amount),
    tx.pure.address(recipient)
  ]
});
```

### Burn tokens

```typescript
const tx = new Transaction();
tx.moveCall({
  target: `${PACKAGE_ID}::step_coin::burn`,
  arguments: [
    tx.object(TREASURY_CAP_ID),
    tx.object(coinObjectId)
  ]
});
```

## Important IDs (After Deployment)

After deploying, record these values in `backend/.env`:

```
SUI_PACKAGE_ID=0x... (from deployment output)
SUI_TREASURY_CAP_ID=0x... (from deployment output)
```

## Testing

The coin includes a test-only init function:

```move
#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(STEP_COIN {}, ctx);
}
```







