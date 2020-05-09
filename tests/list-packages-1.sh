cd ..
read -p 'Qt login username: ' LOGIN_USERNAME
read -sp 'Qt login password: ' LOGIN_PASSWORD
bash ./qt-installer.sh  --list-packages --filedir="C:/installers" --filename="qt-opensource-windows-x86-5.12.8.exe" --username=$LOGIN_USERNAME --password=$LOGIN_PASSWORD