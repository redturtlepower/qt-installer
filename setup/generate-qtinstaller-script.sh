echo "Qt version to install: Qt"`cat QT_VERSION.txt`

# Ignores packages starting with #
# https://stackoverflow.com/questions/8206280/delete-all-lines-beginning-with-a-from-a-file
sed '/^#/ d' < QT_PACKAGES.txt > generated/QT_PACKAGES.txt.tmp

# Prefix each line with 'qt.qt5.5112.' (used Qt5.11.2. as example):
PREFIX=$(cat generated/qtprefix.txt)
sed -e 's/^/'"$PREFIX"'/' generated/QT_PACKAGES.txt.tmp > generated/QT_PACKAGES.txt

# Make a one-liner from multiple lines:
# https://stackoverflow.com/questions/15580144/how-to-concatenate-multiple-lines-of-output-to-one-line
echo $(cat generated/QT_PACKAGES.txt)

# Replace the placeholder in the template file with the generated package list:
# The packages are still missing the base packages which are different depending on the OS!
# This line replaces __PACKAGES_LIST__ with (example, incl. quotes) "qt.qt5.5112.win32_msvc2015 qt.qt5.5112.qtnetworkauth qt.qt5.5112.qtcharts"
sed "s/__PACKAGES_LIST__/\"`echo $(cat generated/QT_PACKAGES.txt)`\"/g" \
generated/qt-installer-noninteractive.qs.template > generated/qt-installer-noninteractive.qs
