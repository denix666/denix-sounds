#! /bin/bash

PROJECT_DIR=`dirname $(which $0)`
SPEC_FILE="${PROJECT_DIR}/$(basename ${PROJECT_DIR}).spec"
TARGET_OS="x1"
BUILD_SOURCE="yes"

# Check if required packages installed
pk="rpmdevtools rpm-build createrepo"
for i in $pk; do
	if ! rpm -q $i >/dev/null 2>&1; then
		required_packages="$required_packages $i"
	fi
done

# Install the required packages (need root password)
if ! [ "$required_packages" = "" ]; then
	echo "Some packages not found on your system. Trying to download and install..."
	if ! su -c "yum -y install $required_packages"; then
		echo "Download failed! Check internet connection and try again!"
		exit 1
	else
		echo "Installation success!"
	fi
fi

# Check _topdir definitions
if ! [ -f $(echo ${HOME})/.rpmmacros ]; then
    echo "%_topdir	%(echo \${HOME})/.rpmbuild" > $(echo ${HOME})/.rpmmacros
fi

# Define _topdir from rpmmacros
TOPDIR=${HOME}/`cat $(echo ${HOME})/.rpmmacros | grep "_topdir" | awk -F")/" '{print $2}'`

# Check buildroot
if ! [ -d ${TOPDIR} ]; then
    rpmdev-setuptree
    mkdir -p ${TOPDIR}/BUILDROOT
fi

if ! [ -f ${SPEC_FILE} ]; then
    echo "SPEC file ${SPEC_FILE} not found!"
    exit 1
fi

PK_VERSION=`cat ${SPEC_FILE} | grep ^Version: | awk {'print $2'}`
PK_RELEASE=`cat ${SPEC_FILE} | grep ^Release: | awk {'print $2'} | awk -F% {'print $1'}`
PK_ARCH=`cat ${SPEC_FILE} | grep ^BuildArch: | awk {'print $2'}`
PK_NAME=`cat ${SPEC_FILE} | grep ^Name: | awk {'print $2'}`

# Copy spec file to _topdir
cp ${SPEC_FILE} ${TOPDIR}/SPECS

# Create temporary directory
TMP_DIR=$(mktemp -d /tmp/${PK_NAME}.XXXXXXXXXX) || { echo "Failed to create temp file"; exit 1; }
mkdir ${TMP_DIR}/${PK_NAME}

# Copy sources to temp dir
for i in bin sbin etc lib usr var srv opt; do
    if [ -e ${PROJECT_DIR}/$i ]; then
	echo "Copying directory: $i"
	cp -Rf ${PROJECT_DIR}/$i ${TMP_DIR}/${PK_NAME}
    fi
done

# Create the tarball
pushd ${TMP_DIR} >/dev/null 2>&1
rm -rf ${TOPDIR}/SOURCES/${PK_NAME}.tar.gz
tar cvfz ${TOPDIR}/SOURCES/${PK_NAME}.tar.gz ${PK_NAME} >/dev/null 2>&1
popd >/dev/null 2>&1

# Remove temporary files
rm -rf ${TMP_DIR}

# Check if we want to build source package
if [ "${BUILD_SOURCE}" = "yes" ]; then
    BUILD_CMD="-ba"
else
    BUILD_CMD="-bb"
fi

# Create the RPM package
for i in ${TARGET_OS}; do
    if ! rpmbuild ${BUILD_CMD} ${TOPDIR}/SPECS/${PK_NAME}.spec --define "dist .$i"; then
	echo "RPM not created!"
	exit 1
    else
	echo
	echo "RPM successfully created!"
	echo
	for y in ${TARGET_OS}; do
	    echo "Install package: ${TOPDIR}/RPMS/noarch/${PK_NAME}-${PK_VERSION}-${PK_RELEASE}.${y}.${PK_ARCH}.rpm"
	done
	echo
	if [ "${BUILD_SOURCE}" = "yes" ]; then
	    for y in ${TARGET_OS}; do
		echo "Source package: ${TOPDIR}/SRPMS/${PK_NAME}-${PK_VERSION}-${PK_RELEASE}.${y}.src.rpm"
	    done
	fi
	echo
    fi
done
