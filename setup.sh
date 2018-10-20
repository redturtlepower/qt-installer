mkdir generated
mkdir installers
sh setup/generate-qt-prefix.sh
sh setup/generate-qtinstaller-script.sh
sh setup/generate-provision-script.sh
sh generated/provision.sh