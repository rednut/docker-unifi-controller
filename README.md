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


The Makefile will provision the docker container image from the Dockerfile which will provision the image with upstream ubuntu:latest and include all the required dependencies to 
run the the unifi controller.

The unifi controller repo will provide the .debs. The package requires mongodb, so if we dont
include 10gen's official repo it will use stock debian mongo instead (current state)

The supervisor.conf is provided to configure supervisord which is used to launch the unifi contoller daemon.

## run the container: launching the unifi controller daemon

- to launch a container using the image created earlier:

``` 
	docker run -d \
			-p 2222:22 -p 8080:8080 -p 8443:8443 -p 37117:27117 \
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

- 20151026 fixup to use upstream ubuntu latest repo, make work with ubnt upstream changes: https://community.ubnt.com/t5/UniFi-Updates-Blog/UniFi-4-6-6-is-released/ba-p/1288816



