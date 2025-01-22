## Prepare

Create an ```/etc/arc.conf``` in your docker host server - replace the hostname with your fqdn 

```
[common]
hostname=galaxy-arc-test-fresh.itf.uiocloud.no

[authgroup: iam]
authtokens = * https://wlcg.cloud.cnaf.infn.it/ * * *
authtokens = * https://aai.egi.eu/oidc/ * * *
authtokens = * https://aai.egi.eu/auth/realms/egi * * *

[mapping]
map_to_user = iam nobody:nobody

[lrms]
lrms = fork

[arex]
loglevel = DEBUG 

[arex/data-staging]
logfile=/var/log/arc/datastaging.log

[arex/ws]
[arex/ws/jobs]

[infosys]
[infosys/glue2]


[infosys/cluster]

[queue:fork]

```


You need the following docker daemon.json config - change data-root to suit your system. 

```
[rocky@galaxy-arc-test-fresh arc_container]$ cat /etc/docker/daemon.json 
{
    "data-root": "/docker-data",
    "storage-driver": "overlay2",
    "default-ulimits": {
    "nofile": {
      "Hard": 64000,
      "Name": "nofile",
      "Soft": 64000
    }
  }
}
```


To be able to submit a job from the host server using the test-CA created by ARC in the container, you need to bind-mount the /etc/grid-security folder which will be created by ARC. So create this folder on the host server:

```
sudo mkdir /etc/grid-security
```


### Build and run
```
sudo docker build -t arc .
sudo docker run -d  -p 443:443 -v "/etc/arc.conf:/etc/arc.conf:rw" -v "/etc/grid-security:/etc/grid-security:rw" arc
```

Or for full control run the entrypoint files manually in the container: 

```
sudo docker run -it -p 443:443 -v "/etc/arc.conf:/etc/arc.conf:rw" -v "/etc/grid-security:/etc/grid-security:rw"  --entrypoint /bin/bash arc
<container-hash># . ./entrypoint_install_rhel.sh
<container-hash># . ./entrypoint_deploy.sh
```



## Problems  (solved)
These problems were solved once I added the above daemon.json config

However, the container is not working as it should. The problems are

1. infoprovider takes ages to get started (symptom no /var/log/arc/infoprovider.log nor /var/spool/arc/jobstatus/info.xml file)
2. Not sure if this is the actual reason for the problems, but there are 3 instead of 1 process starting when running ```/usr/share/arc/arc-arex``` (and as expected 1 process for ```/usr/share/arc/arc-arex-ws```)
3. 
```
[root@06e20320cbff /]# ps aux | grep -v grep | grep arched
root         319  0.0  0.2 256832 19004 ?        Ssl  18:34   0:00 /usr/sbin/arched -c /tmp/arex.xml.otEzl5
root         467  0.0  0.2 119140 16816 ?        Ssl  18:34   0:00 /usr/sbin/arched -c /tmp/arex.xml.vnOH6G
root         508 58.1  0.2 256832 19004 ?        R    18:43   2:44 /usr/sbin/arched -c /tmp/arex.xml.otEzl5
root         509 51.1  0.2 256832 19004 ?        R    18:43   2:02 /usr/sbin/arched -c /tmp/arex.xml.otEzl5
```

4. Once infoprovider finally has run - arcinfo or arcsub stops after "Loaded /usr/lib64/arc/libmcctls.so":

```
[root@06e20320cbff /]# arcinfo -d DEBUG -C $(hostname)
VERBOSE: Running command: arcinfo -d DEBUG -C 06e20320cbff
DEBUG: Loading configuration (/etc/arc/client.conf)
INFO: Configuration (/etc/arc/client.conf) loaded
DEBUG: Loading configuration (/root/.arc/client.conf)
INFO: Configuration (/root/.arc/client.conf) loaded
INFO: Using proxy file: /tmp/x509up_u0
INFO: Using certificate file: /root/.globus/usercert.pem
INFO: Using key file: /root/.globus/userkey.pem
INFO: Using CA certificate directory: /etc/grid-security/certificates
DEBUG: Module Manager Init
DEBUG: Module Manager Init
DEBUG: Loaded /usr/lib64/arc/libaccARCHERY.so
DEBUG: Loaded HED:ServiceEndpointRetrieverPlugin ARCHERY
DEBUG: Module Manager Init
DEBUG: Module Manager Init
DEBUG: Loaded /usr/lib64/arc/libaccARCREST.so
DEBUG: Loaded HED:TargetInformationRetrieverPlugin REST
DEBUG: Adding endpoint (06e20320cbff) to TargetInformationRetriever
DEBUG: Setting status (STARTED) for endpoint: 06e20320cbff (<empty InterfaceName>, capabilities: information.discovery.resource)
DEBUG: Starting thread to query the endpoint on 06e20320cbff (<empty InterfaceName>, capabilities: information.discovery.resource)
DEBUG: The interface of this endpoint (06e20320cbff (<empty InterfaceName>, capabilities: information.discovery.resource)) is unspecified, will try all possible plugins
DEBUG: Found HED:TargetInformationRetrieverPlugin REST (it was loaded already)
DEBUG: Setting status (STARTED) for endpoint: 06e20320cbff (org.nordugrid.arcrest, capabilities: information.discovery.resource)
DEBUG: Starting sub-thread to query the endpoint on 06e20320cbff (org.nordugrid.arcrest, capabilities: information.discovery.resource)
DEBUG: Found HED:TargetInformationRetrieverPlugin REST (it was loaded already)
DEBUG: Calling plugin REST to query endpoint on 06e20320cbff (org.nordugrid.arcrest, capabilities: information.discovery.resource)
DEBUG: Querying WSRF GLUE2 computing REST endpoint.
DEBUG: Module Manager Init
DEBUG: Loaded /usr/lib64/arc/libmcchttp.so
DEBUG: Loaded /usr/lib64/arc/libmccmsgvalidator.so
DEBUG: Loaded /usr/lib64/arc/libmccsoap.so
DEBUG: Loaded /usr/lib64/arc/libmcctcp.so
DEBUG: Loaded /usr/lib64/arc/libmcctls.so
```

Likewise for arcusb, thus submitting jobs does not work. 


