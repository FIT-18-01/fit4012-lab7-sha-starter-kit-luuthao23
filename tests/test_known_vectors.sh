#!/usr/bin/env bash
set -euo pipefail

g++ -std=c++17 -Wall -Wextra -pedantic sha_procedure.cpp -o sha256 >/dev/null


EMPTY_EXPECTED="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
ABC_EXPECTED="ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"

EMPTY_ACTUAL=$(./sha256 --hash-string "")
ABC_ACTUAL=$(./sha256 --hash-string "abc")

[[ "$EMPTY_ACTUAL" == "$EMPTY_EXPECTED" ]] || {
  echo "[FAIL] Empty string vector mismatch"
  echo "expected: $EMPTY_EXPECTED"
  echo "actual  : $EMPTY_ACTUAL"
  exit 1
}

[[ "$ABC_ACTUAL" == "$ABC_EXPECTED" ]] || {
  echo "[FAIL] abc vector mismatch"
  echo "expected: $ABC_EXPECTED"
  echo "actual  : $ABC_ACTUAL"
  exit 1
}

./sha256 --self-test >/dev/null

echo "[PASS] SHA-256 known answer tests passed."
