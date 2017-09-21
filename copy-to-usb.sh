echo coping to usb ...
dd if=/dev/zero of=/dev/sdb bs=1440K count=1
dd if=./obj/mydisk.img of=/dev/sdb conv=notrunc bs=512 seek=0 count=126 
echo done!
