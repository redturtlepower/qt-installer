mkdir generated
mkdir installers
bash setup/generate-qt-prefix.sh
bash setup/generate-qtinstaller-script.sh
bash setup/generate-provision-script.sh
bash generated/provision.sh