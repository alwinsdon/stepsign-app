import Database from 'better-sqlite3';
import path from 'path';

const DB_PATH = process.env.DB_PATH || './stepsign.db';

export interface Session {
  id: number;
  device_id: string;
  start_time: number;
  end_time: number;
  total_steps: number;
  total_distance: number; // meters
  avg_cadence: number; // steps/min
  calories_burned: number;
  session_data: string; // JSON string of full session data
}

export interface Claim {
  id: number;
  session_id: number;
  user_wallet: string;
  steps: number;
  reward_amount: number;
  status: 'pending' | 'approved' | 'rejected' | 'completed';
  tx_digest?: string;
  created_at: number;
  completed_at?: number;
}

class StepSignDatabase {
  private db: Database.Database;

  constructor() {
    this.db = new Database(DB_PATH);
    this.initialize();
  }

  private initialize() {
    // Create sessions table
    this.db.exec(`
      CREATE TABLE IF NOT EXISTS sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        total_steps INTEGER NOT NULL,
        total_distance REAL NOT NULL,
        avg_cadence REAL NOT NULL,
        calories_burned REAL NOT NULL,
        session_data TEXT NOT NULL,
        created_at INTEGER DEFAULT (strftime('%s', 'now'))
      );
      
      CREATE INDEX IF NOT EXISTS idx_device_id ON sessions(device_id);
      CREATE INDEX IF NOT EXISTS idx_start_time ON sessions(start_time);
    `);

    // Create claims table
    this.db.exec(`
      CREATE TABLE IF NOT EXISTS claims (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        user_wallet TEXT NOT NULL,
        steps INTEGER NOT NULL,
        reward_amount INTEGER NOT NULL,
        status TEXT DEFAULT 'pending',
        tx_digest TEXT,
        created_at INTEGER DEFAULT (strftime('%s', 'now')),
        completed_at INTEGER,
        FOREIGN KEY (session_id) REFERENCES sessions(id)
      );
      
      CREATE INDEX IF NOT EXISTS idx_user_wallet ON claims(user_wallet);
      CREATE INDEX IF NOT EXISTS idx_status ON claims(status);
    `);

    console.log('✓ Database initialized:', DB_PATH);
  }

  // Sessions
  createSession(session: Omit<Session, 'id'>): number {
    const stmt = this.db.prepare(`
      INSERT INTO sessions (device_id, start_time, end_time, total_steps, total_distance, avg_cadence, calories_burned, session_data)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `);
    const result = stmt.run(
      session.device_id,
      session.start_time,
      session.end_time,
      session.total_steps,
      session.total_distance,
      session.avg_cadence,
      session.calories_burned,
      session.session_data
    );
    return result.lastInsertRowid as number;
  }

  getSession(id: number): Session | undefined {
    const stmt = this.db.prepare('SELECT * FROM sessions WHERE id = ?');
    return stmt.get(id) as Session | undefined;
  }

  getSessionsByDevice(deviceId: string, limit: number = 20): Session[] {
    const stmt = this.db.prepare(`
      SELECT * FROM sessions 
      WHERE device_id = ? 
      ORDER BY start_time DESC 
      LIMIT ?
    `);
    return stmt.all(deviceId, limit) as Session[];
  }

  // Claims
  createClaim(claim: Omit<Claim, 'id' | 'created_at'>): number {
    const stmt = this.db.prepare(`
      INSERT INTO claims (session_id, user_wallet, steps, reward_amount, status)
      VALUES (?, ?, ?, ?, ?)
    `);
    const result = stmt.run(
      claim.session_id,
      claim.user_wallet,
      claim.steps,
      claim.reward_amount,
      claim.status
    );
    return result.lastInsertRowid as number;
  }

  getClaim(id: number): Claim | undefined {
    const stmt = this.db.prepare('SELECT * FROM claims WHERE id = ?');
    return stmt.get(id) as Claim | undefined;
  }

  getPendingClaims(): Claim[] {
    const stmt = this.db.prepare(`
      SELECT * FROM claims 
      WHERE status = 'pending' 
      ORDER BY created_at ASC
    `);
    return stmt.all() as Claim[];
  }

  getClaimsByWallet(wallet: string): Claim[] {
    const stmt = this.db.prepare(`
      SELECT * FROM claims 
      WHERE user_wallet = ? 
      ORDER BY created_at DESC
    `);
    return stmt.all(wallet) as Claim[];
  }

  updateClaimStatus(id: number, status: string, txDigest?: string) {
    const completedAt = status === 'completed' ? Date.now() : null;
    const stmt = this.db.prepare(`
      UPDATE claims 
      SET status = ?, tx_digest = ?, completed_at = ?
      WHERE id = ?
    `);
    stmt.run(status, txDigest || null, completedAt, id);
  }

  getTodayClaimCount(wallet: string): number {
    const todayStart = Math.floor(new Date().setHours(0, 0, 0, 0) / 1000);
    const stmt = this.db.prepare(`
      SELECT COUNT(*) as count 
      FROM claims 
      WHERE user_wallet = ? AND created_at >= ?
    `);
    const result = stmt.get(wallet, todayStart) as { count: number };
    return result.count;
  }

  close() {
    this.db.close();
  }
}

export const db = new StepSignDatabase();







