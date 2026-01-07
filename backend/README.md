# StepSign Backend

Node.js + TypeScript backend for the StepSign reward system.

## Features

- **Session Management**: Store completed workout sessions
- **Claim System**: Users request rewards, admin approves
- **Wallet Integration**: Query STEP balances, create mint transactions
- **SQLite Database**: Persistent storage for sessions and claims
- **Sui SDK**: Interact with STEP token on Sui testnet

## Setup

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Environment

Copy `.env.example` to `.env` and fill in the values:

```bash
cp .env.example .env
nano .env
```

**Required after deploying STEP token:**
- `SUI_PACKAGE_ID`: From deployment output
- `SUI_TREASURY_CAP_ID`: From deployment output

### 3. Run Development Server

```bash
npm run dev
```

Server starts on `http://localhost:3000`

## API Endpoints

### Sessions

```bash
# Upload a session
POST /api/sessions
{
  "device_id": "ESP32_ABC123",
  "start_time": 1704380400,
  "end_time": 1704384000,
  "total_steps": 5420,
  "total_distance": 4100,
  "avg_cadence": 85,
  "calories_burned": 320,
  "session_data": {}
}

# Get session
GET /api/sessions/:id

# Get sessions by device
GET /api/sessions/device/:device_id?limit=20
```

### Claims

```bash
# Create claim
POST /api/claims
{
  "session_id": 1,
  "user_wallet": "0x1dc9a65345a98cba3437f1b6c6ef8d81d6c7f3e24e6bd942e20f26c41d7c08f4"
}

# Get pending claims (admin)
GET /api/claims/pending

# Get user's claims
GET /api/claims/wallet/:address

# Approve claim (creates unsigned transaction)
POST /api/claims/:id/approve

# Complete claim (after user signs)
POST /api/claims/:id/complete
{
  "signedTransaction": "base64_encoded_signed_tx"
}

# Reject claim
POST /api/claims/:id/reject
```

### Wallet

```bash
# Get wallet info
GET /api/wallet/:address
```

## Claim Flow

1. **User completes workout** → App uploads session to `/api/sessions`
2. **User requests reward** → App calls `/api/claims` with session ID and wallet
3. **Backend validates**:
   - Minimum steps met? (default: 100)
   - Daily claim limit? (default: 3/day)
   - Calculates reward based on steps
4. **Admin approves** → `/api/claims/:id/approve` returns unsigned transaction
5. **User signs in wallet** → App submits signed transaction to `/api/claims/:id/complete`
6. **Backend executes** → Tokens minted and transferred!

## Database Schema

### Sessions
```sql
id, device_id, start_time, end_time, total_steps, total_distance, 
avg_cadence, calories_burned, session_data, created_at
```

### Claims
```sql
id, session_id, user_wallet, steps, reward_amount, status, 
tx_digest, created_at, completed_at
```

## Testing

```bash
# Start backend
npm run dev

# In another terminal, test endpoints
curl http://localhost:3000/health

# Upload test session
curl -X POST http://localhost:3000/api/sessions \
  -H "Content-Type: application/json" \
  -d '{
    "device_id": "TEST_DEVICE",
    "start_time": 1704380400,
    "end_time": 1704384000,
    "total_steps": 500,
    "total_distance": 400,
    "avg_cadence": 80,
    "calories_burned": 50
  }'

# Create claim
curl -X POST http://localhost:3000/api/claims \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": 1,
    "user_wallet": "0x1dc9a65345a98cba3437f1b6c6ef8d81d6c7f3e24e6bd942e20f26c41d7c08f4"
  }'
```

## Production Deployment

1. Build TypeScript:
```bash
npm run build
```

2. Run production server:
```bash
npm start
```

3. Use a process manager (PM2):
```bash
npm install -g pm2
pm2 start dist/server.js --name stepsign-backend
```

## Security Notes

- **ADMIN_PRIVATE_KEY**: Keep secure, don't commit to Git
- **Add rate limiting** in production (e.g., express-rate-limit)
- **Add authentication** for admin endpoints
- **Validate session data** against cheat detection rules







