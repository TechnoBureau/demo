#!/bin/bash

# Extract the value of VERSION using grep and awk
VERSION=$(grep -E '^ARG VERSION=' builders/jenkins/jenkins.Dockerfile | awk -F '=' '{print $2}' | tr -d ' ')

# Check if VERSION is empty or not set
if [ -z "$VERSION" ]; then
  echo "No VERSION argument found in the Dockerfile or the value is empty."
else
  echo "VERSION: $VERSION"
fi
