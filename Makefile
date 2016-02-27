USER = rednut
NAME = unifi-controller
REGISTRY = registry.rednut.net/
REPO = $(REGISTRY)$(USER)/$(NAME)
VERSION = $(shell cat VERSION)


LVOL = /docker/unifi/data
RVOL = /usr/lib/unifi/data



.PHONY: all build test tag_latest release ssh

all: version_bump build tag_latest push

push: push_latest
push_latest:
	docker push $(REPO):latest


build:
	docker build -t="$(REPO):$(VERSION)" --rm --no-cache .



version_bump:
	@VERSION inc

tag_latest:
	docker tag -f $(REPO):$(VERSION) $(REPO):latest

release: test tag_latest
	@if ! docker images $(REPO) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(REPO) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! head -n 1 Changelog.md | grep -q 'release date'; then echo 'Please note the release date in Changelog.md.' && false; fi
	docker push $(REPO)
	@echo "*** Don't forget to create a tag. git tag rel-$(VERSION) && git push origin rel-$(VERSION)"

rm:
	docker stop $(NAME) || echo "container not running yet" && docker rm $(NAME) || echo "no container count yet"

# 0.0.0:8080->8080/tcp, 0.0.0.0:8443->8443/tcp, 0.0.0.0:2222->22/tcp, 0.0.0.0:37117->27117/tcp
run: rm 
	docker run -d \
                        -p 8443:8443 \
			-p 37117:27117 \
			-p 8081:8080 \
                        -v /docker/unifi/data:/usr/lib/unifi/data \
                        --name=$(NAME) \
			$(REPO):latest


ip:
	@ID=$$(docker ps | grep -F "$(REPO):$(VERSION)" | awk '{ print $$1 }') && \
                if test "$$ID" = ""; then echo "Container is not running."; exit 1; fi && \
                IP=$$(docker inspect $$ID | grep IPAddr | sed 's/.*: "//; s/".*//') && \
                echo "$$IP\tsabnzbd"

ssh:
	chmod 600 image/insecure_key
	@ID=$$(docker ps | grep -F "$(REPO):$(VERSION)" | awk '{ print $$1 }') && \
		if test "$$ID" = ""; then echo "Container is not running."; exit 1; fi && \
		IP=$$(docker inspect $$ID | grep IPAddr | sed 's/.*: "//; s/".*//') && \
		echo "SSHing into $$IP" && \
		ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i image/insecure_key root@$$IP
