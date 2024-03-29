PROJECT=website
DOCKER_REPO_OWNER=o-p-n
DOCKER_CACHE=${HOME}/.cache/docker-buildx
DOCKER_BUILDER=container-builder

DOCKER_CONTEXT?=default
STAMP?=latest

include .builder/main.mk

.builder/main.mk:
	git clone -q https://github.com/o-p-n/image-builder.git -b main .builder

image: $(DOCKER_REPO_OWNER)/website

$(DOCKER_REPO_OWNER)/website: Dockerfile

publish: image
	STAMP=$(STAMP) \
	DOCKER_REGISTRY=$(DOCKER_REGISTRY) \
	docker -c $(DOCKER_CONTEXT) stack deploy -c docker-compose.yaml $(PROJECT)