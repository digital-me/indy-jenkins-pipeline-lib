#!/bin/bash -e

# Get the relative dir to this script and source common bloc
SDIR="$(dirname $0)"
source "${SDIR}/common.sh" || source "${SDIR}/../common.sh"

# Default variables
: ${BUILD_DIR:='dist'}
: ${DIST_DIR:=${WORKSPACE}/${BUILD_DIR}/${DIST}}
: ${REPO_BRANCH:='master'}

# Enter the directory where the packages should be
pushd "${DIST_DIR}"

# Move unarchived packages to the relevant sub dir
case "${DIST}" in
	centos*)
		mv -f *.rpm ${REPO_BRANCH}
		/usr/bin/createrepo --pretty --compress-type=gz ${REPO_BRANCH}
	;;
	debian*|ubuntu*)
		mv -f *.deb ${REPO_BRANCH}/binary
		/usr/bin/dpkg-scanpackages --multiversion ${REPO_BRANCH}/binary /dev/null | $GZIP -9c > ${REPO_BRANCH}/binary/Packages.gz
	;;
esac

popd
