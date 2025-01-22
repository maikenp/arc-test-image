#!/bin/sh
printf "\n================== START PREPARATIONS ================================================================\n"

echo "set +e"
set +e

os_v="el9"
mkdir -p /rpmbuild

#############################################################################
## Routine for downloading artifacts typically when running interactive test 
#############################################################################

wget https://source.coderefinery.org/nordugrid/arc/-/jobs/artifacts/next/download?job=build_${os_v} -O artifacts.zip; 
unzip artifacts.zip; 
packages=$(ls /rpmbuild/RPMS/x86_64)


########################################################################
## Set up repo
#######################################################################
printf "\n\n\nPreparing local repo for installation\n"
printf "dnf list installed | grep createrepo\n"
dnf list installed | grep createrepo
if [ "$?" -eq 1 ]; then yum install -y createrepo; fi;

printf "cd /rpmbuild/RPMS/noarch\n"
cd /rpmbuild/RPMS/noarch
printf "createrepo .\n"
createrepo .
printf "cd ../x86_64\n"
cd ../x86_64
printf "createrepo .\n"
createrepo .

printf "ls -lhrt /rpmbuild/RPMS/\n"
ls -lhrt /rpmbuild/RPMS/


printf "ls -lhrt /rpmbuild/RPMS/x86_64/repodata\n"
ls -lhrt /rpmbuild/RPMS/x86_64/repodata

cat > /etc/yum.repos.d/nordugrid-ci.repo <<EOF
[nordugrid-ci]
name=NorduGrid - $basearch - CI
baseurl=file:///rpmbuild/RPMS/x86_64
enabled=1
gpgcheck=0

[nordugrid-ci-noarch]
name=NorduGrid - noarch - CI
baseurl=file:///rpmbuild/RPMS/noarch
enabled=1
gpgcheck=0
EOF

printf "pwd\n"
pwd
printf "ls -lhrt\n"
ls -lhrt 
printf "ls -lhrt /etc/yum.repos.d\n"
ls -lhrt /etc/yum.repos.d

printf "cat /etc/yum.repos.d/nordugrid-ci.repo\n"
cat /etc/yum.repos.d/nordugrid-ci.repo



########################################################################
## Install ARC
#######################################################################
printf '\n\n======== START Install ARC  ==========\n'


printf "dnf install -y nordugrid-arc-arex\n"
dnf install -y nordugrid-arc-arex 

printf "dnf install -y nordugrid-arc-client\n"
dnf install -y nordugrid-arc-client

printf "\n\n======== END Install ARC  ==========\n\n"


printf "mkdir -p /var/spool/arc/jobstatus/{accepting,finished,processing,restarting}\n"
mkdir -p /var/spool/arc/jobstatus/{accepting,finished,processing,restarting}

printf "mkdir -p /var/spool/arc/sessiondir\n"
mkdir -p /var/spool/arc/sessiondir

printf "mkdir -p /var/log/arc\n"
mkdir -p /var/log/arc


cd /
printf "\n================== END PREPARATIONS =====================\n"
