#!/bin/sh

#########################################
# A few variables to make things readable

# Package specific variables
PACKAGE="python26"
DNAME="Python 2.6"

# Common variables
INSTALL_DIR="/usr/local/${PACKAGE}"
VAR_DIR="/usr/local/var/${PACKAGE}"
UPGRADE="/tmp/${PACKAGE}.upgrade"
PATH="${INSTALL_DIR}/bin:/bin:/usr/bin" # Avoid ipkg commands

SYNO3APP="/usr/syno/synoman/webman/3rdparty"

#########################################
# DSM package manager functions

preinst ()
{
    exit 0
}

postinst ()
{
    # Installation directories
    mkdir -p ${INSTALL_DIR}
    mkdir -p ${VAR_DIR}/run

    # Extract the files to the installation ditectory
    ${SYNOPKG_PKGDEST}/sbin/xzdec -c ${SYNOPKG_PKGDEST}/package.txz | \
        tar xpf - -C ${INSTALL_DIR}
    # Remove the installer archive to save space
    rm ${SYNOPKG_PKGDEST}/package.txz

    # Install xzdec for the companion tools installation
    cp ${SYNOPKG_PKGDEST}/sbin/xzdec ${INSTALL_DIR}/bin/xzdec
    # Install the adduser and deluser hardlinks
    ${INSTALL_DIR}/bin/busybox --install ${INSTALL_DIR}/bin

    # Byte-compile the python distribution
    ${INSTALL_DIR}/bin/python -m compileall -q -f ${INSTALL_DIR}/lib/python2.6
    ${INSTALL_DIR}/bin/python -OO -m compileall -q -f ${INSTALL_DIR}/lib/python2.6

    exit 0
}

preuninst ()
{
    for ctl in ${VAR_DIR}/run/*-ctl
    do
        ${ctl} stop
    done
    
    exit 0
}

postuninst ()
{
    # Remove the installation directory
    rm -fr ${INSTALL_DIR}
    rm -fr ${VAR_DIR}

    exit 0
}

preupgrade ()
{
    exit 0
}

postupgrade ()
{
    exit 0
}
