#!/bin/bash -e

# Get the relative dir to this script and source common bloc
SDIR="$(dirname $0)"
source "${SDIR}/common.sh" || source "${SDIR}/../common.sh"

# Prepare folder to store packages
: ${OUTPUT_PATH:="${1:-"${PWD}/${BUILD_DIR}/${DIST}"}"}
[ -d "${OUTPUT_PATH}" ] || mkdir -p "${OUTPUT_PATH}" 

# Get dependency list from argument or Python full requirements file
: ${DEPS:="${2:-${SDIR}/requirements-full.txt}"}

# Prepare temp folder to build packages 
TDIR="$(mktemp -p /var/tmp -d fpm.XXXXXXXXXX)"
trap "rm -rf ${TDIR}" EXIT

# Define function to build Python packages from PyPi
function build_from_pypi {
	PACKAGE_NAME="$1"

	if [ "${PACKAGE_NAME}" == 'Charm-Crypto' ];
	then
		EXTRA_DEPENDENCE='-d libpbc0'
	else
		EXTRA_DEPENDENCE=''
	fi

	if [ -z "$2" ]; then
		PACKAGE_VERSION=''
	else
		PACKAGE_VERSION="==$2"
	fi
	
	POSTINST_TMP="postinst-${PACKAGE_NAME}"
	PREREM_TMP="prerm-${PACKAGE_NAME}"

	# Copy post and pre scripts in temp folder
	cp "${SDIR}/postinst" "${TDIR}/${POSTINST_TMP}"
	cp "${SDIR}/prerm" "${TDIR}/${PREREM_TMP}"

	# Enter temp folder
	pushd "${TDIR}"

	sed -i 's/{package_name}/python3-'${PACKAGE_NAME}'/' "${POSTINST_TMP}"
	sed -i 's/{package_name}/python3-'${PACKAGE_NAME}'/' "${PREREM_TMP}"

	fpm --input-type 'python' \
		--output-type "${PKG_EXT}" \
		--log warn \
		--python-package-name-prefix "${PYTHON_PREFIX}" \
		--python-bin "${PYTHON}" \
		--exclude '*.pyc' \
		--exclude '*.pyo' \
		${EXTRA_DEPENDENCE} \
		--maintainer "Hyperledger <hyperledger-indy@lists.hyperledger.org>" \
		--after-install "${POSTINST_TMP}" \
		--before-remove "${PREREM_TMP}" \
		--package "${OUTPUT_PATH}" \
		"${PACKAGE_NAME}${PACKAGE_VERSION}"

	rm "${POSTINST_TMP}"
	rm "${PREREM_TMP}"

	# Exit temp folder
	popd
}

while read DEP
do
	build_from_pypi "${DEP}"
done < <(cat "${DEPS}" | grep -Ev '^ *(#|$)' | grep -Eo '[^ ]+')
