#!/bin/bash -e
set -e

source /opt/rh/php55/enable

# Create required directories just in case.
mkdir -p /var/www/logs/php-fpm /var/www/files-private /var/www/docroot
echo "*" > /var/www/logs/.gitignore

# Set the apache user and group to match the host user.
# Optionally use the HOST_USER env var if provided.
if [ "$HOST_USER" ]; then
  OWNER=$(echo $HOST_USER | cut -d: -f1)
  GROUP=$(echo $HOST_USER | cut -d: -f2)
else
  OWNER=$(stat -c '%u' /var/www)
  GROUP=$(stat -c '%g' /var/www)
fi
if [ "$OWNER" != "0" ]; then
  usermod -o -u $OWNER apache
  groupmod -o -g $GROUP apache
fi
usermod -s /bin/bash apache
usermod -d /var/www apache

# Add www-data user as same as apache user
if [ ! $(id -u www-data &>/dev/null) ]; then
  OWNER=$(id -u apache)
  GROUP=$(id -g apache)
  useradd -o -u $OWNER -g $GROUP -M -d /var/www www-data
  grep -c www-data /etc/group || groupadd -o -g $GROUP www-data
fi

echo The apache user and group has been set to the following:
id apache

# Setup XDebug to use special remote_host since docker0 bridge doesn't exist
if [ "${HOST_OS}" = "Darwin" ]; then
  echo xdebug.remote_host=docker.for.mac.localhost >> /opt/rh/php55/root/etc/php.d/xdebug.ini
  echo xdebug.remote_connect_back=0 >> /opt/rh/php55/root/etc/php.d/xdebug.ini;
else
  echo xdebug.remote_connect_back=1 >> /opt/rh/php55/root/etc/php.d/xdebug.ini;
fi

exec "$@"
