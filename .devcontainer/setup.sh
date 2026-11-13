#!/bin/bash
set -euo pipefail

echo "=== R 설치 중 ==="
sudo apt-get update -q
sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    --no-install-recommends \
    r-base

echo "=== R 설치 확인 ==="
R --version

echo "=== 설치 완료 ==="
