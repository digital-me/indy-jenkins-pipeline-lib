#!/bin/bash -e

# Get the relative dir to this script and source common bloc
SDIR="$(dirname $0)"
source "${SDIR}/common.sh" || source "${SDIR}/../common.sh"

# Default variables
: ${REPO_BRANCH:='master'}

# Add a local repo and verify the installation with dependencies
case "${DIST}" in
	centos*)
		$SUDO $YUM-config-manager --add-repo "file://${WORKSPACE}/${BUILD_DIR}/dists/${DIST}/${REPO_BRANCH}"
		$SUDO $YUM -y clean expire-cache
		$SUDO $YUM -y install ${1}
	;;
	debian*|ubuntu*)
		$SUDO $APT-add-repository -y -u "deb file://${WORKSPACE}/${BUILD_DIR}/ ${DIST} ${REPO_BRANCH}"
		$SUDO $APT-get -y update
		$SUDO $APT-get -y --allow-unauthenticated install ${1}
	;;
esac
