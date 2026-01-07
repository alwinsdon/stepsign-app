#!/bin/bash
# Test StepSign Backend API

BASE_URL="http://localhost:3000"
WALLET="0x1dc9a65345a98cba3437f1b6c6ef8d81d6c7f3e24e6bd942e20f26c41d7c08f4"

echo "=== Testing StepSign Backend API ==="
echo ""

# Check health
echo "1. Health Check"
curl -s $BASE_URL/health | jq
echo ""

# Create session
echo "2. Creating Test Session"
SESSION_RESPONSE=$(curl -s -X POST $BASE_URL/api/sessions \
  -H "Content-Type: application/json" \
  -d '{
    "device_id": "ESP32_TEST",
    "start_time": 1704380400,
    "end_time": 1704384000,
    "total_steps": 500,
    "total_distance": 400,
    "avg_cadence": 80,
    "calories_burned": 50
  }')
echo $SESSION_RESPONSE | jq
SESSION_ID=$(echo $SESSION_RESPONSE | jq -r '.session.id')
echo "Session ID: $SESSION_ID"
echo ""

# Create claim
echo "3. Creating Claim"
CLAIM_RESPONSE=$(curl -s -X POST $BASE_URL/api/claims \
  -H "Content-Type: application/json" \
  -d "{
    \"session_id\": $SESSION_ID,
    \"user_wallet\": \"$WALLET\"
  }")
echo $CLAIM_RESPONSE | jq
CLAIM_ID=$(echo $CLAIM_RESPONSE | jq -r '.claim.id')
echo "Claim ID: $CLAIM_ID"
echo ""

# Get pending claims
echo "4. Getting Pending Claims"
curl -s $BASE_URL/api/claims/pending | jq
echo ""

# Approve claim
echo "5. Approving Claim (generates unsigned transaction)"
APPROVE_RESPONSE=$(curl -s -X POST $BASE_URL/api/claims/$CLAIM_ID/approve)
echo $APPROVE_RESPONSE | jq
echo ""

echo "=== Test Complete ==="
echo ""
echo "Next Steps:"
echo "  1. Copy the unsignedTransaction from above"
echo "  2. Sign it in your Sui wallet"
echo "  3. Complete the claim with:"
echo "     curl -X POST $BASE_URL/api/claims/$CLAIM_ID/complete \\"
echo "       -H \"Content-Type: application/json\" \\"
echo "       -d '{\"signedTransaction\": \"YOUR_SIGNED_TX_BASE64\"}'"
echo ""







