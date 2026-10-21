#define SPRITE_START $30000
#define PROJECT_NAME mybasicgame
cls:sprites on:bitmap on:bitmap clear 10
bload "spr_mybasicgame.bin", $30000
helloworld()
end
proc helloworld()
	sprite 0 image 0 to 16,16
	print at 2,8 "Hello"
	print at 3,8 "World!
	print at 4,8 "PROJECT_NAME.bas"
endproc
