#!/usr/bin/env bash
set +e 
set +x


CONTAINER_NAME="unifi-controller"



docker stop $CONTAINER_NAME || echo "cannot stop a non running $CONTAINER_NAME"
docker rm -f $CONTAINER_NAME || echo "not a container yet: '$CONTAINER_NAME'"

# 8880 8080 8443 37117 

docker run -d \
	-p 8081:8080 \
        -p 8880:8880 \
	-p 8443:8443 \
	-p 37117:27117 \
        -v /docker/unifi/data:/usr/lib/unifi/data \
        --name \
          ${CONTAINER_NAME} rednut/unifi-controller
