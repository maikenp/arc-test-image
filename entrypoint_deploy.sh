#!/bin/sh
printf "\n ==== Starting entrypoint_deploy.sh ====\n"
echo "set +e"
set +e

printf "useradd grid\n"
useradd grid

printf '\n\n========== Start fix arc.conf ======================\n'

printf '\n map to grid user instead of nobody user\n'
sed -i 's/nobody/grid/g' /etc/arc.conf

printf '\n\n========== End fix arc.conf ======================\n'




printf '\n\n======== START creating grid-user cert =========='
printf "arcctl test-ca usercert -i root --validity 1\n"
arcctl test-ca init --force
arcctl test-ca hostcert --force
arcctl test-ca usercert -i root

printf "\nls -lh /etc/grid-security\n"
ls -lh /etc/grid-security
printf "\nls -lh  /etc/grid-security/certificates\n"
ls -lh  /etc/grid-security/certificates
printf '\n\n========  END creating testuser cert  ==========\n'


printf "\n================= START ARCCTL TEST JWT =====================\n\n"
jwt_deploy_out=$(arcctl test-jwt init --force)
jwt_deploy_command=$(echo "$jwt_deploy_out" | grep -o 'arcctl.*')
echo "Running: ${jwt_deploy_command}\n"
$jwt_deploy_command
printf "\n================= END ARCCTL TEST JWT =====================\n\n"


#set up user authentication
arcproxy
export BEARER_TOKEN=$(arcctl test-jwt token)
#end setup user authentication

printf "\n########################################################################\n"
printf "## Start ARC\n"
printf "\n#######################################################################\n"

printf "\n/usr/share/arc/arc-arex-start\n"
/usr/share/arc/arc-arex-start

printf "\n/usr/share/arc/arc-arex-ws-start\n"
/usr/share/arc/arc-arex-ws-start

