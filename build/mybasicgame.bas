1000 cls:sprites on:bitmap on:bitmap clear 10
1010 bload "spr_mybasicgame.bin", $30000
1020 helloworld()
1030 end
1040 proc helloworld()
1050 sprite 0 image 0 to 16,16
1060 print at 2,8 "Hello"
1070 print at 3,8 "World!
1080 print at 4,8 "mybasicgame.bas"
1090 endproc
ÿÿÿÿ
