#!/bin/bash

# Check if there is an installer file located at $INSTALLER_DIR/$INSTALLER_NAME. 
# If not found, download the version $INSTALL_VERSION to directory $INSTALLER_DIR with name $INSTALLER_NAME. 
# For downloading the url $QT_ARCHIVE_URL is used.
# Given INSTALL_VERSION, the script will build the correct subpath in the format /MAJOR.MINOR/MAJOR.MINOR.PATH/<installername>
echo Calling script $0
echo Arguments:
#echo $1
#echo $2
#echo $3
#echo $4

args=("$@")
INSTALLER_DIR=${args[0]}
INSTALLER_NAME=${args[1]}
QT_ARCHIVE_URL=${args[2]}
INSTALL_VERSION=${args[3]}

echo INSTALLER_DIR $INSTALLER_DIR
echo INSTALLER_NAME $INSTALLER_NAME
echo QT_ARCHIVE_URL $QT_ARCHIVE_URL
echo INSTALL_VERSION $INSTALL_VERSION

# If the installer is not found, download it!
if [ ! -f $INSTALLER_DIR/$INSTALLER_NAME ]; then

    if [ -z "$INSTALL_VERSION" ]; then
        # The required version is not specified! 
        echo "Download failed. Please specify the version via --version=X.YY.Z"
        exit 1
    fi
    
    echo "Installer not found! Trying to download to dir " $INSTALLER_DIR "..."

    # Parse INSTALL_VERSION. Initializes: MAJOR, MINOR, PATCH, QT_PREFIX
    MAJOR=$(cut -c-1 <<< ${INSTALL_VERSION}) # For Qt5.xx.x this yields 5
    MINOR=$(sed 's/\./\n/g' <<< ${INSTALL_VERSION} | awk 'NR==2')
    PATCH=$(sed 's/\./\n/g' <<< ${INSTALL_VERSION} | awk 'NR==3')
    QT_PREFIX="qt.qt"$MAJOR.${MAJOR}${MINOR}${PATCH}.
    echo Qt Version $INSTALLER_VERSION breakdown
    echo Major 
    echo $MAJOR
    echo Minor
    echo $MINOR
    echo Patch
    echo $PATCH
    echo Qt package prefix is
    echo $QT_PREFIX
    
    #URL=https://download.qt.io/archive/qt/$MAJOR.$MINOR/$MAJOR.$MINOR.$PATCH/$INSTALLER_NAME
    URL=$QT_ARCHIVE_URL/$MAJOR.$MINOR/$MAJOR.$MINOR.$PATCH/$INSTALLER_NAME
    echo "Downloading from url "$URL
    mkdir $INSTALLER_DIR
    curl -o $INSTALLER_DIR/$INSTALLER_NAME -sL $URL
fi
