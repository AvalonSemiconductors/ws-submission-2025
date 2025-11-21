#!/bin/bash

set -ex

export PDK=gf180mcuD
export PDK_ROOT=../gf180mcu_pdk/

python3 make_gds.py --cellname aef2 --boundary "0/0" "152/5" --foreground "81/0" --aggressive_fixes --pixel-size 0.5 aef2.png aef2.gds
python3 make_gds.py --cellname avali_logo --boundary "0/0" "152/5" --foreground "81/0" --aggressive_fixes --pixel-size 0.5 Logo_BW.png avali_logo.gds

echo "calma read aef2.gds;load aef2;lef write;" | magic -dnull -noconsole -rcfile $PDK_ROOT/$PDK/libs.tech/magic/gf180mcuD.magicrc
echo "calma read avali_logo.gds;load avali_logo;lef write;" | magic -dnull -noconsole -rcfile $PDK_ROOT/$PDK/libs.tech/magic/gf180mcuD.magicrc
