##Docker file for runner that deploys ARC from rpms on rockylinux 9

FROM rockylinux:9

RUN dnf install -y \
wget \
epel-release \
unzip \
emacs \
net-tools \
python3-jwcrypto



RUN dnf install -y 'dnf-command(config-manager)'
RUN dnf config-manager --set-enabled crb

EXPOSE 443

COPY ./arc-testfiles /arc-testfiles/
COPY ./entrypoint.sh /
COPY ./entrypoint_install_rhel.sh /
COPY ./entrypoint_deploy.sh /

ENTRYPOINT ["/entrypoint.sh"]


