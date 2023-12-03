VERSION=$(grep -E '^ARG VERSION=' "$d/$d.Dockerfile" | awk '{print $3}')
echo $d
if  [ -z "${VERSION}" ] || [ -z "$(echo "$VERSION" | tr -d '[:space:]')" ]; then 
 # Use the general version if not specified in Dockerfile or empty
  VERSION="${GENERAL_VERSION}"
  echo "HI"
fi
