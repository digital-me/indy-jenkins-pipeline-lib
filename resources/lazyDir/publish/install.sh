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
		$SUDO $YUM-config-manager --add-repo "file://${DIST_DIR}/"
		$SUDO $YUM -y clean expire-cache
		$SUDO $YUM -y install ${1}
	;;
	debian*|ubuntu*)
		$SUDO $APT-add-repository -y -u "deb file://${WORKSPACE}/${BUILD_DIR}/ ${DIST_DIR}/"
		$SUDO $APT-get -y update
		$SUDO $APT-get -y install ${1}
	;;
esac
