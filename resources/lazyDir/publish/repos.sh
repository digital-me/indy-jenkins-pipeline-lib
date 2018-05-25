#!/bin/bash -e

# Get the script dir
SDIR="$(dirname $0)"

# Inject common script from stage dir or parent dir
source "${SDIR}/common.sh" || source "${SDIR}/../common.sh"

pushd "${PWD}/dist/${DIST}"

case "${DIST}" in
	centos*)
		/usr/bin/createrepo --pretty --compress-type=gz .
	;;
	ubuntu*)
		/usr/bin/dpkg-scanpackages --multiversion . /dev/null | $GZIP -9c > Packages.gz
	;;
	*) # Fall-back, only if called without DIST set
	;;
esac

popd
