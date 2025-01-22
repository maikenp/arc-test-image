#!/bin/sh

set +e

export today=$(date -I)
cat << EOF > /etc/yum.repos.d/nordugrid-nightly.repo
[nordugrid-nightly]
name=Nordugrid ARC Next Nightly Builds - \$basearch
baseurl=http://builds.nordugrid.org/nightlies/nordugrid-arc/next/${today}/rocky/9/\$basearch
enabled=1
gpgcheck=0
EOF


mkdir -p /var/spool/arc/jobstatus/{accepting,finished,processing,restarting}
mkdir -p /var/spool/arc/sessiondir
mkdir -p /var/log/arc

dnf install -y nordugrid-arc-arex nordugrid-arc-client

cd /

