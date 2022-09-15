PROJECT=website

include ../image-builder/config.mk
include ../image-builder/image.mk

.PHONY: image

image: linuxwolf/website

linuxwolf/website: Dockerfile