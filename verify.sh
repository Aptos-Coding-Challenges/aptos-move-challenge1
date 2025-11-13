#!/usr/bin/env bash
set -euo pipefail

TEST_FILE="tests/my_first_nft_tests.move"
EXPECTED_HASH="def98fcc65656ccee12f4a516dff1790b8ba0fc42597385388a2e08962154022"

hash_file() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$TEST_FILE" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$TEST_FILE" | awk '{print $1}'
  else
    echo "Neither shasum nor sha256sum is available; please install one of them." >&2
    return 1
  fi
}

if [[ ! -f "$TEST_FILE" ]]; then
  echo "Test file '$TEST_FILE' not found." >&2
  exit 1
fi

actual_hash=$(hash_file)
if [[ "$actual_hash" != "$EXPECTED_HASH" ]]; then
  cat >&2 <<MSG
Test file hash mismatch.
  expected: $EXPECTED_HASH
  actual:   $actual_hash
Please revert changes under $TEST_FILE before running the tests.
MSG
  exit 1
fi

echo "Test file hash verified ($actual_hash)."

if ! command -v aptos >/dev/null 2>&1; then
  echo "aptos CLI not found on PATH. Install it before running this script." >&2
  exit 1
fi

cmd=(aptos move test "$@")
echo "+ ${cmd[*]}"
"${cmd[@]}"
