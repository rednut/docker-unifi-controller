USER = rednut
NAME = unifi-controller
REPO = $(USER)/$(NAME)

LVOL = /srv/data/apps/docker/unifi/data
RVOL = /usr/lib/unifi/data



.PHONY: all build test tag_latest release ssh

all: build tag_latest 


build:
	docker build -t="$(REPO):$(VERSION)" --rm --no-cache .




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
                        -p 8443:8443 -p 37117:27117 -p 8080:8080 \
                        -v /srv/data/apps/docker/unifi/data:/usr/lib/unifi/data \
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
