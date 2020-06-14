# Try to read the login credentials from the system environment variables
QT_INSTALLER_LOGIN_MAIL=${QT_INSTALLER_LOGIN_MAIL}
QT_INSTALLER_LOGIN_PW=${QT_INSTALLER_LOGIN_PW}

# -z checks for emptyness of variable
if [ -z "${QT_INSTALLER_LOGIN_MAIL}" ]; then
    :
else
    echo "Found qt login email in system environment"
fi
if [ -z "${QT_INSTALLER_LOGIN_MAIL}" ]; then
    :
else
    echo "Found qt login password in system environment"
fi

for i in "$@"
do
#echo "Parsing option" $i
case $i in
    --list-packages)
    LIST_PACKAGES=1
    echo "Task: list packages"
    shift # past argument=value
    ;;
    --cleanup)
    DELETE_UNNECESSARY_DIRS=1
    echo "Task: Delete unnecessary directories"
    shift # past argument=value
    ;;
    --export-control-script)
    EXPORT_CONTROL_SCRIPT=1
    echo "Task: Export the control script with all variables hardcoded."
    shift # past argument=value
    ;;
    --export-credentials-insecure)
    PLAIN_TEXT_EXPORT_CREDENTIALS=1
    echo "Task: Export plain text credentials. SECURITY RISK!"
    shift # past argument=value
    ;;
    --filedir=*)
    INSTALLER_DIR="${i#*=}"
    echo "Installer directory is:" $INSTALLER_DIR
    shift # past argument=value
    ;;
    --filename=*)
    INSTALLER_NAME="${i#*=}"
    echo "Installer name is:" $INSTALLER_NAME
    shift # past argument=value
    ;;
    -v=*|--version=*)
    INSTALL_VERSION="${i#*=}"
    echo "Version to be installed: " $INSTALL_VERSION
    shift # past argument=value
    ;;
    --packages=*)
    INSTALL_PACKAGES="${i#*=}"
    echo "Packages to be installed: " $INSTALL_PACKAGES
    shift # past argument=value
    ;;
    --installdir=*)
    INSTALLDIR="${i#*=}"
    echo "Installation directory: " $INSTALLDIR
    shift # past argument=value
    ;;
    --archive-url=*)
    ARCHIVE_URL="${i#*=}"
    echo "Download archive url: " $ARCHIVE_URL
    shift # past argument=value
    ;;
    --only-download=*)
    ONLY_DOWNLOAD=1
    echo "Task: Only download, don't install."
    shift # past argument=value
    ;;
    -u=*|--username=*)
    if [ -z "${QT_INSTALLER_LOGIN_MAIL}" ]; then
        :
    else
        echo "Warning: Overwriting qt login email from system environment"
    fi
    QT_INSTALLER_LOGIN_MAIL="${i#*=}"
    shift # past argument=value
    ;;
    --target-os=*)
	TARGET_OS="${i#*=}"
    echo "Target operating system: " $TARGET_OS
    shift # past argument=value
    ;;
    --password=*)
    if [ -z "${QT_INSTALLER_LOGIN_PW}" ]; then
        :
    else
        echo "Warning: Overwriting qt login password from system environment"
    fi
    QT_INSTALLER_LOGIN_PW="${i#*=}"
    shift # past argument=value
    ;;
    --default)
    DEFAULT=YES
    shift # past argument with no value
    ;;
    *)
    # unknown option
    ;;
esac
done

if [ -z "$TARGET_OS" ]; then
    # No target operating system specified. Try to detect default.
    case "$(uname -s)" in
      darwin*|Darwin*)
        TARGET_OS=darwin
        ;;
      linux*|Linux*)
        TARGET_OS=linux
        ;;
      CYGWIN*|MSYS*|MINGW*)
        TARGET_OS=windows
        ;;
      *) echo "unknown (uname -s) when setting TARGET_OS: (uname -s)=$(uname -s)" ;;
    esac
fi

if [ -z "$INSTALLDIR" ]; then
    # No installation directory specified. Select default directory
    echo 
    case "$(TARGET_OS)" in
      darwin|Darwin)
        INSTALLDIR=/Users/${USER}/Qt${INSTALL_VERSION}
        ;;
      linux|Linux)
        INSTALLDIR=/home/${USER}/Qt${INSTALL_VERSION}
        ;;
      windows|Windows)
        INSTALLDIR=C:/Qt${INSTALL_VERSION}
        ;;
      solaris*) echo "SOLARIS" ;;
      bsd*) echo "BSD" ;;
      *) echo "unknown TARGET_OS when setting default install dir: TARGET_OS=$TARGET_OS" ;;
    esac
    echo "Installing/Downloading into default directory:" $INSTALLDIR
fi

# Maybe select a default installer name
if [ -z "$INSTALL_VERSION" ]
then
    # No version specified
    : #no-op
else
    # The version is specified
    if [ -z "$INSTALLER_NAME" ] # if the installation file is not specified
    then # Choose default installer names. The version string must be provided.
        case "$(TARGET_OS)" in
          darwin*)
            INSTALLER_NAME=qt-opensource-mac-x64-${INSTALL_VERSION}.dmg
            ;;
          linux*)
            INSTALLER_NAME=qt-opensource-linux-x64-${INSTALL_VERSION}.run
            ;;
          msys*)
            INSTALLER_NAME=qt-opensource-windows-x86-${INSTALL_VERSION}.exe
            ;;
          solaris*) echo "SOLARIS" ;;
          bsd*) echo "BSD" ;;
          *) echo "unknown TARGET_OS when setting default installer name: TARGET_OS=$TARGET_OS" ;;
        esac
        echo "Using default installer name:" $INSTALLER_NAME
    else
        :
    fi
fi

# Make variables available to the controller script 'control-script.qs'
export QT_LIST_PACKAGES=$LIST_PACKAGES
export QT_INSTALL_PACKAGES="$INSTALL_PACKAGES"
export QT_INSTALL_DIR="$INSTALLDIR"
export QT_INSTALLER_LOGIN_MAIL=$QT_INSTALLER_LOGIN_MAIL
export QT_INSTALLER_LOGIN_PW="$QT_INSTALLER_LOGIN_PW"

if [ -z "$ARCHIVE_URL" ]; then
    # If no download archive url has been specified, choose a default one:
    ARCHIVE_URL=https://download.qt.io/archive/qt/
fi

if [ -z "$EXPORT_CONTROL_SCRIPT" ]; then
    :
else
    echo "Exporting the control script."
    # We don't want to install; we just export the control script with hardcoded parameters.
    exportpath=$INSTALLER_DIR/control-script.exported.qs
    cp control-script.qs $exportpath

    # Replace parameters in script, if the parameter has been specified
    if [ -z "$QT_INSTALL_PACKAGES" ]; then :;
    else
        VALUE=$QT_INSTALL_PACKAGES
        sed -i -e "s|installer.environmentVariable(\"QT_INSTALL_PACKAGES\")|\"$VALUE\"|g" $exportpath 
    fi

    if [ -z "$QT_INSTALL_DIR" ]; then :;
    else
        VALUE=$QT_INSTALL_DIR
        sed -i -e "s|installer.environmentVariable(\"QT_INSTALL_DIR\")|\"$VALUE\"|g" $exportpath
    fi

    if [ -z "$QT_LIST_PACKAGES" ]; then :;
    else
        VALUE=$QT_LIST_PACKAGES
        sed -i -e "s|installer.environmentVariable(\"QT_LIST_PACKAGES\")|$VALUE|g" $exportpath
    fi

    # BEWARE!! SECURITY RISK
    if [ -z "$PLAIN_TEXT_EXPORT_CREDENTIALS" ]; then :;
    else
        VALUE=$QT_INSTALLER_LOGIN_MAIL
        sed -i -e "s|installer.environmentVariable(\"QT_INSTALLER_LOGIN_MAIL\")|\"$VALUE\"|g" $exportpath
        VALUE=$QT_INSTALLER_LOGIN_PW
        sed -i -e "s|installer.environmentVariable(\"QT_INSTALLER_LOGIN_PW\")|\"$VALUE\"|g" $exportpath
    fi

    exit 0;
fi

bash maybe-download-installer.sh $INSTALLER_DIR $INSTALLER_NAME $ARCHIVE_URL $INSTALL_VERSION 

if [ -z $ONLY_DOWNLOAD ]; then
    :
else
    echo Finished downloading the installer. Exit 0.
    exit 0; # We don't want to install; we just downloaded the file (in case it did not exist). Exit.
fi

# If no credentials provided, ask the user for input.
if [ -z "$QT_INSTALLER_LOGIN_MAIL" ] || [ -z "$QT_INSTALLER_LOGIN_PW" ]; then
    echo The installer requires to log in to Qt. Internet connection required! Please provide your login details.
    read -p 'Qt login username: ' QT_INSTALLER_LOGIN_MAIL
    read -sp 'Qt login password: ' QT_INSTALLER_LOGIN_PW
fi

if [ -f $INSTALLER_DIR/$INSTALLER_NAME ]; then
    case "$TARGET_OS" in
      darwin|Darwin)
        echo Installing on Darwin.
        ;;
      linux|Linux)
        echo Installing on Linux.
        chmod +x $INSTALLER_DIR/$INSTALLER_NAME
        ls -la $INSTALLER_DIR
        export QT_QPA_PLATFORM=minimal
        #installer_log=$($INSTALLER_DIR/$INSTALLER_NAME --script control-script.qs --verbose --silent -platform minimal);
        installer_log=$($INSTALLER_DIR/$INSTALLER_NAME --script control-script.qs --verbose);
        ;;
      windows|Windows)
        echo Installing on Windows.
        export QT_QPA_PLATFORM=windows
        installer_log=$($INSTALLER_DIR/$INSTALLER_NAME --script control-script.qs --verbose --silent);
        ;;
      solaris*) echo "SOLARIS" ;;
      bsd*) echo "BSD" ;;
      *) echo "unknown TARGET_OS when installing: TARGET_OS=$TARGET_OS. The installation was not started." 
    esac
else
    echo "Did not find the qt installer in the directory" $INSTALLER_DIR
    exit 1
fi

echo $installer_log > $INSTALLER_DIR/installer_log.txt

if [ -z "$LIST_PACKAGES" ]; then
    # Qt has been installed. Save info about installed packages, and clean up.

    echo $INSTALL_PACKAGES > temp.txt
    sed 's/ /\n/g' < temp.txt > QT_INSTALLED_PACKAGES.txt
    rm temp.txt

    if [ -z "$DELETE_UNNECESSARY_DIRS" ]
    then
        : #no-op: the flag has not been set
    else
        echo "Removing unnecessary files and directories from parent directory" $INSTALLDIR
        deleted=$(find $INSTALLDIR -mindepth 1 ! -regex "^${INSTALLDIR}/${INSTALL_VERSION}\(/.*\)?")
        find $INSTALLDIR -mindepth 1 ! -regex "^${INSTALLDIR}/${INSTALL_VERSION}\(/.*\)?" -delete
        echo $deleted > deleted.txt
    fi
else
    # Packages have been extracted. Write them to a file.

    # This was tested under Ubuntu 18.04 and works:

    # Replace \r with \n
    tr '\r' '\n' < $INSTALLER_DIR/installer_log.txt > $INSTALLER_DIR/installer_log_lf.txt

    # Split at space
    sed 's/ /\n/g' < $INSTALLER_DIR/installer_log_lf.txt > ${INSTALLER_DIR}/temp.txt

    pkgfile=${INSTALLER_DIR}/${INSTALLER_NAME}.available_packages.txt
    cat ${INSTALLER_DIR}/temp.txt | grep "^qt.*" > $pkgfile

    # Sort alphabetically
    sort -o ${pkgfile} ${pkgfile}

    echo Packages:
    cat ${pkgfile}

    exit 0

	# OLD CODE: Did not work on Linux. To be tested under windows!

    # Replace \r with \n
    tr '\r' '\n' < $INSTALLER_DIR/installer_log.txt > $INSTALLER_DIR/installer_log_lf.txt
    # Extract the 2nd last line that contains a list of all packages: extract last 2 lines, keep only 1st of those 2
    packages_line=$(cat $INSTALLER_DIR/installer_log_lf.txt | tail -n2 | head -n1);
    #rm installer_log_lf.txt
    echo $packages_line > ${INSTALLER_DIR}/packages_line.txt
    # One package per line
    sed 's/ /\n/g' < ${INSTALLER_DIR}/packages_line.txt > ${INSTALLER_DIR}/temp.txt
    rm ${INSTALLER_DIR}/packages_line.txt
    # Remove first line that is garbage like [12345] from qt installer
    pkgfile=${INSTALLER_DIR}/${INSTALLER_NAME}.available_packages.txt
    tail -n +2 "${INSTALLER_DIR}/temp.txt" > ${pkgfile}
    rm ${INSTALLER_DIR}/temp.txt
    # Sort alphabetically
    sort -o ${pkgfile} ${pkgfile}
    echo Packages:
    echo cat ${pkgfile}
fi

