#!/bin/bash


################################################################################
# PREPARATIONS                                                                 #
################################################################################

# Loading env variables
. ./mattermost/.env

# Delete the old backup to not mix any data
rm -rf ./backup

# Creating required folders
mkdir -p ./backup


################################################################################
# FILES                                                                        #
################################################################################

# Copying files from inside the docker container
./manage.sh mattermost cp mattermost:/mattermost/config/config.json ./backup/config/config.json
./manage.sh mattermost cp mattermost:/mattermost/data ./backup


################################################################################
# DATABASE                                                                     #
################################################################################

# Backing up the Database
./manage.sh exec --no-TTY database pg_dump \
  --role=${DATABASE_USER} \
	--username=${DATABASE_USER} \
	--dbname=${DATABASE_NAME} \
	--format=tar \
	--no-security-labels \
  --no-owner \
  --verbose \
	> ./backup/dump.sql
