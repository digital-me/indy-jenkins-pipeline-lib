#!/bin/bash -e

# Get the relative dir to this script and source common bloc
SDIR="$(dirname $0)"
source "${SDIR}/common.sh" || source "${SDIR}/../common.sh"

# Default variables
: ${BUILD_DIR:='dist'}
: ${DIST_DIR:=${WORKSPACE}/${BUILD_DIR}/${DIST}}

# Add a local repo and verify the installation with dependencies
case "${DIST}" in
	centos*)
		$YUM -y clean expire-cache
		$YUM-config-manager --add-repo "file://${DIST_DIR}/"
		$YUM -y install ${1}
	;;
	debian*|ubuntu*)
		$APT-get -y update
		$APT-add-repository -y -u "file://${DIST_DIR}/"
		$APT-get -y install ${1}
	;;
esac
