#!/usr/bin/env bash

GITHUB_REF=$1
GITHUB_REF_TYPE=$2
INPUT_VERSION=$3

cd builders || exit 1
result=""
result1=""
upload_assets () {
  RELEASE_ID=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_REPOSITORY/releases/tags/$RELEASE_VERSION" | jq -r '.id')

  #curl -X PATCH -H "Authorization: Bearer $GITHUB_TOKEN" -H "Accept: application/vnd.github.v3+json" -d '{"body": "'"$RELEASE_REPORT"'"}' "https://api.github.com/repos/$GITHUB_REPOSITORY/releases/$RELEASE_ID"
  touch release.json
  curl -L -X POST -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_REPOSITORY/releases/$RELEASE_ID/assets?name=release-${GENERAL_VERSION}.json" -H "Content-Type: text/plain" --data-binary "@release.json"

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
upload_assets
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