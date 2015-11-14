# dockerisation of unifi controller

Warning, this may eat your data, nibble your wifi or cause the silver foil lining your hat to combust in a shower of sparks like metal in a microwave.



## acquisition of container image

For a quick start use the docker hub method, for access to the source, built it yourself.



### pull from docker hub


```	
	docker pull rednut/unifi-controller
```

(see instructions below for running it)




### building docker image

```
git clone https://github.com/rednut/docker-unifi-controller.git 
cd docker-unifi-controller
make
```


## run the container: launching the unifi controller daemon

- to launch a container using the image created earlier:

```
    docker run -d \
            -p 8080:8080 -p 8443:8443 -p 8880:8880 -p 37117:27117 \
            -v /srv/data/apps/docker/unifi/data:/usr/lib/unifi/data \
            --name unifi rednut/unifi-controller
```


### notes on the make / build of the container

The Makefile will provision the docker container image from the Dockerfile which will provision the image with upstream ubuntu:latest and include all the required dependencies to 
run the the unifi controller.

The unifi controller repo will provide the .debs. The package requires mongodb, so if we dont
include 10gen's official repo it will use stock debian mongo instead (current state)

The supervisor.conf (example below) is provided to configure supervisord which is then used to launch the unifi contoller daemon:


```
[supervisord]
nodaemon=true

[program:unify]
command=nice ionice -c2 /usr/lib/jvm/java-6-openjdk-amd64/jre/bin/java -Xmx256M -jar /usr/lib/unifi/lib/ace.jar start
pidfile=/var/run/unifi/unifi.pid
stdout_logfile=/var/log/supervisor/%(program_name)s.log
stderr_logfile=/var/log/supervisor/%(program_name)s.log
#autorestart=true

```


## run the container: launching the unifi controller daemon

### volumes for persistent data

You can mount a local volume path into the container at `/usr/lib/unifi/data` by supplying to docker the `-v` argument like `-v <local_path>:<container_path>` or `-v /srv/data/apps/docker/unifi/data:/usr/lib/unifi/data`

### ports

To connunicate with the unifi controller you mapo various ports, eg:

- 8080: non tls web ui
- 8443: tls web ui
- 8880: guest login ui
- 27117: mongo 

### command to run the unifi controller daemon

To launch a container using the image created earlier:

``` 
	docker run -d \
			-p 8080:8080 -p 8443:8443 -p 8880:8880 -p 37117:27117 \
			-v /srv/data/apps/docker/unifi/data:/usr/lib/unifi/data \
			--name unifi rednut/unifi-controller
```


## management of container 

see Makefile...

- check the container is runing:
	`docker ps`

- check logs from container:
	`docker logs unifi`

- show process:
	`docker top unifi`

- kill the container ie stop process and stop container:
	`docker kill unifi`

- remove named conatiner (so you can re-run it):
	`docker rm unifi`

so its usually better, after running the container to just stop/start it instead:

- pause / unpause aka suspend running cotainer:

	`docker pause/unpause unifi`



	`docker restart unifi`


	`docker stop/start unifi`

	`docker kill unifi`

# Changelog

- 20151113 merge pr to all guest portal ports
- 20151026 fixup to use upstream ubuntu latest repo, make work with ubnt upstream changes: https://community.ubnt.com/t5/UniFi-Updates-Blog/UniFi-4-6-6-is-released/ba-p/1288816



