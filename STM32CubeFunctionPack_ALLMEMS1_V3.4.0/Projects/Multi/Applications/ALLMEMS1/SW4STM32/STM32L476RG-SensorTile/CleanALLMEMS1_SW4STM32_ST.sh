#!/bin/bash

######## Modify this Section:
# 1) Set the Installation path for OpenOCD
# example:
#OpenOCD_DIR="C:/Ac6/SystemWorkbench/plugins/fr.ac6.mcu.externaltools.openocd.win32_1.17.0.201801120948/tools/openocd/"
#OpenOCD_DIR="/home/matteo/Ac6/SystemWorkbench/plugins/fr.ac6.mcu.externaltools.openocd.linux64_1.23.0.201904120827/tools/openocd"
OpenOCD_DIR="/home/matteo/Ac6/SystemWorkbench/plugins/fr.ac6.mcu.externaltools.openocd.linux64_1.23.0.201904120827/tools/openocd"

# 2) Set the installation path for stm32 OpenOCD scritps
# example:
#OpenOCD_CFC="C:/Ac6/SystemWorkbench/plugins/fr.ac6.mcu.debug_2.1.4.201801120948/resources/openocd/scripts"
#OpenOCD_CFC="/home/matteo/Ac6/SystemWorkbench/plugins/fr.ac6.mcu.debug_2.5.0.201904120827/resources/openocd/scripts"
OpenOCD_CFC=" /home/matteo/Ac6/SystemWorkbench/plugins/fr.ac6.mcu.debug_2.5.0.201904120827/resources/openocd/scripts"

# 3) Only for Linux/iOS add openocd library path to _LIBRARY_PATH:
# For iOS example:
#export DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${OpenOCD_DIR}"lib/"

# For Linux example:
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${OpenOCD_DIR}"lib/"

######## Don't change the following part

## Control Section

if [[ ! $OpenOCD_DIR ]];  then
	echo "Please add the rigth path to OpenOCD_DIR Variable"
	exit
fi

if [[ ! $OpenOCD_CFC ]];  then
	echo "Please add the rigth path to OpenOCD_CFC Variable"
	exit
fi


## Run section

# Board type
BOARDNAME="nucleo_l476rg"

# OpenOCD command
OpenOCD_CMD="${OpenOCD_DIR}/bin/openocd -s ${OpenOCD_CFC} -f st_board/${BOARDNAME}.cfg"


echo "/******************************************/"
echo "           Clean FP-SNS-ALLMEMS1"
echo "/******************************************/"
echo "             Full Chip Erase"
echo "/******************************************/"
${OpenOCD_CMD} -c "init" -c "reset halt" -c "flash erase_sector 0 511 511" -c "shutdown"
echo "/******************************************/"
echo "              Install BootLoader"
echo "/******************************************/"
${OpenOCD_CMD} -c "init" -c "reset halt" -c "flash write_image erase ../../../../../../Utilities/BootLoader/STM32L476RG/BootLoaderL4.bin 0x08000000 bin" -c "shutdown"
echo "/******************************************/"
echo "           Install FP-SNS-ALLMEMS1"
echo "/******************************************/"
${OpenOCD_CMD} -c "init" -c "reset halt" -c "flash write_image erase  ./STM32L4xx-SensorTile/Debug/ALLMEMS1_ST.bin 0x08004000 bin" -c "shutdown"
echo "/******************************************/"
echo "     Dump FP-SNS-ALLMEMS1 + BootLoader"
echo "/******************************************/"

SizeBinBL=`ls -l ./STM32L4xx-SensorTile/Debug/ALLMEMS1_ST.bin | awk '{print $6+0x4000};'`
${OpenOCD_CMD} -c "init" \
			   -c "reset halt" \
			   -c "dump_image ./STM32L4xx-SensorTile/Debug/ALLMEMS1_ST_BL.bin 0x08000000 ${SizeBinBL}" \
			   -c "shutdown"
			   
