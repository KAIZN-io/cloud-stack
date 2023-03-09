#!/bin/bash


service_name="nextcloud"
manage_script="${PWD}/manage.sh"
service_root="${PWD}/${service_name}"
backups_dir="${PWD}/${service_name}/backups"


# Make sure this script is called from the repository root.
if [ ! -f  "${manage_script}" ]; then
    echo "Please call this script form the repository root."
    exit 1
fi


# Make sure there are acutally some backups to choose from.
if [ ! -d  "${backups_dir}" ]; then
    echo "No backups found."
    exit 0
fi

if [ -z "$(ls -A ${backups_dir})" ]; then
    echo "No backups found."
    exit 0
fi

printf "Please select backup:\n"
select selected_backup_dir in ${backups_dir}/*; do test -n "${selected_backup_dir}" && break; echo ">>> Invalid Selection"; done

selected_database_dump=`find ${selected_backup_dir} -name "*.sql"`


################################################################################
# PREPARATIONS                                                                 #
################################################################################

# Loading env variables
. ${service_root}/.env

# Stopping and removing everything that might still be running
${manage_script} ${service_name} down -v

# Creating required folders
mkdir -p ${DATA_PATH}

################################################################################
# FILES                                                                        #
################################################################################

# Copy over all files from the backup
rsync -Aaxvh --delete ${selected_backup_dir}/config ${DATA_PATH}
rsync -Aaxvh --delete ${selected_backup_dir}/data   ${DATA_PATH}
rsync -Aaxvh --delete ${selected_backup_dir}/themes ${DATA_PATH}

# Create a fresh mattermost container
${manage_script} ${service_name} create nextcloud

# Set the correct permissions
${manage_script} ${service_name} run --rm --user root nextcloud chown -R www-data:www-data /var/www/html


################################################################################
# DATABASE                                                                     #
################################################################################

# Start the database up again
${manage_script} ${service_name} up -d database

# Restore the database
${manage_script} ${service_name} exec --no-TTY database pg_restore \
  --role=${DATABASE_USER} \
  --username=${DATABASE_USER} \
  --dbname=${DATABASE_NAME} \
  --format=tar \
  --no-security-labels \
  --no-owner \
  --verbose \
  < ${selected_database_dump}


################################################################################
# Finalize                                                                     #
################################################################################

# Start everything up again
${manage_script} ${service_name} up -d
