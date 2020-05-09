cd ..
read -p 'Qt login username: ' LOGIN_USERNAME
read -sp 'Qt login password: ' LOGIN_PASSWORD
bash ./qt-installer.sh --filedir="C:/installers" --filename="qt-opensource-windows-x86-5.12.8.exe" --version="5.12.8" --username=$LOGIN_USERNAME --password=$LOGIN_PASSWORD --packages="qt.qt5.5128.win64_msvc2017_64 qt.qt5.5128.qtwebengine qt.qt5.5128.qtnetworkauth" --cleanup
