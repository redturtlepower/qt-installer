QT_MAJOR=$(cut -c-1 QT_VERSION.txt) # For Qt5.11.2 this yields 5 (QT_VERSION.txt contains version in format '5.11.2')
QT_MINOR=$(sed 's/\./\n/g' QT_VERSION.txt | awk 'NR==2')
QT_PATCH=$(sed 's/\./\n/g' QT_VERSION.txt | awk 'NR==3')
QT_VERSION_NO_DOTS=$(sed 's/\.//g' < QT_VERSION.txt) # yields: 5112
PREFIX="qt.qt"$QT_MAJOR.$QT_VERSION_NO_DOTS.
echo "QT_VERSION_NO_DOTS:"$QT_VERSION_NO_DOTS
echo "packages PREFIX:"$PREFIX
echo $PREFIX > generated/qtprefix.txt
echo $QT_MAJOR > generated/qt-version-major.txt
echo $QT_MINOR > generated/qt-version-minor.txt
echo $QT_PATCH > generated/qt-version-patch.txt