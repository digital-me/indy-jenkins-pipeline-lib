#!/bin/bash -e

# Catch error in pipes
set -o pipefail

# Define some default value, in case the environment is not set (by Jenkins for instance)
: ${DIST:="${LAZY_LABEL}"}
: ${WORKSPACE:="${PWD}"}

# Figure out the distro name if not supplied
if [ -z "${DIST}" ]; then
	if [ -x /usr/bin/lsb_release ]; then
		DIST_ID="$(lsb_release -is | tr [:upper:] [:lower:])"
		DIST_RN="$(lsb_release -rs | cut -d'.' -f1)"
	elif [ -r /etc/redhat-release ]; then
		DIST_ID="$(grep -Po "^\w+" /etc/redhat-release | tr [:upper:] [:lower:])"
		DIST_RN="$(grep -Po "[\d\.]+" /etc/redhat-release | cut -d'.' -f1)"
	fi
	DIST="${DIST_ID}-${DIST_RN}"
fi
# Give up if the distro is still unknown
[ -n "${DIST}" -o "${DIST}" = '-' ] || { echo "Undefined distribution!"; exit 1; }

# Set some dry-run options/arguments
if [ -n "${DRYRUN}" -a "${DRYRUN}" != '0' -a "${DRYRUN}" != 'false' ]; then
	DRY_CMD='echo '
	DRY_ARG='-n'
fi

case "${DIST}" in
	centos*)
		SUDO='/usr/bin/sudo'
		PYTHON='/bin/python3.5'
		PYTHON_PREFIX="$(rpm -q --whatprovides ${PYTHON} --queryformat '%{name}' 2> /dev/null | cut -d'-' -f1 || echo 'python35u')"
		PIP='/bin/pip3.5'
		PKG_EXT='rpm'
		PKG_MNG="$SUDO /usr/bin/yum"
		YUM="$PKG_MNG"
	;;
	debian*|ubuntu*)
		SUDO='/usr/bin/sudo'
		PYTHON='/usr/bin/python3.5'
		PYTHON_PREFIX="$(dpkg-query --search ${PYTHON} 2> /dev/null | cut -d'-' -f1 || echo '')"
		PIP='/usr/bin/pip3'
		PKG_EXT='deb'
		PKG_MNG="$SUDO /usr/bin/apt-get"
		APT="$PKG_MNG"
	;;
	*)
		echo "Unknown distribution (= ${DIST})"
		exit 1
	;;
esac

# Some general useful reusable commands and variables
PYTHON_VER_STR="$(${PYTHON} --version 2> /dev/null || echo 'unknown')"
PYTHON_VER="${PYTHON_VER_STR##* }"
: ${RSYNC_OPTIONS:="-hal --stats --exclude=\"lost+found\""}
RSYNC="/usr/bin/rsync ${RSYNC_OPTIONS}"
GZIP='/bin/gzip'
