# Default targets
.PHONY: default build start stop clean clean-docker clean-data clean-all
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
	./wordpress/create_proxy.bash

start: build
	./wordpress/start.bash

stop:
	./wordpress/stop.bash

clean: stop
	@-cd wordpress && docker-compose rm -s -f

clean-data: 
	@-sudo rm -rf wordpress/.wordpress

clean-docker: clean
	@-cd wordpress && docker-compose rm -s -f -v
	@-docker rmi wordpress

clean-all: | clean-docker clean-data
	@-rm -rf wordpress/systemd-wp.conf
	@-rm -rf nginx/nginx.conf
	@-rm -rf nginx/nginx-wp.conf
	@-rm -rf nginx/systemd-nginx.conf
	@-rm -rf nginx/selfsigned.key
	@-rm -rf nginx/selfsigned.crt


