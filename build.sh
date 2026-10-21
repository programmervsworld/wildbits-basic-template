#!/bin/bash

projectname="mybasicgame"
spritebin=spr_${projectname}

rm -f build/*.zip
rm -f build/*.bas
rm -f build/*.bin

send_sprites() {
    local pid status frame=0
    local -a poses=('ᗧ' 'ᗣ')

    printf '\nHerding the sprites. Please keep all pixels together.\n'

    # Run whatever transfer command you pass to this function.
    "$@" &
    pid=$!

    if [[ -t 1 && ${TERM:-dumb} != dumb ]]; then
        while kill -0 "$pid" 2>/dev/null; do
            printf '\r  %*s%s  · · ·  SPRITE CROSSING' \
                "$((frame % 24))" '' "${poses[frame % 2]}"
            printf '\033[K'
            frame=$((frame + 1))
            sleep 0.12
        done
        printf '\r\033[K'
    fi

    if wait "$pid"; then
        printf '  Sprites delivered. Only mildly disoriented.\n'
    else
        status=$?
        printf '  Sprite escape detected! Transfer failed (%s).\n' "$status" >&2
        return "$status"
    fi
}

sudo python3 --version

sed -i "s/^#define PROJECT_NAME .*/#define PROJECT_NAME ${projectname}/" src/game.bas
sed -i "s/^#define SPRITE_FILE .*/#define SPRITE_FILE ${spritebin}/" src/game.bas

cat src/game.bas | python3 scripts/number.py > "build/$projectname.bas"

python3 scripts/spritebuild2.py sprites/sprites.def

# This is a hack since copy can't send from directories for whatever reason
mv graphics.bin ${spritebin}.bin
echo "Sending sprites to device...."
printf '\033[1;95m👾 Deploying tiny weirdos…\033[0m\n'
send_sprites sudo python3 fnxmgr.zip --copy ${spritebin}.bin
printf '\033[1;92m✓ Tiny weirdos deployed. Do not feed after midnight.\033[0m\n'
echo -e ""
read -n 1 -s -p "Press any key to load next part......"
mv ${spritebin}.bin build/
echo -e ""

printf '\n\033[1;96m🚀 Beaming BASIC aboard…\033[0m\n'
sudo python3 fnxmgr.zip --binary build/${projectname}.bas --address 28000

printf '\033[1;92m✓ BASIC delivered. The pixels await your command.\033[0m\n'
printf '\n  On your Wildbits, type:\n'
printf '    \033[1;93mXGO\033[0m    — launch the program\n'
printf '    \033[1;93mXLOAD\033[0m  — load it for tinkering\n\n'
