#!/bin/bash -e

# Catch error in pipes
set -o pipefail

# Define some default value, in case the environment is not set (by Jenkins for instance)
: ${DIST:="${LAZY_LABEL}"}
: ${WORKSPACE:="${PWD}"}

# Set some dry-run options/arguments
if [ -n "${DRYRUN}" -a "${DRYRUN}" != '0' -a "${DRYRUN}" != 'false' ]; then
	DRY_CMD='echo '
	DRY_ARG='-n'
fi

# Some general useful commands
CAT='/bin/cat'				&& test -x $CAT
CUT='/usr/bin/cut'		&& test -x $CUT
GREP='/bin/grep'			&& test -x $GREP
GZIP='/bin/gzip'			&& test -x $GZIP
SED='/bin/sed'				&& test -x $SED
SUDO='/usr/bin/sudo'	&& test -x $SUDO
TR='/usr/bin/tr'				&& test -x $TR

# Figure out the distro name if not supplied
if [ -z "${DIST}" ]; then
	if [ -x /usr/bin/lsb_release ]; then
		DIST_ID="$(lsb_release -is | $TR [:upper:] [:lower:])"
		DIST_RN="$(lsb_release -rs | $CUT -d'.' -f1)"
	elif [ -r /etc/redhat-release ]; then
		DIST_ID="$($GREP -Po "^\w+" /etc/redhat-release | $TR [:upper:] [:lower:])"
		DIST_RN="$($GREP -Po "[\d\.]+" /etc/redhat-release | $CUT -d'.' -f1)"
	fi
	DIST="${DIST_ID}-${DIST_RN}"
fi
# Give up if the distro is still unknown
[ -n "${DIST}" -o "${DIST}" = '-' ] || { echo "Undefined distribution!"; exit 1; }

# Some distro specific command
case "${DIST}" in
	centos*)
		RPM='/bin/rpm'			&& test -x $RPM
		YUM='/usr/bin/yum'		&& test -x $YUM
		PKG_EXT='rpm'
		PKG_MNG="$SUDO $YUM"
		PYTHON='/bin/python3.5'
		PYTHON_PREFIX="$($RPM -q --whatprovides ${PYTHON} --queryformat '%{name}' 2> /dev/null | $CUT -d'-' -f1 || echo 'python35u')"
		PIP='/bin/pip3.5'
	;;
	debian*|ubuntu*)
		DPKG='/usr/bin/dpkg'	&& test -x $DPKG
		APT='/usr/bin/apt'		&& test -x $APT
		PKG_EXT='deb'
		PKG_MNG="$SUDO $APT-get"
		PYTHON='/usr/bin/python3.5'
		PYTHON_PREFIX="$($DPKG-query --search ${PYTHON} 2> /dev/null | $CUT -d'-' -f1 || echo '')"
		PIP='/usr/bin/pip3'
	;;
	*)
		echo "Unknown distribution (= ${DIST})"
		exit 1
	;;
esac

# Some extra reusable variables
PYTHON_VER_STR="$(${PYTHON} --version 2> /dev/null || echo 'unknown')"
PYTHON_VER="${PYTHON_VER_STR##* }"
