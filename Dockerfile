##Docker file for runner that deploys ARC from rpms on rockylinux 9

FROM almalinux:9

ENV OS_V=9
ENV OS=almalinux

RUN dnf install -y \
wget \
epel-release \
unzip \
emacs \
net-tools \
createrepo \
python3-jwcrypto


RUN dnf install -y 'dnf-command(config-manager)'
RUN dnf config-manager --set-enabled crb
RUN dnf install -y \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-$OS_V.noarch.rpm \
    https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-$OS_V.noarch.rpm



EXPOSE 443

COPY ./arc-testfiles /arc-testfiles/
COPY ./entrypoint.sh /
COPY ./entrypoint_install_rhel.sh /
COPY ./entrypoint_deploy.sh /

ENTRYPOINT ["/entrypoint.sh"]


