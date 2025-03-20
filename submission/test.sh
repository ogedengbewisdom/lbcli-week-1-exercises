#!/bin/bash

# Import helper functions
source submission/functions.sh

# Week One Exercise: Bitcoin Address Generation and Transaction Verification
# This script demonstrates using the key concepts from previous exercises in a practical scenario

# Ensure script fails fast on errors
set -e

# ========================================================================
# STUDENT EXERCISE PART BEGINS HERE - Complete the following sections
# ========================================================================

# Set up the challenge scenario
setup_challenge

# CHALLENGE PART 1: Create a wallet to track your discoveries
echo "CHALLENGE 1: Create your explorer wallet"
echo "----------------------------------------"
echo "Create a wallet named 'btrustwallet' to track your Bitcoin exploration"
bitcoin-cli -regtest createwallet "btrustwallet"
echo "Now, create another wallet called 'treasurewallet' to fund your adventure"
bitcoin-cli -regtest createwallet "treasurewallet"

# Generate an address for mining in the treasure wallet
echo "Generating an address in treasurewallet..."
TREASURE_ADDR=$(bitcoin-cli -regtest -rpcwallet=treasurewallet getnewaddress)
check_cmd "Address generation"
echo "Mining to address: $TREASURE_ADDR"

# Mine some blocks to get initial coins
mine_blocks 101 $TREASURE_ADDR

# CHALLENGE PART 2: Check your starting balance
echo ""
echo "CHALLENGE 2: Check your starting resources"
echo "-----------------------------------------"
BALANCE=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getbalance)
check_cmd "Balance check"
echo "Your starting balance: $BALANCE BTC"

# CHALLENGE PART 3: Generate different address types to collect treasures
echo ""
echo "CHALLENGE 3: Create a set of addresses for your exploration"
echo "---------------------------------------------------------"
LEGACY_ADDR=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getnewaddress "" legacy)
check_cmd "Legacy address generation"
P2SH_ADDR=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getnewaddress "" p2sh-segwit)
check_cmd "P2SH address generation"
SEGWIT_ADDR=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getnewaddress "" bech32)
check_cmd "SegWit address generation"
TAPROOT_ADDR=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getnewaddress "" bech32m)
check_cmd "Taproot address generation"

echo "Your exploration addresses:"
echo "- Legacy treasure map: $LEGACY_ADDR"
echo "- P2SH ancient vault: $P2SH_ADDR"
echo "- SegWit digital safe: $SEGWIT_ADDR"
echo "- Taproot quantum vault: $TAPROOT_ADDR"

# CHALLENGE PART 4: Find the total treasure collected
echo ""
echo "CHALLENGE 4: Count your treasures"
echo "-------------------------------"
NEW_BALANCE=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getbalance)
check_cmd "New balance check"
echo "Your treasure balance: $NEW_BALANCE BTC"
COLLECTED=$(echo "$NEW_BALANCE - $BALANCE" | bc)
check_cmd "Balance calculation"
echo "You've collected $COLLECTED BTC in treasures!"

# CHALLENGE PART 5: Verify that one of your addresses is valid
echo ""
echo "CHALLENGE 5: Validate the ancient vault address"
echo "--------------------------------------------"
P2SH_VALID=$(bitcoin-cli -regtest validateaddress "$P2SH_ADDR" | jq -r '.isvalid')
check_cmd "Address validation"
echo "P2SH vault validation: $P2SH_VALID"

if [[ "$P2SH_VALID" == "true" ]]; then
  echo "Vault is secure! You may proceed to the next challenge."
else
  echo "WARNING: Vault security compromised!"
  exit 1
fi

# CHALLENGE PART 6: Decode a signed message to reveal a secret
echo ""
echo "CHALLENGE 6: Decode the hidden message"
echo "------------------------------------"
VERIFY_RESULT=$(bitcoin-cli -regtest -rpcwallet=btrustwallet verifymessage "$LEGACY_ADDR" "$SIGNATURE" "$SECRET_MESSAGE")
check_cmd "Message verification"
echo "Message verification result: $VERIFY_RESULT"

if [[ "$VERIFY_RESULT" == "true" ]]; then
  echo "Message verified successfully! The secret message is:"
  echo "\"$SECRET_MESSAGE\""
else
  echo "ERROR: Message verification failed!"
  exit 1
fi

# CHALLENGE PART 7: Working with descriptors to find the final treasure
echo ""
echo "CHALLENGE 7: The descriptor treasure map"
echo "-------------------------------------"
NEW_TAPROOT_ADDR=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getnewaddress "" bech32m)
check_cmd "New taproot address generation"
NEW_TAPROOT_ADDR=$(trim "$NEW_TAPROOT_ADDR")

ADDR_INFO=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getaddressinfo "$NEW_TAPROOT_ADDR")
check_cmd "Getting address info"
INTERNAL_KEY=$(echo "$ADDR_INFO" | jq -r '.pubkey')
check_cmd "Extracting key from descriptor"
INTERNAL_KEY=$(trim "$INTERNAL_KEY")

SIMPLE_DESCRIPTOR="tr($INTERNAL_KEY)"
echo "Simple descriptor: $SIMPLE_DESCRIPTOR"
TAPROOT_DESCRIPTOR=$(bitcoin-cli -regtest getdescriptorinfo "$SIMPLE_DESCRIPTOR" | jq -r '.descriptor')
check_cmd "Descriptor generation"
TAPROOT_DESCRIPTOR=$(trim "$TAPROOT_DESCRIPTOR")
echo "Taproot treasure map: $TAPROOT_DESCRIPTOR"
DERIVED_ADDR_RAW=$(bitcoin-cli -regtest deriveaddresses "$TAPROOT_DESCRIPTOR")
check_cmd "Address derivation"
DERIVED_ADDR=$(echo "$DERIVED_ADDR_RAW" | tr -d '[]" \n\t')

echo "New taproot address: $NEW_TAPROOT_ADDR"
echo "Derived address:     $DERIVED_ADDR"

if [[ "$NEW_TAPROOT_ADDR" == "$DERIVED_ADDR" ]]; then
  echo "Addresses match! The final treasure is yours!"
else
  echo "ERROR: Address mismatch detected!"
  exit 1
fi

echo ""
echo "TREASURE HUNT COMPLETE!"
