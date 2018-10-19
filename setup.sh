mkdir generated
mkdir installers
setup/generate-qt-prefix.sh
setup/generate-qtinstaller-script.sh
setup/generate-provision-script.sh
generated/provision.sh