# !/usr/bin/make - f

SHELL                   := /usr/bin/env bash
DOCKER_NAMESPACE        ?= robinastedt
IMAGE_NAME              ?= opengl
VERSION                 := $(shell git describe --tags --abbrev=0 2>/dev/null || git rev-parse --abbrev-ref HEAD)
VCS_REF                 := $(shell git rev-parse --short HEAD)
BUILD_DATE              := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
ARCH                    := $(shell uname -m)
RELEASES                := 18.2.8 18.3.6 19.0.8
LATEST_TAG              := 19.0.8
STABLE_TAG              := 19.0.8

# Default target is to build all defined Mesa releases.
.PHONY: default
default: 19.0.8 tag-latest

.PHONY: latest
latest: $(LATEST_TAG) tag-latest

.PHONY: stable
stable: $(STABLE_TAG) tag-stable

.PHONY: all
all: $(RELEASES) tag-latest tag-stable

# Build base images for all releases.
.PHONY: $(RELEASES)
$(RELEASES):
	docker build \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg MESA_VERSION=$(@) \
		--tag $(DOCKER_NAMESPACE)/$(IMAGE_NAME):$(@) \
		--tag $(DOCKER_NAMESPACE)/$(IMAGE_NAME):$(@)-$(VCS_REF) \
		--tag $(DOCKER_NAMESPACE)/$(IMAGE_NAME):$(@)-$(VERSION) \
		--file Dockerfile .; \

# Tag our latest release
.PHONY: tag-latest
tag-latest:
	docker tag $(DOCKER_NAMESPACE)/$(IMAGE_NAME):$(LATEST_TAG) $(DOCKER_NAMESPACE)/$(IMAGE_NAME):latest

# Tag our stable release
.PHONY: tag-stable
tag-stable:
	docker tag $(DOCKER_NAMESPACE)/$(IMAGE_NAME):$(STABLE_TAG) $(DOCKER_NAMESPACE)/$(IMAGE_NAME):stable
