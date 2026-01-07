import { SuiClient, getFullnodeUrl } from '@mysten/sui/client';
import { Transaction } from '@mysten/sui/transactions';
import { Ed25519Keypair } from '@mysten/sui/keypairs/ed25519';
import { fromBase64 } from '@mysten/sui/utils';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const NETWORK = process.env.SUI_NETWORK || 'testnet';
const RPC_URL = process.env.SUI_RPC_URL || getFullnodeUrl(NETWORK as any);
const PACKAGE_ID = process.env.SUI_PACKAGE_ID!;
const TREASURY_CAP_ID = process.env.SUI_TREASURY_CAP_ID!;

export class SuiService {
  private client: SuiClient;
  private keypair: Ed25519Keypair | null = null;

  constructor() {
    this.client = new SuiClient({ url: RPC_URL });
    
    // Initialize admin keypair if private key is provided
    if (process.env.ADMIN_PRIVATE_KEY) {
      try {
        const privKey = process.env.ADMIN_PRIVATE_KEY;
        
        // Handle both bech32 (suiprivkey1...) and base64 formats
        if (privKey.startsWith('suiprivkey')) {
          this.keypair = Ed25519Keypair.fromSecretKey(privKey);
        } else {
          this.keypair = Ed25519Keypair.fromSecretKey(fromBase64(privKey));
        }
        
        console.log('✓ Sui client initialized with admin wallet');
      } catch (error) {
        console.error('Failed to load admin private key:', error);
      }
    } else {
      console.warn('⚠ No ADMIN_PRIVATE_KEY - minting will require manual approval');
    }
  }

  /**
   * Get STEP token balance for an address
   */
  async getStepBalance(address: string): Promise<number> {
    try {
      const coinType = `${PACKAGE_ID}::step_coin::STEP_COIN`;
      const coins = await this.client.getCoins({
        owner: address,
        coinType
      });

      let totalBalance = 0n;
      for (const coin of coins.data) {
        totalBalance += BigInt(coin.balance);
      }

      // Convert from base units (6 decimals) to STEP
      return Number(totalBalance) / 1_000_000;
    } catch (error) {
      console.error('Error fetching balance:', error);
      return 0;
    }
  }

  /**
   * Create a mint transaction (returns unsigned transaction for user approval)
   */
  createMintTransaction(recipient: string, amount: number): string {
    const tx = new Transaction();
    
    // Convert STEP to base units (6 decimals)
    const baseAmount = Math.floor(amount * 1_000_000);

    tx.moveCall({
      target: `${PACKAGE_ID}::step_coin::mint`,
      arguments: [
        tx.object(TREASURY_CAP_ID),
        tx.pure.u64(baseAmount),
        tx.pure.address(recipient)
      ]
    });

    // Serialize transaction to base64 for wallet to sign
    return tx.serialize();
  }

  /**
   * Execute a signed transaction
   */
  async executeTransaction(signedTxBytes: string): Promise<string> {
    try {
      const result = await this.client.executeTransactionBlock({
        transactionBlock: signedTxBytes,
        options: {
          showEffects: true,
          showObjectChanges: true
        }
      });

      if (result.effects?.status.status === 'success') {
        return result.digest;
      } else {
        throw new Error(`Transaction failed: ${result.effects?.status.error}`);
      }
    } catch (error: any) {
      throw new Error(`Failed to execute transaction: ${error.message}`);
    }
  }

  /**
   * Get transaction details
   */
  async getTransaction(digest: string) {
    return this.client.getTransactionBlock({
      digest,
      options: {
        showEffects: true,
        showInput: true,
        showEvents: true,
        showObjectChanges: true
      }
    });
  }

  /**
   * Admin-only: Directly mint tokens (requires ADMIN_PRIVATE_KEY)
   */
  async mintTokensAdmin(recipient: string, amount: number): Promise<string> {
    if (!this.keypair) {
      throw new Error('Admin private key not configured');
    }

    const tx = new Transaction();
    const baseAmount = Math.floor(amount * 1_000_000);

    tx.moveCall({
      target: `${PACKAGE_ID}::step_coin::mint`,
      arguments: [
        tx.object(TREASURY_CAP_ID),
        tx.pure.u64(baseAmount),
        tx.pure.address(recipient)
      ]
    });

    const result = await this.client.signAndExecuteTransaction({
      transaction: tx,
      signer: this.keypair
    });

    return result.digest;
  }
}

export const suiService = new SuiService();


