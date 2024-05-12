# Default targets
.PHONY: default build start stop clean
default: start

# Makefile setup
SHELL:=/bin/bash
IMAGENAME ?= wp
CONTNAME ?= $(IMAGENAME)

# Help
usage:
	@echo "make TARGET"
	@echo "   TARGETS: "
	@echo "     usage: Help message"
	@echo ""

build: stop
	docker build -t $(IMAGENAME) .

start: build
	docker run --rm --name $(CONTNAME) $(IMAGENAME)
stop:
	-docker container kill $(CONTNAME)
clean: stop
	-docker images rm $(IMAGENAME)

