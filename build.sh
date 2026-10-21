#!/bin/bash

rm -f build/*.zip
rm -f build/*.bas
rm -f build/*.bin

cat src/game.bas | python3 scripts/number.py > build/game.bas

sudo python3 fnxmgr.zip --binary build/game.bas --address 28000
