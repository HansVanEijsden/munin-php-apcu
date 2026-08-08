.PHONY: install uninstall update test clean

install:
	sudo bash install.sh

uninstall:
	sudo bash uninstall.sh

update:
	git pull origin main
	sudo bash install.sh

test:
	@echo "Testing APCu multi plugin..."
	@sudo munin-run php_apcu_multi config | head -10
	@sudo munin-run php_apcu_multi

clean:
	git clean -fdX