#!/bin/bash

# Making sure we are having our variables from .env
. .env
. ../.env

chown -R 2000:2000 ${DATA_PATH}
