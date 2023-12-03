#!/bin/bash

# Check if the required arguments are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <json_data> <image_name> : $#"
  exit 1
fi

json_data="$1"
image_name="$2"

# Extract the VERSION from the JSON data
VERSION=$(echo $json_data | jq -r ".[] | .[\"$image_name\"].version")

# Output the version only
echo "VERSION=${VERSION}"

