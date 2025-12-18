PDK?=gf180mcuD
PDK_ROOT?=../../gf180mcu_pdk

project:
	librelane --pdk $(PDK) --pdk-root $(PDK_ROOT) --manual-pdk --run-tag latest --overwrite config.yaml

gui:
	librelane --pdk $(PDK) --pdk-root $(PDK_ROOT) --manual-pdk --last-run config.yaml --flow OpenInOpenROAD

klayout:
	echo "Choose 'yes' on the window that pops up and do File > Load Layer Properties and choose 'gf180mcu.lyp'"
	# You may also have to restart klayout after first run for everything to load correctly
	klayout runs/latest/final/gds/secret_message.gds
magic:
	cp magicrc_base ~/.magicrc
	echo "Run 'select top cell; expand' in the console for a full view"
	# Magic also lags until DRC is complete. Or you can click the "DRC" checkbox on the top bar to turn it off.
	magic -d OGL runs/latest/final/mag/secret_message.mag

.PHONY: project
