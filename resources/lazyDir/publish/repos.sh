#!/bin/bash -e

# Get the relative dir to this script and source common bloc
SDIR="$(dirname $0)"
source "${SDIR}/common.sh" || source "${SDIR}/../common.sh"

# Default variables
: ${BUILD_DIR:='dist'}
: ${DIST_DIR:=${WORKSPACE}/${BUILD_DIR}/${DIST}}

# Enter the directory where the packages should be
pushd "${DIST_DIR}"

case "${DIST}" in
	centos*)
		/usr/bin/createrepo --pretty --compress-type=gz .
	;;
	debian*|ubuntu*)
		mkdir -p binary && mv *.deb binary
		/usr/bin/dpkg-scanpackages --multiversion binary /dev/null | $GZIP -9c > binary/Packages.gz
	;;
esac

popd
