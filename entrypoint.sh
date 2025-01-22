#!/bin/bash

printf "Importing entrypoint_install_rhel.sh"
. ./entrypoint_install_rhel.sh

cd ./

printf "Importing entrypoint_deploy.sh"
. ./entrypoint_deploy.sh
