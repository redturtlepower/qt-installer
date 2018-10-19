The purpose of this repo is to have a consistent build environment setup that can be installed silently without user interaction.
Only takes care of installing Qt.

Further steps not in the scope of this repo:
- on Windows you will also need to install the MSVC build tools
- on Mac you will also need to install XCode
- for Android development you will need the Android SDK + NDK and also Java JDK.

Define the version of Qt by editing `QT_VERSION.txt`. 
This file shall only contain the requested version in the format [5.11.2] without the brackets. Nothing else.

You may also adapt the packages to be installed by (out-)commenting the lines in `QT_PACKAGES.txt`.
You can select multiple compilers, if they are not found in the downloaded package, they are ignored (say ios on Windows).

Start the installation by executing `setup.sh`.

The procedure automatically determines the host OS to identify the correct installers.
The respective Qt-installers are expected in the directory `installers`.
If they are not found, they will be downloaded with curl. Make sure curl is installed.

This script can be run on Windows, Linux and Mac. On Windows Git is required to execute bash.
