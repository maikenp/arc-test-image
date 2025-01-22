```
sudo docker build -t arc .
sudo docker run -it   -p 443 arc
```

Or for full control

```
sudo docker run -it  -v "/etc/grid-security:/etc/grid-security:rw"  -p 443  --entrypoint /bin/bash arc
<container-hash># . ./entrypoint_install_rhel.sh
<container-hash># . ./entrypoint_deploy.sh
```



