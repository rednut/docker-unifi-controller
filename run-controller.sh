#!/usr/bin/env bash
set +e 
set +x


CONTAINER_NAME="unifi"



docker stop $CONTAINER_NAME || echo "cannot stop a non running $CONTAINER_NAME"
docker rm -f $CONTAINER_NAME || echo "not a container yet: '$CONTAINER_NAME'"


docker run -d \
	-p 2222:22 \
	-p 8081:8080 \
	-p 8443:8443 \
	-p 37117:27117 \
                        -v /docker/unifi/data:/usr/lib/unifi/data \
                        --name unifi rednut/unifi-controller
