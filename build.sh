#!/bin/bash

projectname="mybasicgame"

rm -f build/*.zip
rm -f build/*.bas
rm -f build/*.bin

cat src/game.bas | python3 scripts/number.py > "build/$projectname.bas"

sudo python3 fnxmgr.zip --binary build/${projectname}.bas --address 28000
