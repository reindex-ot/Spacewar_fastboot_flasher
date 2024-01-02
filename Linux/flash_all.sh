#!/bin/bash

echo "#################################################"
echo "#           Pong Fastboot ROM Flasher           #"
echo "#              Developed/Tested By              #"
echo "#  Hellboy017, Ali Shahawez, Spike, Phatwalrus  #"
echo "#     [Nothing Phone (2) Telegram Dev Team]     #"
echo "#################################################"

echo "#############################"
echo "# CHANGING ACTIVE SLOT TO A #"
echo "#############################"
fastboot --set-active=a

echo "###################"
echo "# FORMATTING DATA #"
echo "###################"
read -p "Wipe Data? (y/n) " DATA_RESP 
case $DATA_RESP in
    [yY] )
        echo 'Please ignore "Did you mean to format this partition?" warnings.'
        fastboot erase userdata
        fastboot erase metadata
        ;;
esac

echo "##########################"
echo "# FLASHING BOOT/RECOVERY #"
echo "##########################"
for i in boot vendor_boot dtbo recovery; do 
    fastboot flash $i $i.img
done

echo "##########################"             
echo "# REBOOTING TO FASTBOOTD #"       
echo "##########################"
fastboot reboot fastboot

echo  "#####################"
echo  "# FLASHING FIRMWARE #"
echo  "#####################"
read -p "Flash firmware on both slots? (y/n) " FIRMWARE_RESP 
case $FIRMWARE_RESP in
    [yY] )
        for i in abl aop bluetooth cpucp devcfg dsp featenabler hyp imagefv keymaster modem multiimgoem multiimgqti qupfw qweslicstore shrm tz uefi uefisecapp xbl xbl_config xbl_ramdump; do
            fastboot flash --slot=all $i $i.img
        done
        ;;
    *)
        for i in abl aop bluetooth cpucp devcfg dsp featenabler hyp imagefv keymaster modem multiimgoem multiimgqti qupfw qweslicstore shrm tz uefi uefisecapp xbl xbl_config xbl_ramdump; do
            fastboot flash $i $i.img
        done
        ;;
esac

echo "###############################"
echo "# RESIZING LOGICAL PARTITIONS #"
echo "###############################"
for i in odm_a system_a system_ext_a product_a vendor_a vendor_dlkm_a odm_b system_b system_ext_b product_b vendor_b vendor_dlkm_b; do
    fastboot delete-logical-partition $i-cow
    fastboot delete-logical-partition $i
    fastboot create-logical-partition $i 1
done

echo "###############################"
echo "# FLASHING LOGICAL PARTITIONS #"
echo "###############################"
for i in system system_ext product vendor vendor_dlkm odm vbmeta vbmeta_system vbmeta_vendor; do
    fastboot flash $i $i.img
done

echo "#############"
echo "# REBOOTING #"
echo "#############"
read -p "Reboot to system? (y/n) " REBOOT_RESP 
case $REBOOT_RESP in
    [yY] )
        fastboot reboot
        ;;
esac

exit 1
