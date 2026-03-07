#!/usr/bin/env bash
# Build and run tests in Docker

set -euo pipefail

echo "Building test container..."
docker build -f Dockerfile.test -t luabots-test .

echo ""
echo "Running tests..."
docker run --rm luabots-test
