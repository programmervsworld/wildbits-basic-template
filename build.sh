#!/bin/bash

projectname="mybasicgame"
spritebin=spr_${projectname}

rm -f build/*.zip
rm -f build/*.bas
rm -f build/*.bin

sed -i "s/^#define PROJECT_NAME .*/#define PROJECT_NAME ${projectname}/" src/game.bas
cat src/game.bas | python3 scripts/number.py > "build/$projectname.bas"

python3 scripts/spritebuild2.py sprites/sprites.def

# This is a hack since copy can't send from directories for whatever reason
mv graphics.bin ${spritebin}.bin
echo "Sending sprites to device...."
sudo python3 fnxmgr.zip --copy ${spritebin}.bin
read -n 1 -s -p "Press any key to load next part......"
mv ${spritebin}.bin build/

echo "Sending basic files to device...."
sudo python3 fnxmgr.zip --binary build/${projectname}.bas --address 28000

echo "########################################"
echo "# Game is loaded type XGO on device #"
echo "########################################"
