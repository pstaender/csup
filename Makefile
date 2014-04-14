build:
	coffee -cbm -o lib src
	chmod +x bin/csup
watch:
	coffee -cbwm -o lib src
