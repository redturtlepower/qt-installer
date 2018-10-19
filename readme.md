There are 2 bash scripts:
- Setup_buildenv.sh which installs only the required packages for building
- Setup_devenv.sh which additionally installs tools like QtCreator

Those scripts automatically determine the host OS they are run on to identify the correct installers.
The Qt-installers are expected to be present in the directory "installers".
If they are not found, they will be downloaded with curl. Make sure curl is installed.

This script can be run on Windows, Linux and Mac. On Windows Git is required to execute bash.

Define the version of Qt by editing "QT_VERSION.txt". 
This file shall only contain the string version (good example: '5.11.2' => remove quotation marks, but keep dots)
The string shall not contain any other chars (bad example: 'Qt5.11.2')

Currently, the scripts installs the following packages:
- Qt base
- NetworkAuth

Depending on the host OS:
- Mac (MacOS and iOS - Clang)
- Linux (Desktop and Android - GCC)
- Windows (Desktop - MSVC2015)

On Windows you will also need to install the MSVC build tools separately.
