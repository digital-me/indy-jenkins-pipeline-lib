#!/bin/bash -e

# Get the relative dir to this script and source common bloc
SDIR="$(dirname $0)"
source "${SDIR}/common.sh" || source "${SDIR}/../common.sh"

# Default variables
: ${REPO_BRANCH:='master'}

# Some required commands
SUDO='/usr/bin/sudo'	&& test -x $SUDO

# Add a local repo and verify the installation with dependencies
case "${DIST}" in
	centos*)
		$SUDO $YUM-config-manager --save indy --setopt "indy.baseurl=file://${WORKSPACE}/${BUILD_DIR}/dists/${DIST}/${REPO_BRANCH}"
		$SUDO $YUM -y clean expire-cache
		$SUDO $YUM -y install ${1}
	;;
	debian*|ubuntu*)
		$SUDO $SED -r -e "s;^deb\s+${REPO_BASEURL}.+\$;deb file://${WORKSPACE}/${BUILD_DIR}/ ${DIST} ${REPO_BRANCH};" \
			-i /etc/apt/sources.list.d/indy.list
		$SUDO $APT-get -y update
		$SUDO DEBIAN_FRONTEND=noninteractive $APT-get -y --allow-unauthenticated install ${1}
	;;
esac
