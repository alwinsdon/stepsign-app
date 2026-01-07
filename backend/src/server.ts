import express, { Request, Response } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { db, Session, Claim } from './database';
import { suiService } from './sui-client';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Health check
app.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'ok', timestamp: Date.now() });
});

// ========== SESSIONS ==========

/**
 * POST /api/sessions
 * Upload a completed session from the app
 */
app.post('/api/sessions', async (req: Request, res: Response) => {
  try {
    const {
      device_id,
      start_time,
      end_time,
      total_steps,
      total_distance,
      avg_cadence,
      calories_burned,
      session_data
    } = req.body;

    // Validation
    if (!device_id || !start_time || !end_time || total_steps === undefined) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const sessionId = db.createSession({
      device_id,
      start_time,
      end_time,
      total_steps,
      total_distance: total_distance || 0,
      avg_cadence: avg_cadence || 0,
      calories_burned: calories_burned || 0,
      session_data: JSON.stringify(session_data || {})
    });

    const session = db.getSession(sessionId);
    res.status(201).json({ success: true, session });
  } catch (error: any) {
    console.error('Error creating session:', error);
    res.status(500).json({ error: error.message });
  }
});

/**
 * GET /api/sessions/:id
 * Get a specific session
 */
app.get('/api/sessions/:id', (req: Request, res: Response) => {
  try {
    const sessionId = parseInt(req.params.id);
    const session = db.getSession(sessionId);

    if (!session) {
      return res.status(404).json({ error: 'Session not found' });
    }

    res.json({ success: true, session });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * GET /api/sessions/device/:device_id
 * Get sessions for a device
 */
app.get('/api/sessions/device/:device_id', (req: Request, res: Response) => {
  try {
    const { device_id } = req.params;
    const limit = parseInt(req.query.limit as string) || 20;
    const sessions = db.getSessionsByDevice(device_id, limit);

    res.json({ success: true, sessions });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// ========== CLAIMS ==========

/**
 * POST /api/claims
 * Create a reward claim request
 */
app.post('/api/claims', async (req: Request, res: Response) => {
  try {
    const { session_id, user_wallet } = req.body;

    if (!session_id || !user_wallet) {
      return res.status(400).json({ error: 'Missing session_id or user_wallet' });
    }

    // Get session
    const session = db.getSession(session_id);
    if (!session) {
      return res.status(404).json({ error: 'Session not found' });
    }

    // Validation rules
    const MIN_STEPS = parseInt(process.env.MIN_STEPS_FOR_CLAIM || '10');
    const MAX_CLAIMS = parseInt(process.env.MAX_CLAIMS_PER_DAY || '3');
    const REWARD_PER_STEP = parseInt(process.env.REWARD_PER_STEP || '1000000'); // 1 STEP

    if (session.total_steps < MIN_STEPS) {
      return res.status(400).json({ 
        error: `Minimum ${MIN_STEPS} steps required`,
        your_steps: session.total_steps
      });
    }

    // Check daily claim limit
    const todayClaims = db.getTodayClaimCount(user_wallet);
    if (todayClaims >= MAX_CLAIMS) {
      return res.status(429).json({ 
        error: `Daily claim limit reached (${MAX_CLAIMS} claims per day)` 
      });
    }

    // Calculate reward (example: 1 STEP per step)
    const rewardAmount = session.total_steps * REWARD_PER_STEP;

    // Create claim
    const claimId = db.createClaim({
      session_id,
      user_wallet,
      steps: session.total_steps,
      reward_amount: rewardAmount,
      status: 'pending'
    });

    // AUTOMATIC APPROVAL & MINTING
    try {
      const stepAmount = rewardAmount / 1_000_000; // Convert to STEP
      console.log(`Auto-minting ${stepAmount} STEP to ${user_wallet}...`);
      
      const txDigest = await suiService.mintTokensAdmin(user_wallet, stepAmount);
      
      // Update claim with transaction digest and mark as completed
      db.updateClaimStatus(claimId, 'completed', txDigest);
      
      console.log(`✓ Auto-minted ${stepAmount} STEP - TX: ${txDigest}`);

      const completedClaim = db.getClaim(claimId);

      res.status(201).json({ 
        success: true, 
        claim: completedClaim,
        message: `Successfully minted ${stepAmount} STEP tokens`,
        txDigest
      });
    } catch (mintError: any) {
      console.error('Auto-mint failed:', mintError);
      // Claim stays as pending if minting fails
      const claim = db.getClaim(claimId);
      res.status(201).json({ 
        success: true, 
        claim,
        message: 'Claim created but auto-mint failed. Contact admin.',
        error: mintError.message
      });
    }
  } catch (error: any) {
    console.error('Error creating claim:', error);
    res.status(500).json({ error: error.message });
  }
});

/**
 * GET /api/claims/pending
 * Get all pending claims (for admin)
 */
app.get('/api/claims/pending', async (req: Request, res: Response) => {
  try {
    const claims = db.getPendingClaims();
    res.json({ success: true, claims });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * GET /api/claims/wallet/:address
 * Get claims for a wallet
 */
app.get('/api/claims/wallet/:address', async (req: Request, res: Response) => {
  try {
    const { address } = req.params;
    const claims = db.getClaimsByWallet(address);
    res.json({ success: true, claims });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * POST /api/claims/:id/approve
 * Approve a claim and mint tokens directly (admin action)
 */
app.post('/api/claims/:id/approve', async (req: Request, res: Response) => {
  try {
    const claimId = parseInt(req.params.id);
    const claim = db.getClaim(claimId);

    if (!claim) {
      return res.status(404).json({ error: 'Claim not found' });
    }

    if (claim.status !== 'pending') {
      return res.status(400).json({ error: `Claim is already ${claim.status}` });
    }

    // Update claim status to approved
    db.updateClaimStatus(claimId, 'approved');

    // Mint tokens directly using admin wallet
    const stepAmount = claim.reward_amount / 1_000_000; // Convert to STEP
    console.log(`Minting ${stepAmount} STEP to ${claim.user_wallet}...`);
    
    const txDigest = await suiService.mintTokensAdmin(
      claim.user_wallet,
      stepAmount
    );

    // Update claim with transaction digest and status
    db.updateClaimStatus(claimId, 'completed', txDigest);

    console.log(`✓ Minted ${stepAmount} STEP - TX: ${txDigest}`);

    res.json({
      success: true,
      message: `Successfully minted ${stepAmount} STEP tokens`,
      txDigest,
      claimId
    });
  } catch (error: any) {
    console.error('Error approving claim:', error);
    // Revert claim status on error if claim was found
    try {
      const claimId = parseInt(req.params.id);
      db.updateClaimStatus(claimId, 'pending');
    } catch {}
    res.status(500).json({ error: error.message });
  }
});

/**
 * POST /api/claims/:id/complete
 * Mark claim as completed after user signs transaction
 */
app.post('/api/claims/:id/complete', async (req: Request, res: Response) => {
  try {
    const claimId = parseInt(req.params.id);
    const { signedTransaction } = req.body;

    if (!signedTransaction) {
      return res.status(400).json({ error: 'Missing signedTransaction' });
    }

    const claim = db.getClaim(claimId);
    if (!claim) {
      return res.status(404).json({ error: 'Claim not found' });
    }

    // Execute the signed transaction
    const txDigest = await suiService.executeTransaction(signedTransaction);

    // Update claim
    db.updateClaimStatus(claimId, 'completed', txDigest);

    res.json({
      success: true,
      message: 'Claim completed!',
      txDigest,
      explorerUrl: `https://suiexplorer.com/txblock/${txDigest}?network=testnet`
    });
  } catch (error: any) {
    console.error('Error completing claim:', error);
    res.status(500).json({ error: error.message });
  }
});

/**
 * POST /api/claims/:id/reject
 * Reject a claim
 */
app.post('/api/claims/:id/reject', async (req: Request, res: Response) => {
  try {
    const claimId = parseInt(req.params.id);
    const claim = db.getClaim(claimId);

    if (!claim) {
      return res.status(404).json({ error: 'Claim not found' });
    }

    db.updateClaimStatus(claimId, 'rejected');

    res.json({ success: true, message: 'Claim rejected' });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// ========== WALLET ==========

/**
 * GET /api/wallet/:address
 * Get wallet balance and stats
 */
app.get('/api/wallet/:address', async (req: Request, res: Response) => {
  try {
    const { address } = req.params;

    // Get STEP balance from Sui
    const balance = await suiService.getStepBalance(address);

    // Get claim history
    const claims = db.getClaimsByWallet(address);
    const completedClaims = claims.filter(c => c.status === 'completed');
    const totalEarned = completedClaims.reduce((sum, c) => sum + c.reward_amount, 0) / 1_000_000;

    res.json({
      success: true,
      wallet: {
        address,
        balance,
        totalEarned,
        claimCount: completedClaims.length,
        pendingClaims: claims.filter(c => c.status === 'pending').length
      }
    });
  } catch (error: any) {
    console.error('Error fetching wallet:', error);
    res.status(500).json({ error: error.message });
  }
});

// Start server - listen on all interfaces (0.0.0.0) for phone access
app.listen(PORT, '0.0.0.0', () => {
  console.log('\n=== StepSign Backend Server ===');
  console.log(`✓ Server running on http://0.0.0.0:${PORT}`);
  console.log(`✓ Network: ${process.env.SUI_NETWORK || 'testnet'}`);
  console.log(`✓ Database: ${process.env.DB_PATH || './stepsign.db'}`);
  console.log('\nEndpoints:');
  console.log('  POST   /api/sessions');
  console.log('  GET    /api/sessions/:id');
  console.log('  POST   /api/claims');
  console.log('  GET    /api/claims/pending');
  console.log('  GET    /api/claims/wallet/:address');
  console.log('  POST   /api/claims/:id/approve');
  console.log('  POST   /api/claims/:id/complete');
  console.log('  GET    /api/wallet/:address');
  console.log('\n');
});

