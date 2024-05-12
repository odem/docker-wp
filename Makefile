# Default targets
.PHONY: default build start stop
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
	docker-compose build
	[ -f .env ] || echo "Create .env file before starting"

start: build
	docker-compose up -d

stop:
	docker-compose down

