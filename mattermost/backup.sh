#!/bin/bash


service_name="mattermost"
manage_script="${PWD}/manage.sh"
service_root="${PWD}/${service_name}"
backup_dir="${PWD}/${service_name}/backups/backup_`date +"%Y-%m-%d_%H%M%S"`"


# Make sure this script is called from the repository root.
if [ ! -f  "${manage_script}" ]; then
    echo "Please call this script form the repository root."
    exit 1
fi


################################################################################
# PREPARATIONS                                                                 #
################################################################################

# Loading env variables
. ${service_root}/.env

# Creating required folders
mkdir -p ${backup_dir}/mattermost/


################################################################################
# FILES                                                                        #
################################################################################

# Copying files from inside the docker container
${manage_script} ${service_name} cp mattermost:/mattermost/config ${backup_dir}/mattermost/
${manage_script} ${service_name} cp mattermost:/mattermost/data   ${backup_dir}/mattermost/


################################################################################
# DATABASE                                                                     #
################################################################################

# Backing up the Database
${manage_script} ${service_name} exec --no-TTY database pg_dump \
  --role=${DATABASE_USER} \
	--username=${DATABASE_USER} \
	--dbname=${DATABASE_NAME} \
	--format=tar \
	--no-security-labels \
  --no-owner \
  --verbose \
	> ${backup_dir}/dump_${service_name}_`date +"%Y-%m-%d_%H%M%S"`.sql
