#!/bin/bash

projectname="mybasicgame"
spritebin=spr_${projectname}
PYTHON_PATH=""
DEPLOY=false
CODE_ONLY=false
EMULATE=false
MAME_PATH="/home/jdowning/github/mame"

PARSED_ARGS=$(getopt --options d:c:e --longoptions deploy,code-only,emulate --name "$0" -- "$@")
if [ $? -ne 0 ]; then exit 1; fi
eval set -- "$PARSED_ARGS"
echo "Parsed Args: $PARSED_ARGS"

while true; do
	case "$1" in
		-d|--deploy) DEPLOY=true; shift ;;
		-c|--code-only) DEPLOY=true; CODE_ONLY=true; shift ;; 
		-e|--emulate) DEPLOY=false; EMULATE=true; shift ;;
		--) shift; break ;;
		*) echo "Error: Unexpected flag $1"; exit 1 ;;
	esac	
done

if command -v python3 > /dev/null 2>&1; then
        PYTHON_PATH=$(command -v python3)
elif command -v python > /dev/null 2>&1; then
        PYTHON_PATH=$(command -v python)
else
        echo "Python isn't installed. You have to have it to run this script."
        exit
fi

echo "Deploy is $DEPLOY"
echo "Code Only is $CODE_ONLY"

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

sudo "$PYTHON_PATH" --version

sed -i "s/^#define PROJECT_NAME .*/#define PROJECT_NAME ${projectname}/" src/game.bas
sed -i "s/^#define SPRITE_FILE .*/#define SPRITE_FILE ${spritebin}/" src/game.bas

"$PYTHON_PATH" scripts/number.py < src/game.bas > "build/$projectname.bas"

"$PYTHON_PATH" scripts/spritebuild2.py sprites/sprites.def

# This is a hack since copy can't send from directories for whatever reason
mv graphics.bin ${spritebin}.bin

if $DEPLOY; then
	if ! $CODE_ONLY; then
		echo "Sending sprites to device...."
		printf '\033[1;95m👾 Deploying tiny weirdos…\033[0m\n'
		send_sprites sudo "$PYTHON_PATH" fnxmgr.zip --copy ${spritebin}.bin
		printf '\033[1;92m✓ Tiny weirdos deployed. Do not feed after midnight.\033[0m\n'
		echo -e ""
		read -n 1 -s -p "Press any key to load next part......"
		echo -e ""
	fi

	printf '\n\033[1;96m🚀 Beaming BASIC aboard…\033[0m\n'
	sudo "$PYTHON_PATH" fnxmgr.zip --binary build/${projectname}.bas --address 28000

	printf '\033[1;92m✓ BASIC delivered. The pixels await your command.\033[0m\n'
	printf '\n  On your Wildbits, type:\n'
	printf '    \033[1;93mXGO\033[0m    — launch the program\n'
	printf '    \033[1;93mXLOAD\033[0m  — load it for tinkering\n\n'
fi

# Final step is just to zip up what we did in the build dir so that we have a copy.
mv ${spritebin}.bin build/
cd build || exit
zip "$projectname.zip" "$projectname.bas" "$spritebin.bin"

sudo mkdir -p /mnt/f256
sudo mount -o loop,offset=$((2048 * 512)) f256sd.img /mnt/f256
sudo cp "$projectname.bas" /mnt/f256/
sudo cp "$spritebin.bin" /mnt/f256/
sudo umount /mnt/f256

pwd
if $EMULATE; then
	${MAME_PATH}/f256k f256k -rompath ${MAME_PATH}/roms -window -harddisk $(pwd)/f256sd.img
fi
