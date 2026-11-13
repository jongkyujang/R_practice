#!/bin/bash
set -euo pipefail

echo "=== 시스템 패키지 설치 중 ==="
sudo apt-get update -q
sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
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
sudo Rscript -e '
  options(repos = c(
    CRAN = "https://packagemanager.posit.co/cran/__linux__/noble/latest"
  ))

  packages <- c("languageserver", "httpgd")
  install.packages(packages)

  installed <- vapply(
    packages,
    requireNamespace,
    logical(1),
    quietly = TRUE
  )

  if (!all(installed)) {
    stop(
      "설치 실패: ",
      paste(packages[!installed], collapse = ", ")
    )
  }

  cat("R 패키지 설치 완료\n")
'

echo "=== 설치 완료 ==="
