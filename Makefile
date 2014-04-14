build:
	coffee -cbm -o lib src
	chmod +x lib/csub
watch:
	coffee -cbwm -o lib src
