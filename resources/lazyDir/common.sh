#!/bin/bash -e

# Define some default value, in case the environment is not set
: ${LAZY_LABEL:='unknown'}
# Export LAZY_LABEL as DIST for later use
export DIST=${LAZY_LABEL}

# Paths to general tools
RSYNC='/usr/bin/rsync'
: ${RSYNC_OPTIONS:="-hal --stats --exclude=\"lost+found\""}
GZIP='/bin/gzip'

# Set some dry-run options/arguments
if [ -n "${DRYRUN}" -a "${DRYRUN}" != '0' -a "${DRYRUN}" != 'false' ]; then
	DRY_CMD='echo '
	DRY_ARG='-n'
fi

case "${DIST}" in
	centos*)
		PYTHON='/bin/python3.5'
		PYTHON_PREFIX="$(rpm -q --whatprovides ${PYTHON} --queryformat '%{name}' 2> /dev/null | cut -d'-' -f1 || echo 'python35u')"
		PIP='/bin/pip3.5'
		PKG_EXT='rpm'
		PKG_MNG='/usr/bin/yum'
	;;
	ubuntu*)
		PYTHON='/usr/bin/python3.5'
		PYTHON_PREFIX="$(dpkg-query --search ${PYTHON} 2> /dev/null | cut -d'-' -f1 || echo '')"
		PIP='/usr/bin/pip3'
		PKG_EXT='deb'
		PKG_MNG='/usr/bin/apt-get'
	;;
	*) # Fall-back, only if called without DIST set
		[ -x '/usr/bin/which' ] || { echo "Can not found 'which'!"; exit 1; }
		PYTHON="$(which python)" 
		PYTHON_PREFIX='python'
		PIP="$(which pip)"
		which rpm &> /dev/null && PKG_EXT='rpm' || PKG_EXT='deb'
		which yum &> /dev/null && PKG_MNG="$(which yum)" || PKG_MNG="$(which apt-get)"
	;;
esac

PYTHON_VER_STR="$(${PYTHON} --version 2> /dev/null || echo 'unknown')"
PYTHON_VER="${PYTHON_VER_STR##* }"
