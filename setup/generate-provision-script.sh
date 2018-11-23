sed "s/__QT_VERSION__/`cat QT_VERSION.txt`/" setup/provision.sh.template > generated/provision.sh

# Use fixed user name 'jenkins':
sed -i "s/__USER_NAME__/`echo jenkins`/g" generated/provision.sh