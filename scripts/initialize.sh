#!/usr/bin/env bash

GITHUB_REF=$1
GITHUB_REF_TYPE=$2
GITHUB_TOKEN=$3
INPUT_VERSION=$4
#GITHUB_REPOSITORY=
cd builders || exit 1
result=""
result1=""

# Upload assets
upload_release_metadata() {
  ASSET_NAME=release.json
  echo "$1" > "$ASSET_NAME"

  RELEASE_ID=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_REPOSITORY/releases/tags/$GENERAL_VERSION" | jq -r '.id')

  ASSET_ID=$(curl -L -H "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/repos/$GITHUB_REPOSITORY/releases/$RELEASE_ID/assets | jq -r '.[] | select(.name == '\"$ASSET_NAME\"') | .id')

  if [ -z "$ASSET_ID" ]; then
    curl -s -L -X POST \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Content-Type: application/vnd.github+json" \
    --data-binary "@release.json" \
    https://uploads.github.com/repos/$GITHUB_REPOSITORY/releases/$RELEASE_ID/assets?name=release.json
  else
      # curl -L \
      #   -X DELETE \
      #   -H "Accept: application/vnd.github+json" \
      #   -H "Authorization: Bearer $GITHUB_TOKEN" \
      #   -H "X-GitHub-Api-Version: 2022-11-28" \
      #   https://api.github.com/repos/$GITHUB_REPOSITORY/releases/assets/$ASSET_ID
    return
  fi
}

# Determine the GENERAL_VERSION
if [ -n "$INPUT_VERSION" ]; then
  GENERAL_VERSION="$INPUT_VERSION"
elif [ "$GITHUB_REF" = "refs/heads/main" ]; then
  GENERAL_VERSION="${MAJOR}.${MINOR}.${FIX}"
elif [ "$GITHUB_REF_TYPE" = "tag" ]; then
  GENERAL_VERSION=$(echo "$GITHUB_REF" | sed 's/^v//')
else
  GENERAL_VERSION="$GITHUB_REF"
fi
echo "general_version=${GENERAL_VERSION}"

for d in *; do
  if [ -d "$d" ] && [ ! -f "$d/skip" ]; then
    # Check if Dockerfile has a version specified
    VERSION=$(awk -F= '/^ARG VERSION=/ {print $2}' "$d/$d.Dockerfile" | tr -d ' ')
    if [ -z "$VERSION" ]; then
      # Use the general version if not specified in Dockerfile
      VERSION="${GENERAL_VERSION}"
    fi

    if [ -z "$result" ]; then
      result="\"$d\""
      result1="\"$d\": { \"version\": \"$VERSION\" }"
    else
      result+=",\"$d\""
      result1+=", \"$d\": { \"version\": \"$VERSION\" }"
    fi
  fi
done

echo "images=[$result]"
echo "images_metadata={$result1}"
echo "version=${GENERAL_VERSION}"

upload_release_metadata "{$result1}"