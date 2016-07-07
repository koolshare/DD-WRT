#!/bin/sh
### #########################################
### This must be setup on build host
### #########################################
DEVDIR=/home/houzi/DD-WRT
#GCCARM=/home/houzi/toolchains/toolchain-arm_cortex-a9_gcc-4.8-linaro_musl-1.1.5_eabi/bin
GCCARM=/home/houzi/toolchain/toolchains/toolchain-arm_cortex-a9_gcc-5.2.0_musl-1.1.11_eabi/bin
#REVISION="29846M" # redefined, just default value
KERNELVERSION="3.10" # 3.10 stable, 4.4 experimental
export PATH=$GCCARM:$PATH
export PATH=/home/houzi/toolchain/toolchains/toolchain-arm_cortex-a9_gcc-5.2.0_musl-1.1.11_eabi/bin:$PATH
export ARCH=arm

cd $DEVDIR
#REVISION=`git log --grep git-svn-id -n 1|grep -i dd-wrt|awk '{print $2}'|awk -F'@' '{print $2}'`
#EXTENDNO="-"`git rev-parse --verify HEAD --short|cut -c 1-4`"-by-houzi"
EXTENDNO="-"`svn info | grep UUID | sed -e "s;Repository UUID: ;;g" | cut -c 1-4`"-by-houzi"

# choose Kernel kconfig
cp -f $DEVDIR/src/linux/universal/linux-$KERNELVERSION/.config_northstar $DEVDIR/src/linux/universal/linux-$KERNELVERSION/.config

### ###################
### setup target router
### ###################
# brcm_arm_16M
#cp -f $DEVDIR/src/router/configs/northstar/.config_northstar_16m $DEVDIR/src/router/.config
# brcm_arm_big
cp -f $DEVDIR/src/router/configs/northstar/.config_northstar $DEVDIR/src/router/.config
# R8000 and R8500
#cp -f $DEVDIR/src/router/configs/northstar/.config_northstar_std_dhd_128K $DEVDIR/src/router/.config
# ipq806x
#cp -f $DEVDIR/src/router/configs/ipq806x/.config_ipq806x $DEVDIR/src/router/.config
#cp -f $DEVDIR/src/router/configs/ipq806x/.config_r7500 $DEVDIR/src/router/.config
# MINI (~10MB firmware) - try to build with that config it first!
# cp -f $DEVDIR/src/router/configs/northstar/.config_ws880_mini $DEVDIR/src/router/.config
# 16M (~16MB firmware)
#cp -f $DEVDIR/src/router/configs/northstar/.config_ws880_16m $DEVDIR/src/router/.config
# STD (~30MB firmware)
#cp -f $DEVDIR/src/router/configs/northstar/.config_ws880 $DEVDIR/src/router/.config
# R1D (14.3MB MAX)
#cp -f $DEVDIR/src/router/configs/northstar/($(CONFIG_SAMBA),y).config_xiaomi_r1d $DEVDIR/src/router/.config
#echo "CONFIG_BUILD_HUAWEI=y" >> $DEVDIR/src/router/.config
#echo "CONFIG_USB_AUDIO=y" >> $DEVDIR/src/router/.config
echo "CONFIG_PPTP_PLUGIN=y" >> $DEVDIR/src/router/.config
#echo "CONFIG_TPROXY=y" >> $DEVDIR/src/router/.config
echo "CONFIG_IPVS=y" >> $DEVDIR/src/router/.config
#echo "CONFIG_SUPERCHANNEL=y" >> $DEVDIR/src/router/.config
#sed -i 's/CONFIG_RADVD=y/#CONFIG_RADVD=y/g' $DEVDIR/src/router/.config
#sed -i 's/CONFIG_USBIP=y/#CONFIG_USBIP=y/g' $DEVDIR/src/router/.config
#sed -i 's/CONFIG_IPV6=y/CONFIG_IPV6=n/g' $DEVDIR/src/router/.config
#sed -i 's/CONFIG_OPENDPI=y/#CONFIG_OPENDPI=y/g' $DEVDIR/src/router/.config
sed -i 's/CONFIG_SUPERCHANNEL=y/#CONFIG_SUPERCHANNEL=y/g' $DEVDIR/src/router/.config
sed -i 's/CONFIG_SPUTNIK_APD=y/#CONFIG_SPUTNIK_APD=y/g' $DEVDIR/src/router/.config
sed -i 's/CONFIG_NOCAT=y/#CONFIG_NOCAT=y/g' $DEVDIR/src/router/.config
sed -i 's/CONFIG_HOSTAPD2=y/#CONFIG_HOSTAPD2=y/g' $DEVDIR/src/router/.config
sed -i 's/CONFIG_AIRCRACK=y/#CONFIG_AIRCRACK=y/g' $DEVDIR/src/router/.config
sed -i 's/CONFIG_MC=y/#CONFIG_MC=y/g' $DEVDIR/src/router/.config
sed -i 's/CONFIG_ASTERISK=y/#CONFIG_ASTERISK=y/g' $DEVDIR/src/router/.config
sed -i 's/CONFIG_MACTELNET=y/#CONFIG_MACTELNET=y/g' $DEVDIR/src/router/.config

# Set Kernel version
if [ $KERNELVERSION = "3.10" ]; then
sed -i 's/KERNELVERSION=4.4/KERNELVERSION=3.10/g' $DEVDIR/src/router/.config
fi

if [ $KERNELVERSION = "3.18" ]; then
sed -i 's/KERNELVERSION=4.4/KERNELVERSION=3.18/g' $DEVDIR/src/router/.config
fi

# Kernel version show
cd $DEVDIR/src/linux/universal/linux-$KERNELVERSION
echo "1337" > .version

# Make fw for other brands too
# (uncomment desired and check src/router/Makefile.northstar)
#echo "CONFIG_BUILD_XIAOMI=y" >> $DEVDIR/src/router/.config
#echo "CONFIG_BUILD_TPLINK=y" >> $DEVDIR/src/router/.configmake -f Makefile.northstar pcre
#echo "CONFIG_BUILD_DLINK=y" >> $DEVDIR/src/router/.config
#echo "CONFIG_BUILD_ASUS=y" >> $DEVDIR/src/router/.config
#echo "CONFIG_BUILD_BUFFALO=y" >> $DEVDIR/src/router/.config
#echo "CONFIG_BUILD_NETGEAR=y" >> $DEVDIR/src/router/.config
#echo "CONFIG_DHDAP=y" >> $DEVDIR/src/router/.config
#echo "CONFIG_NVRAM_128K=y" >> $DEVDIR/src/router/.config
#sed -i 's/CONFIG_NVRAM_128K=y/#CONFIG_NVRAM_128K=y/g' $DEVDIR/src/router/.config
#echo "CONFIG_BUILD_TRENDNET=y" >> $DEVDIR/src/router/.config

# !!! TEMP need to fix
echo "NO_PROCESSLANGFILES=y" >> $DEVDIR/src/router/.config

cd $DEVDIR/src/router/libutils
echo -n '#define SVN_REVISION "' > revision.h
svnversion -n . >> revision.h
#echo -n $REVISION >> revision.h
echo -n $EXTENDNO >> revision.h
echo '"' >> revision.h

cd $DEVDIR/src/router/services
echo -n '#define SVN_REVISION "' > revision.h
svnversion -n . >> revision.h
#echo -n $REVISION >> revision.h
echo -n $EXTENDNO >> revision.h
echo '"' >> revision.h

cd $DEVDIR/src/router/httpd/visuals
echo -n '#define SVN_REVISION "' > revision.h
svnversion -n . >> revision.h
#echo -n $REVISION >> revision.h
echo -n $EXTENDNO >> revision.h
echo '"' >> revision.h

cd $DEVDIR/src/router/httpd
echo -n '#define SVN_REVISION "' > revision.h
svnversion -n . >> revision.h
#echo -n $REVISION >> revision.h
echo -n $EXTENDNO >> revision.h
echo '"' >> revision.h

### #################################################################
### compile them once to make sure these binaries work on your distro,
### then comment them as i did
### ###

### compile trx ###
cd $DEVDIR/opt/tools/
gcc -o trx trx.c
gcc -o trx_asus trx_asus.c

### compile jsformat ###
cd $DEVDIR/src/router/tools
rm jsformat
make jsformat

### compile webcomp tools ###
cd $DEVDIR/tools/
rm ./process_langfile
gcc process_langfile.c -o ./process_langfile
rm ./process_nvramconfigfile
gcc process_nvramconfigfile.c -o ./process_nvramconfigfile
rm ./removewhitespace
gcc removewhitespace.c -o ./removewhitespace
rm ./strip
gcc strip.c -o ./strip
rm ./write3
gcc write3.c -o ./write3
rm ./write4
gcc write4.c -o ./write4
rm ./webcomp
gcc -o webcomp -DUEMF -DWEBS -DLINUX webcomp.c

echo ""
echo "************************************"
echo "*"
echo "* Fix all configs "
echo "*"
echo "************************************"
echo ""
### #########################################
### * comment this section after 1st run
### * some fixes doesn't needed at all...
### ###
#cd $DEVDIR/src/router/zlib
#aclocal

#cd $DEVDIR/src/router/openssl
#aclocal

#cd $DEVDIR/src/router/jansson
#aclocal

### glib2.0/gettext automake version build error fix (moved to rules/*.mk)
### it still needs aclocal-1.13, link it in case yourth newer
#sudo ln -s /usr/bin/automake /usr/bin/automake-1.13
#sudo ln -s /usr/bin/aclocal /usr/bin/aclocal-1.13
#sudo ln -s /usr/bin/automake /usr/bin/automake-1.12
#sudo ln -s /usr/bin/aclocal /usr/bin/aclocal-1.12

###  glib20 compile fix
#cd $DEVDIR/src/router/glib20/gettext
#aclocal
#autoreconf -ivf

#cd $DEVDIR/src/router/glib20/gettext/gettext-tools
#aclocal

cd $DEVDIR/src/router/glib20/libiconv
aclocal

#cd $DEVDIR/src/router/glib20/libglib
#aclocal
#autoconf

### libusb compile fix
cd $DEVDIR/src/router/usb_modeswitch/libusb
aclocal
autoreconf -ivf

### comgt compile fix
cd $DEVDIR/src/router/usb_modeswitch/libusb-compat
aclocal
autoreconf -ivf

#cd $DEVDIR/src/router/pptpd
#aclocal

#cd $DEVDIR/src/router/igmp-proxy
#aclocal

#cd $DEVDIR/src/router/nocat
#aclocal

### for snort (moved to rules/*.mk)
#cd $DEVDIR/src/router/libnfnetlink
#aclocal
#autoreconf -ivf
#cd $DEVDIR/src/router/libnetfilter_queue
#aclocal
#autoreconf -ivf
#cd $DEVDIR/src/router/daq
#aclocal
#autoconf
#automake --add-missing
#autoreconf -ivf

#cd $DEVDIR/src/router/tor
#aclocal
#autoconf
#automake --add-missing
#autoreconf -ivf

### miss automake
cd $DEVDIR/src/router/usbip
automake --add-missing

cd $DEVDIR/src/router/libgd
automake --add-missing

cd $DEVDIR/src/router/coova-chilli
automake --add-missing

cd $DEVDIR/src/router/daq
automake --add-missing

#cd $DEVDIR/src/router/zabbix
#aclocal

#cd $DEVDIR/src/router/openvpn
#aclocal
#autoconf
### #########################################

cd $DEVDIR/src/router
echo ""
echo "************************************"
echo "* Essentials..."
echo "************************************"
echo ""
make -f Makefile.northstar zlib-configure
make -f Makefile.northstar jansson-configure
make -f Makefile.northstar zlib
make -f Makefile.northstar jansson
make -f Makefile.northstar nvram
make -f Makefile.northstar shared
make -f Makefile.northstar utils
make -f Makefile.northstar libutils
make -f Makefile.northstar openssl-configure
make -f Makefile.northstar openssl
make -f Makefile.northstar dropbear-configure
make -f Makefile.northstar dropbear
make -f Makefile.northstar dhcpforwarder-configure
make -f Makefile.northstar dhcpforwarde
make -f Makefile.northstar bird-configure
make -f Makefile.northstar bird
make -f Makefile.northstar libpcap-configure
make -f Makefile.northstar libpcap
make -f Makefile.northstar tcpdump-configure
make -f Makefile.northstar tcpdump
make -f Makefile.northstar wol-configure
make -f Makefile.northstar wol
make -f Makefile.northstar radvd-configure
make -f Makefile.northstar radvd
make -f Makefile.northstar rtpproxy-configure
make -f Makefile.northstar rtpproxy
make -f Makefile.northstar ntfs-3g-configure
make -f Makefile.northstar ntfs-3g
make -f Makefile.northstar igmp-proxy-configure
make -f Makefile.northstar igmp-proxy
make -f Makefile.northstar lzo-configure
make -f Makefile.northstar lzo
make -f Makefile.northstar e2fsprogs-configure
make -f Makefile.northstar e2fsprogs
make -f Makefile.northstar dhcpv6-configure
make -f Makefile.northstar dhcpv6
make -f Makefile.northstar ncurses-configure
make -f Makefile.northstar ncurses
make -f Makefile.northstar wifidog-configure
make -f Makefile.northstar wifidog
make -f Makefile.northstar iperf-configure
make -f Makefile.northstar iperf
make -f Makefile.northstar proftpd-configure
make -f Makefile.northstar proftpd
make -f Makefile.northstar usb_modeswitch-clean
make -f Makefile.northstar usb_modeswitch-configure
make -f Makefile.northstar usb_modeswitch
make -f Makefile.northstar comgt-clean
make -f Makefile.northstar comgt-configure
make -f Makefile.northstar comgt
make -f Makefile.northstar glib20-clean
make -f Makefile.northstar glib20-configure
make -f Makefile.northstar glib20
make -f Makefile.northstar libevent-configure
make -f Makefile.northstar libevent
make -f Makefile.northstar tor-configure
make -f Makefile.northstar tor
make -f Makefile.northstar libffi-configure
make -f Makefile.northstar libffi
make -f Makefile.northstar usbip-clean
make -f Makefile.northstar usbip-configure
make -f Makefile.northstar usbip
make -f Makefile.northstar ipeth-configure
make -f Makefile.northstar ipeth
make -f Makefile.northstar libxml2-configure
make -f Makefile.northstar libxml2
make -f Makefile.northstar json-c-configure
make -f Makefile.northstar json-c
make -f Makefile.northstar uqmi-configure
make -f Makefile.northstar uqmi
make -f Makefile.northstar pcre-configure
make -f Makefile.northstar pcre
make -f Makefile.northstar curl-clean
make -f Makefile.northstar curl-configure
make -f Makefile.northstar curl
make -f Makefile.northstar tcpdump-clean
make -f Makefile.northstar tcpdump-configure
make -f Makefile.northstar tcpdump
make -f Makefile.northstar snmp-clean
make -f Makefile.northstar snmp-configure
make -f Makefile.northstar snmp
make -f Makefile.northstar chillispot-clean
make -f Makefile.northstar chillispot-configure
make -f Makefile.northstar chillispot
make -f Makefile.northstar mtr-clean
make -f Makefile.northstar mtr-configure
make -f Makefile.northstar mtr
make -f Makefile.northstar quagga-clean
make -f Makefile.northstar quagga-configure
make -f Makefile.northstar quagga
make -f Makefile.northstar libubox-clean
make -f Makefile.northstar libubox-configure
make -f Makefile.northstar libubox
make -f Makefile.northstar jansson-clean
make -f Makefile.northstar jansson-configure
make -f Makefile.northstar jansson
make -f Makefile.northstar wol-clean
make -f Makefile.northstar wol-configure
make -f Makefile.northstar wol
make -f Makefile.northstar radvd-clean
make -f Makefile.northstar radvd-configure
make -f Makefile.northstar radvd
make -f Makefile.northstar ntfs-3g-clean
make -f Makefile.northstar ntfs-3g-configure
make -f Makefile.northstar ntfs-3g
make -f Makefile.northstar zabbix-clean
make -f Makefile.northstar zabbix-configure
make -f Makefile.northstar zabbix
make -f Makefile.northstar libgd-clean
make -f Makefile.northstar libgd-configure
make -f Makefile.northstar libgd
make -f Makefile.northstar libpng-clean
make -f Makefile.northstar libpng-configure
make -f Makefile.northstar libpng
make -f Makefile.northstar iperf-clean
make -f Makefile.northstar iperf-configure
make -f Makefile.northstar iperf
make -f Makefile.northstar freeradius-clean
make -f Makefile.northstar freeradius-configure
make -f Makefile.northstar freeradius
make -f Makefile.northstar util-linux-clean
make -f Makefile.northstar util-linux-configure
make -f Makefile.northstar util-linux
make -f Makefile.northstar libnfnetlink-clean
make -f Makefile.northstar libnfnetlink-configure
make -f Makefile.northstar libnfnetlink
make -f Makefile.northstar libnetfilter_queue-clean
make -f Makefile.northstar libnetfilter_queue-configure
make -f Makefile.northstar libnetfilter_queue
make -f Makefile.northstar libdnet-clean
make -f Makefile.northstar libdnet-configure
make -f Makefile.northstar libdnet
make -f Makefile.northstar daq-clean
make -f Makefile.northstar daq-configure
make -f Makefile.northstar daq
make -f Makefile.northstar pcre-clean
make -f Makefile.northstar pcre-configure
make -f Makefile.northstar pcre
make -f Makefile.northstar snort-clean
make -f Makefile.northstar snort-configure
make -f Makefile.northstar snort
make -f Makefile.northstar lighttpd-clean
make -f Makefile.northstar lighttpd-configure
make -f Makefile.northstar lighttpd
make -f Makefile.northstar unbound-clean
make -f Makefile.northstar unbound-configure
make -f Makefile.northstar unbound
make -f Makefile.northstar php5-clean
make -f Makefile.northstar php5-configure
make -f Makefile.northstar php5
make -f Makefile.northstar privoxy-clean
make -f Makefile.northstar privoxy-configure
make -f Makefile.northstar privoxy
make -f Makefile.northstar transmission-clean
make -f Makefile.northstar transmission-configure
make -f Makefile.northstar transmission

mkdir -p $DEVDIR/logs
echo ""
echo "************************************"
echo "* Clean Northstar configure..."
echo "* Configure Northstar targets..."
echo "* doesn't need to run on every build"
echo "* comment if build with same config"
echo "************************************"
echo ""
#(make -f Makefile.northstar configure | tee $DEVDIR/logs/`date "+%Y.%m.%d-%H.%M"`-stdoutconf.log) 3>&1 1>&2 2>&3 | tee $DEVDIR/logs/`date "+%Y.%m.%d-%H.%M"`-stderrconf.log 
echo ""
echo "************************************"
echo "* Make Northstar targets..."
echo "************************************"
echo ""
# make -f Makefile.northstar install_headers
make -f Makefile.northstar kernel # must be builded first, or opendpi won't compile
make -f Makefile.northstar clean all install 2>&1 | tee $DEVDIR/logs/`date "+%Y.%m.%d-%H.%M"`-stdoutbuild.log
# make -f Makefile.northstar all install 2>&1 | tee $DEVDIR/logs/`date "+%Y.%m.%d-%H.%M"`-stdoutbuild.log

# copy xiaomi firmware to image dir
if [ -e arm-uclibc/xiaomi-r1d-firmware.bin ]
then
   STAMP="`date +%Y-%m-%d_%H:%M`"
   mkdir -p ../../image
   cp arm-uclibc/xiaomi-r1d-firmware.bin ../../image/dd-wrt.v3-K"$KERNELVERSION"_Xiaomi_R1D_"$STAMP"_r"$REVISION$EXTENDNO".bin
   echo ""
   echo ""
   echo "Image created: image/dd-wrt.v3-K"$KERNELVERSION"_Xiaomi_R1D_"$STAMP"_r"$REVISION$EXTENDNO".bin"
fi

# copy huawei firmware to image dir
if [ -e arm-uclibc/huawei-ws880-firmware.trx ]
then
   STAMP="`date +%Y-%m-%d_%H:%M`"
   mkdir -p ../../image
   cp arm-uclibc/huawei-ws880-firmware.trx ../../image/dd-wrt.v3-K"$KERNELVERSION"_Huawei_WS880_"$STAMP"_r"$REVISION$EXTENDNO".trx
   echo ""
   echo ""
   echo "Image created: dd-wrt.v3-K"$KERNELVERSION"_Huawei_WS880_"$STAMP"_r"$REVISION$EXTENDNO".trx"
fi

# copy Netgear firmware to image dir
if [ -e arm-uclibc/K3_AC1450.chk ]
then
   STAMP="`date +%Y-%m-%d_%H:%M`"
   mkdir -p ../../image
   cp arm-uclibc/K3_AC1450.chk ../../image/dd-wrt.v3-K"$KERNELVERSION"_Netgear_AC1450_"$STAMP"_r"$REVISION$EXTENDNO".chk
   echo ""
   echo ""
   echo "Image created: dd-wrt.v3-K"$KERNELVERSION"_Netgear_AC1450_"$STAMP"_r"$REVISION$EXTENDNO".chk"
fi

if [ -e arm-uclibc/K3_R6250.chk ]
then
   STAMP="`date +%Y-%m-%d_%H:%M`"
   mkdir -p ../../image
   cp arm-uclibc/K3_R6250.chk ../../image/dd-wrt.v3-K"$KERNELVERSION"_Netgear_R6250_"$STAMP"_r"$REVISION$EXTENDNO".chk
   echo ""
   echo ""
   echo "Image created: dd-wrt.v3-K"$KERNELVERSION"_Netgear_R6250_"$STAMP"_r"$REVISION$EXTENDNO".chk"
fi

if [ -e arm-uclibc/K3_R6300V2CH.chk ]
then
   STAMP="`date +%Y-%m-%d_%H:%M`"
   mkdir -p ../../image
   cp arm-uclibc/K3_R6300V2CH.chk ../../image/dd-wrt.v3-K"$KERNELVERSION"_Netgear_R6300V2CH_"$STAMP"_r"$REVISION$EXTENDNO".chk
   echo ""
   echo ""
   echo "Image created: dd-wrt.v3-K"$KERNELVERSION"_Netgear_R6300V2CH_"$STAMP"_r"$REVISION$EXTENDNO".chk"
fi

if [ -e arm-uclibc/K3_R6300V2.chk ]
then
   STAMP="`date +%Y-%m-%d_%H:%M`"
   mkdir -p ../../image
   cp arm-uclibc/K3_R6300V2.chk ../../image/dd-wrt.v3-K"$KERNELVERSION"_Netgear_R6300V2_"$STAMP"_r"$REVISION$EXTENDNO".chk
   echo ""
   echo ""
   echo "Image created: dd-wrt.v3-K"$KERNELVERSION"_Netgear_R6300V2_"$STAMP"_r"$REVISION$EXTENDNO".chk"
fi

if [ -e arm-uclibc/K3_R6700.chk ]
then
   STAMP="`date +%Y-%m-%d_%H:%M`"
   mkdir -p ../../image
   cp arm-uclibc/K3_R6700.chk ../../image/dd-wrt.v3-K"$KERNELVERSION"_Netgear_R6700_"$STAMP"_r"$REVISION$EXTENDNO".chk
   echo ""
   echo ""
   echo "Image created: dd-wrt.v3-K"$KERNELVERSION"_Netgear_R6700_"$STAMP"_r"$REVISION$EXTENDNO".chk"
fi

if [ -e arm-uclibc/K3_R7000.chk ]
then
   STAMP="`date +%Y-%m-%d_%H:%M`"
   mkdir -p ../../image
   cp arm-uclibc/K3_R7000.chk ../../image/dd-wrt.v3-K"$KERNELVERSION"_Netgear_R7000_"$STAMP"_r"$REVISION$EXTENDNO".chk
   echo ""
   echo ""
   echo "Image created: dd-wrt.v3-K"$KERNELVERSION"_Netgear_R7000_"$STAMP"_r"$REVISION$EXTENDNO".chk"
fi

   echo "DONE"
   echo ""
   echo "Have a look in the \"image\" directory"
   echo "and src/router/arm-uclibc directory"

cd $DEVDIR
