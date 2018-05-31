#!/bin/bash -e

# Get the relative dir to this script and source common bloc
SDIR="$(dirname $0)"
source "${SDIR}/common.sh" || source "${SDIR}/../common.sh"

# Default variables
: ${BUILD_DIR:='target'}
: ${REPO_BRANCH:='master'}
: ${DST_DIR:="dists/${DIST}/${REPO_BRANCH}"}

# Enter the directory where the packages should be
pushd "${WORKSPACE}/${BUILD_DIR}"

# Move unarchived packages to the relevant sub dir
case "${DIST}" in
	centos*)
		test -d "${DST_DIR}" || mkdir -p "${DST_DIR}"
		mv -f "${DIST}"/*.rpm "${DST_DIR}"
		/usr/bin/createrepo --pretty --compress-type=gz "${DST_DIR}"
	;;
	debian*|ubuntu*)
		test -d "${DST_DIR}/binary-${PKG_ARCH}" || mkdir -p "${DST_DIR}/binary-${PKG_ARCH}"
		mv -f "${DIST}"/*.deb "${DST_DIR}/binary-${PKG_ARCH}"
		/usr/bin/dpkg-scanpackages --multiversion "${DST_DIR}/binary-${PKG_ARCH}" /dev/null | $GZIP -9c > ${DST_DIR}/binary-${PKG_ARCH}/Packages.gz
	;;
esac

popd
