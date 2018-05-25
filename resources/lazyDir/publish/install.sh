#!/bin/bash -e

# Get the script dir
SDIR="$(dirname $0)"

# Inject common script from stage dir or parent dir
source "${SDIR}/common.sh" || source "${SDIR}/../common.sh"

$PKG_MNG install ${1}
