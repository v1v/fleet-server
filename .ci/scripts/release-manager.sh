#!/usr/bin/env bash
#
# This script is executed by the release snapshot stage.
# It requires the below environment variables:
# - BRANCH_NAME
# - VAULT_ADDR
# - VAULT_ROLE_ID
# - VAULT_SECRET_ID
#
set -uexo pipefail

# set required permissions on artifacts and directory
chmod -R a+r build/binaries/*
chmod -R a+w build/binaries

# ensure the latest image has been pulled
IMAGE=docker.elastic.co/infra/release-manager:latest
docker pull --quiet $IMAGE

# Generate checksum files and upload to GCS
docker run --rm \
  --name release-manager \
  -e VAULT_ADDR \
  -e VAULT_ROLE_ID \
  -e VAULT_SECRET_ID \
  --mount type=bind,readonly=false,src="$PWD",target=/artifacts \
  "$IMAGE" \
    cli collect \
      --project fleet-server \
      --branch "main" \
      --commit "$(git rev-parse HEAD)" \
      --workflow "snapshot" \
      --artifact-set main
