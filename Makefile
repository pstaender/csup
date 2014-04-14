build:
	coffee -cbm -o lib src
	chmod +x lib/csup
watch:
	coffee -cbwm -o lib src
