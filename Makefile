.PHONY: install uninstall update test clean

install:
	sudo bash install.sh

uninstall:
	sudo bash uninstall.sh

update:
	git pull origin main
	sudo bash install.sh

test:
	@echo "Testing APCu plugin..."
	@for container in $$(docker ps --format "{{.Names}}" | grep -E 'php$$'); do \
		echo "=== APCu - $$container ==="; \
		sudo munin-run php_apcu_$$container config | head -5; \
		sudo munin-run php_apcu_$$container; \
		echo ""; \
	done

clean:
	git clean -fdX