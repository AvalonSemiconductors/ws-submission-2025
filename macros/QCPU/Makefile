PDK?=gf180mcuD

project:
	librelane --pdk $(PDK) --run-tag latest --overwrite --manual-pdk config.yaml

gui:
	librelane --pdk $(PDK) --manual-pdk --last-run config.yaml --flow OpenInOpenROAD

.PHONY: project
