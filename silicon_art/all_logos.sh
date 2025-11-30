#!/bin/bash

set -ex

export PDK=gf180mcuD
export PDK_ROOT=../gf180mcu_pdk/

python3 make_gds.py --cellname aef2 --boundary "0/0" "152/5" --foreground "81/0" --aggressive_fixes --pixel-size 0.5 aef2.png aef2.gds
python3 make_gds.py --cellname avali_logo --boundary "0/0" "152/5" --foreground "81/0" --aggressive_fixes --pixel-size 0.6 Logo_BW.png avali_logo.gds
#python3 make_gds.py --cellname tholin --boundary "0/0" "152/5" --foreground "81/0" "46/0" "42/0" "36/0" "34/0" "30/0" --aggressive_fixes --pixel-size 0.6 Tholin_Circuit.png tholin.gds

echo "calma read aef2.gds;load aef2;lef write;" | magic -dnull -noconsole -rcfile $PDK_ROOT/$PDK/libs.tech/magic/gf180mcuD.magicrc
echo "calma read avali_logo.gds;load avali_logo;lef write;" | magic -dnull -noconsole -rcfile $PDK_ROOT/$PDK/libs.tech/magic/gf180mcuD.magicrc
#echo "calma read tholin.gds;load tholin;lef write;" | magic -dnull -noconsole -rcfile $PDK_ROOT/$PDK/libs.tech/magic/gf180mcuD.magicrc
