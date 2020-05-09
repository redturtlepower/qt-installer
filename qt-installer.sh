# Try to read the login credentials from the system environment variables
LOGIN_USERNAME=${QT_INSTALLER_LOGIN_MAIL}
LOGIN_PASSWORD=${QT_INSTALLER_LOGIN_PW}

# -z checks for emptyness of variable
if [ -z "${LOGIN_USERNAME}" ]; then
    :
else
    echo "Found qt login email in system environment"
fi
if [ -z "${LOGIN_USERNAME}" ]; then
    :
else
    echo "Found qt login password in system environment"
fi

for i in "$@"
do
echo "Parsing option" $i
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
    -u=*|--username=*)
    if [ -z "${LOGIN_USERNAME}" ]; then
        :
    else
        echo "Warning: Overwriting qt login email from system environment"
    fi
    LOGIN_USERNAME="${i#*=}"
    shift # past argument=value
    ;;
    --password=*)
    if [ -z "${LOGIN_PASSWORD}" ]; then
        :
    else
        echo "Warning: Overwriting qt login password from system environment"
    fi
    LOGIN_PASSWORD="${i#*=}"
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

if [ -z "$INSTALLDIR" ];then  
    # No installation directory specified. Select default directory
    case "$OSTYPE" in
      darwin*) 
        INSTALLDIR=/Users/${USER}/Qt${INSTALL_VERSION}
        ;; 
      linux*)   
        INSTALLDIR=/home/${USER}/Qt${INSTALL_VERSION}
        ;;
      msys*)    
        INSTALLDIR=C:/Qt${INSTALL_VERSION}
        ;;
      solaris*) echo "SOLARIS" ;;
      bsd*)     echo "BSD" ;;
      *)        echo "unknown: $OSTYPE" ;;
    esac
    echo "Installing into default directory" $INSTALLDIR
fi

# Maybe select a default installer name
if [ -z "$INSTALL_VERSION" ] # If 
then 
    # No version specified
    : #no-op
else
    # The version is specified
    if [ -z "$INSTALLER_NAME" ] # if the installation file is not specified
    then # Choose default installer names. The version string must be provided.
        case "$OSTYPE" in
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
          *) echo "unknown: $OSTYPE" ;;
        esac
    else
        :
    fi
fi

# If no credentials provided, ask the user for input.
if [ -z "$LOGIN_USERNAME" ] || [ -z "$LOGIN_PASSWORD" ]; then
    echo The installer requires to log in to Qt. Internet connection required! Please provide your login details.
    read -p 'Qt login username: ' LOGIN_USERNAME
    read -sp 'Qt login password: ' LOGIN_PASSWORD
    echo
    echo Thankyou $uservar we now have your login details
fi

# Make variables available to the controller script 'control-script.qs'
export QT_LIST_PACKAGES=$LIST_PACKAGES
export QT_INSTALL_PACKAGES=$INSTALL_PACKAGES
export QT_INSTALL_DIR=$INSTALLDIR
export QT_LOGIN=$LOGIN_USERNAME
export QT_PASSWORD=$LOGIN_PASSWORD

echo "LIST_PACKAGES" $LIST_PACKAGES
if [ -z "$LIST_PACKAGES" ] #If LIST_PACKAGES is empty
then
    if [ "$(ls -a $INSTALLDIR)" ]; then
        echo "Qt is already installed! Aborting."
    else
        # Install Qt
        if [ -z "$ARCHIVE_URL" ]; then
            # If no download archive url has been specified, choose a default one:
            ARCHIVE_URL=https://download.qt.io/archive/qt/
        fi
        bash maybe-download-installer.sh $INSTALLER_DIR $INSTALLER_NAME $INSTALL_VERSION $ARCHIVE_URL

        if [ -f $INSTALLER_DIR/$INSTALLER_NAME ]; then
            echo "Installer found in directory" $INSTALLER_DIR "!"
            # Make the installer executable (only needed on linux)
            case "$OSTYPE" in
                linux*) 
                    chmod +x $INSTALLER_DIR/$INSTALLER_NAME 
                    ls -la $INSTALLER_DIR
                    ;;
            esac 
            # Start the installer in headless mode

            installer_log=$($INSTALLER_DIR/$INSTALLER_NAME --script control-script.qs --verbose);
            echo $installer_log
            echo $installer_log > installer_log.txt
            
            #echo $INSTALL_VERSION > QT_INSTALLED_VERSION.txt
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
            echo "Did not find the qt installer in the directory" $INSTALLER_DIR
        fi
    fi

else
    # List packages
    if [ -f $INSTALLER_DIR/$INSTALLER_NAME ]; then
        echo "Listing packages of " $INSTALLER_DIR/$INSTALLER_NAME;
        installer_log=$($INSTALLER_DIR/$INSTALLER_NAME --script control-script.qs --verbose);
        echo $installer_log > installer_log.txt
        # Replace \r with \n
        tr '\r' '\n' < installer_log.txt > installer_log_lf.txt
        # Extract the 2nd last line that contains a list of all packages: extract last 2 lines, keep only 1st of those 2
        packages_line=$(cat installer_log_lf.txt | tail -n2 | head -n1);
        rm installer_log_lf.txt
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
    else
        echo "Listing packages failed."
        echo "Please provide the installer-dir and the installer-name, or the installer-dir and the version (default installer names will be used)"
    fi
fi

