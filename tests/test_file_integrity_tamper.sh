#!/usr/bin/env bash
set -euo pipefail

g++ -std=c++17 -Wall -Wextra -pedantic sha_procedure.cpp -o sha256 >/dev/null
g++ -std=c++17 -Wall -Wextra -pedantic file_integrity.cpp -o file_integrity >/dev/null


TMP_FILE=$(mktemp)
trap 'rm -f "$TMP_FILE"' EXIT

printf "FIT4012 file integrity test\n" > "$TMP_FILE"
EXPECTED_HASH=$(./sha256 --hash-file "$TMP_FILE")

./file_integrity "$TMP_FILE" "$EXPECTED_HASH" >/dev/null || {
  echo "[FAIL] File integrity check should pass before tamper"
  exit 1
}

printf "tamper: sửa 1 byte / flip 1 byte\n" >> "$TMP_FILE"
if ./file_integrity "$TMP_FILE" "$EXPECTED_HASH" >/dev/null; then
  echo "[FAIL] Tamper test should fail after file is changed"
  exit 1
fi

echo "[PASS] Tamper / flip 1 byte negative test passed."
