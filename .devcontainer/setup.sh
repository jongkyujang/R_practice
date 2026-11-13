#!/bin/bash
set -e

echo "=== 시스템 패키지 설치 중 ==="
apt-get update -q
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    r-base \
    r-base-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libcairo2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libpng-dev \
    libjpeg-dev

echo "=== R 패키지 설치 중 (languageserver, httpgd) ==="
# Posit Package Manager의 Ubuntu 24.04 (noble) 바이너리 저장소 사용 → 컴파일 없이 빠르게 설치
Rscript -e "
  options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/noble/latest'))
  install.packages(c('languageserver', 'httpgd'))
  cat('패키지 설치 완료:', paste(c('languageserver', 'httpgd'), collapse = ', '), '\n')
"

echo "=== 설치 완료 ==="
