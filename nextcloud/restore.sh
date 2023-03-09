#!/bin/bash


################################################################################
# PREPARATIONS                                                                 #
################################################################################

# Loading env variables
. ./nextcloud/.env

# Stopping and removing everything that might still be running
./manage.sh nextcloud down -v

# Creating required folders
mkdir -p ${DATA_PATH}

################################################################################
# FILES                                                                        #
################################################################################

# Copy over all files from the backup
rsync -Aaxvh --delete ./nextcloud/backup/config ${DATA_PATH}
rsync -Aaxvh --delete ./nextcloud/backup/data   ${DATA_PATH}
rsync -Aaxvh --delete ./nextcloud/backup/themes ${DATA_PATH}

# Create a fresh mattermost container
./manage.sh nextcloud create nextcloud

# Set the correct permissions
./manage.sh nextcloud run --rm --user root nextcloud chown -R www-data:www-data /var/www/html


################################################################################
# DATABASE                                                                     #
################################################################################

# Start the database up again
./manage.sh nextcloud up -d database

# Restore the database
./manage.sh nextcloud exec --no-TTY database pg_restore \
  --role=${DATABASE_USER} \
  --username=${DATABASE_USER} \
  --dbname=${DATABASE_NAME} \
  --format=tar \
  --no-security-labels \
  --no-owner \
  --verbose \
  < ./nextcloud/backup/dump.sql


################################################################################
# Finalize                                                                     #
################################################################################

# Start everything up again
./manage.sh nextcloud up -d
