# About this repository

This repository can solve two kind of problems. 

1. List available packages in the Qt offline installer
2. Install Qt without user interaction (CI setup)

Qt requires the user to be log in to their Qt account during installation. Hence you have to provide credentials. This is also required for listing the packages, because the packages are read when the component selection screen is shown, which comes after the login screen. There are three options to provide the credentials: 

1. Set the environment variables **QT_INSTALLER_LOGIN_MAIL** and **QT_INSTALLER_LOGIN_PW**
2. Pass the parameters *--username* and *--password* to the script. They take precedence over the environment variables.
3. On request, input the credentials during script execution. Used as a fallback mechanism if no credentials have been set.

The credentials only have to be provided once. Read more further down in the section `Credentials store`.

## 1 List packages

The available packages are written to a file called `${FILEDIR}/${FILENAME}.available_packages.txt`. 

If the installer file is placed at 
`/home/Qt-5.12.1.run` then the package file is placed at
`/home/Qt-5.12.1.run.available_packages.txt`.

If you specify a filename, you don't need to pass the version.

`bash qt-installer.sh --list-packages --filedir="C:/installers" --filename="qt-opensource-windows-x86-5.12.8.exe"`

Here, as a filename is provided, the version will be ignored:

`bash qt-installer.sh --list-packages --filedir="C:/installers" --filename="qt-opensource-windows-x86-5.12.8.exe" --version=5.12.0`

If you specify the version and don't provide a filename, the default installer filenames will be chosen.

`bash qt-installer.sh --list-packages --filedir="C:/installers" --version=5.12.8`

## 2 Install Qt

Install the specified packages. Download the installer if not found (checked at the location <filedir/filename>). Remove all directories and files except the directory <installdir/version> after installation. Read the credentials from ENV or user input.

`bash qt-installer.sh --filedir="/var/installers/" --filename="qt-opensource-linux-x64-5.12.8.run" --version=5.12.8 --packages="qt.qt5.5128.win64_msvc2017_64 qt.qt5.5128.qtwebengine qt.qt5.5128.qtnetworkauth" --installdir="/home/jenkins/Qt" --cleanup ` 



# Parameters

| parameter       | comment                                                      |
| --------------- | ------------------------------------------------------------ |
| --list-packages | List all the packages, do not install                        |
| --filedir       | The directory where the installer file is located            |
| --filename      | The name of the installer file, including file ending        |
| --version, -v   | The version to be installed in the format **x.yy.z**, like 5.12.8 |
| --packages      | Space separated string of packages as output by *--list-packages* |
| --installdir    | The installation directory                                   |
| --username, -u  | Alternative: ENV variable **QT_INSTALLER_LOGIN_MAIL**        |
| --password      | Alternative: ENV variable **QT_INSTALLER_LOGIN_PW**          |
| --cleanup       | Optional flag. Set to remove unnecessary files and directories after installation |
| --no-install    | Eventually downloads the file --filename to dir --filedir, nothing else. |
| --archive-url   | The URL to the download archive of Qt. <br />Defaults to https://download.qt.io/archive/qt/**<br />appended internally** with **/x.yy/x.yy.z/filename** |



# Default Values

Some variables have default values.

## installation directory

parameter: *--installdir*

| OS      | default value                  | example                 |
| ------- | ------------------------------ | ----------------------- |
| windows | C:/Qt${QT_VERSION}             | C:/Qt5.12.8             |
| linux   | /home/${USER}/Qt${QT_VERSION}  | /home/jenkins/Qt5.12.8  |
| osx     | /Users/${USER}/Qt${QT_VERSION} | /Users/jenkins/Qt5.12.8 |

## installer file name

parameter: *--filename*

| OS      | default value                            |
| ------- | ---------------------------------------- |
| windows | qt-opensource-windows-x86-**x.yy.z**.exe |
| linux   | qt-opensource-linux-x64-**x.yy.z**.run   |
| osx     | qt-opensource-mac-x64-**x.yy.z**.dmg     |

## download archive url

parameter: *--archive-url*

default value: https://download.qt.io/archive/qt/



# Credentials store

The Qt installer requires login credentials. Those are only required for the first time, because will get cached in a file from where they are read on consecutive installer runs. 
Example content:

`[QtAccount]`
`email=x@y.com`
`jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2YjVkYzI2MmQ4MjNmYTAwMDRmYWY2OGYiLCJlbWFpbCI6InhAeS5jb20iLCJzY29wZSI6InVzZXIiLCJldiI6dHJ1ZSwiaWF0IjoxNTg4ODU5MDEwLCJleHAiOjE2MDQ1ODM4MTAsImlzcyI6Imh0dHBzOi8vbG9naW4ucXQuaW8ifQ.OHVepZ8NlU485dhrwjD_iwLd2vZj79QYWsPBsxCJrwA`
`u=5c0bc262d823fa0004faf45e`

The password is hashed and stored in the java web token (jwt).
The token expires after approximately 6 months.

You can decode it on www.jwt.io:

HEADER:ALGORITHM & TOKEN TYPE

```
{
  "alg": "HS256",
  "typ": "JWT"
}
```

PAYLOAD:DATA

```
{
  "sub": "6b5dc262d823fa0004faf68f",
  "email": "x@y.com",
  "scope": "user",
  "ev": true,
  "iat": 1588859010,
  "exp": 1604583810,
  "iss": "https://login.qt.io"
}
```

VERIFY SIGNATURE

```
HMACSHA256(
  base64UrlEncode(header) + "." +
  base64UrlEncode(payload),
  
) secret base64 encoded
```

The location of this credentials cache file is written to the console during installation.

| OS      | location                           |
| ------- | ---------------------------------- |
| windows | ~/AppData/Roaming/Qt/qtaccount.ini |
| linux   |                                    |
| osx     |                                    |

