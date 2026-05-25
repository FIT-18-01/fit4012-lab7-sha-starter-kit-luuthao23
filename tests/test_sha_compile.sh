#!/usr/bin/env bash
set -euo pipefail

g++ -std=c++17 -Wall -Wextra -pedantic sha_procedure.cpp -o sha256
g++ -std=c++17 -Wall -Wextra -pedantic file_integrity.cpp -o file_integrity
g++ -std=c++17 -Wall -Wextra -pedantic password_hash.cpp -o password_hash
g++ -std=c++17 -Wall -Wextra -pedantic salted_password_hash.cpp -o salted_password_hash


[[ -x ./sha256 ]] || { echo "[FAIL] Missing sha256 executable"; exit 1; }
[[ -x ./file_integrity ]] || { echo "[FAIL] Missing file_integrity executable"; exit 1; }
[[ -x ./password_hash ]] || { echo "[FAIL] Missing password_hash executable"; exit 1; }
[[ -x ./salted_password_hash ]] || { echo "[FAIL] Missing salted_password_hash executable"; exit 1; }

echo "[PASS] SHA programs compile successfully."
