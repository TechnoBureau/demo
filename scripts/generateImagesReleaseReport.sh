#!/usr/bin/env bash
images=${{ needs.initialize.outputs.images }}
releaseReport="# 🚀 Released Packages $RELEASE 🚀\n"
releaseReport+="| 📦 Package | Internal Repository Location | Public Repository Location |\n"
releaseReport+="| :-: | :-: | :-: |"
IFS=',' read -ra imageArray <<< "$images"
for image in "${imageArray[@]}"; do
  releaseReport+="\n|$image|${{ needs.initialize.outputs.version }}|1.0.0|"
done
echo -e "$releaseReport" >> $GITHUB_STEP_SUMMARY
echo -e "\n" >> $GITHUB_STEP_SUMMARY
# echo "RELEASE_REPORT=$releaseReport" >> $GITHUB_OUTPUT

RELEASE_ID=$(curl -s -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" "https://api.github.com/repos/${{ github.repository }}/releases/tags/${{ needs.initialize.outputs.version }}" | jq -r '.id')
echo "RELEASE_ID=${RELEASE_ID}" >> $GITHUB_OUTPUT

curl -X PATCH -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" -H "Accept: application/vnd.github.v3+json" -d '{"body": "'"$releaseReport"'"}' "https://api.github.com/repos/${{ github.repository }}/releases/${RELEASE_ID}"