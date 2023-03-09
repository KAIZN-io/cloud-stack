#!/bin/bash


################################################################################
# PREPARATIONS                                                                 #
################################################################################

# Loading env variables
. ./nextcloud/.env

# Delete the old backup to not mix any data
rm -rf ./backup

# Creating required folders
mkdir -p ./backup


################################################################################
# FILES                                                                        #
################################################################################

# Copying files from inside the docker container
./manage.sh nextcloud cp nextcloud:/var/www/html/config ./backup
./manage.sh nextcloud cp nextcloud:/var/www/html/data   ./backup
./manage.sh nextcloud cp nextcloud:/var/www/html/themes ./backup


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
