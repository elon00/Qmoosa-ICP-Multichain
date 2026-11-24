#!/usr/bin/env bash
source ~/.local/share/dfx/env
CANISTER="mkv5r-3aaaa-aaaab-qabsq-cai"

echo "=== 1. Token Metadata ==="
dfx canister call --playground "$CANISTER" get_token_metadata

echo -e "\n=== 2. Balance of Genesis Account (2vxsx-fae) ==="
dfx canister call --playground "$CANISTER" icrc1_balance_of '(record { owner = principal "2vxsx-fae"; subaccount = null })'

echo -e "\n=== 3. Balance of Your Deployer (6ppwb-h7r62...) ==="
dfx canister call --playground "$CANISTER" icrc1_balance_of '(record { owner = principal "6ppwb-h7r62-p4vkr-6cz2b-fi4qk-vz2xe-ezaaj-s3ftc-ggu4l-4265s-5qe"; subaccount = null })'

echo -e "\n=== 4. Balance of ygwoo-ajcpq... ==="
dfx canister call --playground "$CANISTER" icrc1_balance_of '(record { owner = principal "ygwoo-ajcpq-dppl7-2ejwb-msjm2-tehg2-z56er-vbrxu-ne7hp-kdbth-2ae"; subaccount = null })'
