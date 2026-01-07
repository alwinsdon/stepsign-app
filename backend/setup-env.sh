#!/bin/bash
# Setup .env file for StepSign backend

echo "=== StepSign Backend Configuration ==="
echo ""
echo "This script will create your .env file."
echo "You'll need:"
echo "  1. Package ID (from STEP token deployment)"
echo "  2. Treasury Cap ID (from deployment output)"
echo ""

# Check if .env already exists
if [ -f .env ]; then
    echo "⚠ .env file already exists!"
    read -p "Overwrite? (y/n): " overwrite
    if [ "$overwrite" != "y" ]; then
        echo "Aborted."
        exit 0
    fi
fi

echo ""
echo "Enter your deployment values:"
echo ""

read -p "Package ID (0x...): " PACKAGE_ID
read -p "Treasury Cap ID (0x...): " TREASURY_CAP_ID

echo ""
echo "Creating .env file..."

cat > .env <<EOF
# Server Config
PORT=3000
NODE_ENV=development

# Sui Network Config
SUI_NETWORK=testnet
SUI_RPC_URL=https://fullnode.testnet.sui.io:443

# STEP Token Config
SUI_PACKAGE_ID=$PACKAGE_ID
SUI_TREASURY_CAP_ID=$TREASURY_CAP_ID

# Reward Config
REWARD_PER_STEP=1000000
MIN_STEPS_FOR_CLAIM=100
MAX_CLAIMS_PER_DAY=3

# Database
DB_PATH=./stepsign.db
EOF

echo ""
echo "✓ .env file created!"
echo ""
echo "Configuration:"
echo "  Package ID: $PACKAGE_ID"
echo "  Treasury Cap ID: $TREASURY_CAP_ID"
echo "  Port: 3000"
echo "  Network: testnet"
echo ""
echo "To start the backend:"
echo "  npm run dev"
echo ""







