#!/bin/bash

set -e

# Start the Docker daemon in the background
dockerd &

# Wait for the Docker daemon to be ready
until docker info &>/dev/null; do
  sleep 1
done

# Call the original entrypoint script from the Bitnami Jenkins image
exec /opt/bitnami/scripts/jenkins/entrypoint.sh "$@"