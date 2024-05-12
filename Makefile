# Default targets
.PHONY: default build start stop clean clean-all
default: start

# Makefile setup
SHELL:=/bin/bash

# Help
usage:
	@echo "make TARGET"
	@echo "   TARGETS: "
	@echo "     usage: Help message"
	@echo ""

build: stop
	@docker-compose build
	@[ -f .env ] || echo "ERROR! Create .env file before starting. Exiting now."

start: build
	@docker-compose up -d

stop:
	@-docker-compose down

clean:
	@docker-compose rm -s -f

clean-all:
	@docker-compose rm -s -f -v
	@docker rmi wordpress

