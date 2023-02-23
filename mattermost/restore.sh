#!/bin/bash


################################################################################
# PREPARATIONS                                                                 #
################################################################################

# Loading env variables
. ./mattermost/.env

# Stopping and removing everything that might still be running
./manage.sh mattermost down -v


################################################################################
# FILES                                                                        #
################################################################################

# Create a fresh mattermost container
./manage.sh mattermost create mattermost

# Copying files into the mattermost container
./manage.sh mattermost cp ./backup/config/config.json mattermost:/mattermost/config/config.json
./manage.sh mattermost cp ./backup/data mattermost:/mattermost

# Set the correct permissions
./manage.sh mattermost run --rm --user root mattermost chown -R mattermost:mattermost /mattermost/


################################################################################
# DATABASE                                                                     #
################################################################################

# Start the database up again
./manage.sh mattermost up -d database

# Restore the database
./manage.sh mattermost exec --no-TTY database pg_restore \
  --role=${DATABASE_USER} \
  --username=${DATABASE_USER} \
  --dbname=${DATABASE_NAME} \
  --format=tar \
  --no-security-labels \
  --no-owner \
  --verbose \
  < ./mattermost/backup/dump.sql


################################################################################
# Finalize                                                                     #
################################################################################

# Start everything up again
./manage.sh mattermost up -d
