#!/usr/bin/env bash

# Usage: generate_release_report.sh <images_metadata_json> <release_version> <github_token>
metadata=$(jq -r '.[]' <<< "$1")
RELEASE_VERSION="$2"
GITHUB_TOKEN="$3"
#GITHUB_REPOSITORY="Technobureau/demo"
# Initialize release report and header
RELEASE_REPORT="#  Released Packages $RELEASE_VERSION \n"
RELEASE_REPORT+="|  Package | Image Tag | SHA | Created Date |\n"
RELEASE_REPORT+="| :-: | :-: | :-: | :-: |"

# Get release ID
RELEASE_ID=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_REPOSITORY/releases/tags/$RELEASE_VERSION" | jq -r '.id')

# Define asset name
ASSET_NAME=release.json

# Download existing asset (if exists)
ASSET_ID=$(curl -L -s -H "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/repos/$GITHUB_REPOSITORY/releases/$RELEASE_ID/assets | jq -r '.[] | select(.name == '\"$ASSET_NAME\"') | .id')

if [[ ! -z "$ASSET_ID" ]]; then
  # Download and store existing data
  curl -s -L \
    -H "Accept: application/octet-stream" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/$GITHUB_REPOSITORY/releases/assets/$ASSET_ID > $ASSET_NAME

  existing_data=$(cat $ASSET_NAME)

# Use jq to merge and update report
merged_data=$(echo "$existing_data" "$metadata" | jq -s '.[0] * .[1]')

jq '.' > "$ASSET_NAME" <<< "$merged_data"

# Loop through image data and update report
for image in $(jq -r 'keys[]' <<< "$merged_data"); do
  # Extract image details
  BUILD_TAG=$(echo "$merged_data" | jq -r ".[\"$image\"].BUILD_TAG")
  IMAGE_ID=$(echo "$merged_data" | jq -r ".[\"$image\"].IMAGE_ID")
  CREATED=$(echo "$merged_data" | jq -r ".[\"$image\"].CREATED")

  # Update report with extracted details
  RELEASE_REPORT+="\n|$image|$BUILD_TAG|$IMAGE_ID|$CREATED|"
done

# Print final release report
echo -e "$RELEASE_REPORT"
echo -e "\n"

# Update release body on GitHub
curl -s -X PATCH -H "Authorization: Bearer $GITHUB_TOKEN" -H "Accept: application/vnd.github.v3+json" -d '{"body": "'"$RELEASE_REPORT"'"}' "https://api.github.com/repos/$GITHUB_REPOSITORY/releases/$RELEASE_ID" > /dev/null

#If existing asset exists, delete it
curl -s -L -X DELETE \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/$GITHUB_REPOSITORY/releases/assets/$ASSET_ID > /dev/null

# Upload updated data as new asset
# curl -s -L -X POST \
#     -H "Authorization: Bearer $GITHUB_TOKEN" \
#     -H "Content-Type: application/vnd.github+json" \
#     --data-binary "@$ASSET_NAME" \
#     https://uploads.github.com/repos/$GITHUB_REPOSITORY/releases/$RELEASE_ID/assets?name=$ASSET_NAME > /dev/null
fi
exit 0
