#!/usr/bin/env bash

set -euo pipefail

buildapp \
        --load-system 'quick-fastq' \
        --entry 'quick-fastq:toplevel' \
        --manifest-file 'build/asdf-manifest' \
        --compress-core \
        --output 'build/quick-fastq'
