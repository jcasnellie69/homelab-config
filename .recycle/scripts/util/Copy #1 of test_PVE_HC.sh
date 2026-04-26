#!/usr/bin/env bash
set -euo pipefail

# Define variables that are expected by the sourced script
OUT="/dev/null"
OUTDIR="/tmp"

# Source the original script
source scripts/util/PVE_HC.sh

# Mock mem_kib
mem_kib() {
  case "$1" in
    MemTotal) echo 16777216 ;; # 16Gi
    MemAvailable) echo 8388608 ;; # 8Gi
    SwapTotal) echo 8388608 ;; # 8Gi
    SwapFree) echo 4194304 ;; # 4Gi
    *) echo 0 ;;
  esac
}

# Test helper
assertEquals() {
  local expected="$1"
  local actual="$2"
  local name="$3"
  if [[ "$expected" == "$actual" ]]; then
    echo "PASS: $name"
  else
    echo "FAIL: $name (Expected: '$expected', Actual: '$actual')"
    return 1
  fi
}

echo "Running tests..."

# Test toGi
assertEquals "1.0Gi" "$(toGi 1048576)" "toGi 1.0Gi"
assertEquals "2.0Gi" "$(toGi 2097152)" "toGi 2.0Gi"
assertEquals "0.5Gi" "$(toGi 524288)" "toGi 0.5Gi"

# Test mem_summary
assertEquals "16.0Gi total, 8.0Gi used, 8.0Gi free" "$(mem_summary)" "mem_summary"

# Test swap_summary
assertEquals "8.0Gi total, 4.0Gi used, 4.0Gi free" "$(swap_summary)" "swap_summary"

echo "All tests passed!"
