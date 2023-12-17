#!/bin/bash
# Copyright VMware, Inc.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/technobureau/scripts/libnginx.sh

# Load NGINX environment variables
. /opt/technobureau/scripts/nginx-env.sh

/opt/technobureau/scripts/nginx/stop.sh
/opt/technobureau/scripts/nginx/start.sh