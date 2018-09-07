#!/bin/bash

apt-get update
apt-get upgrade -y

source /boot/pi-router.txt

 run () {
                    number=$1
                    shift
                    for i in `seq $number`; do
                      $@
                    done
}

PersistantInterfaceNames () {
        WAN () {
                WANINTERFACE=$( ifconfig | grep -v "lo" | grep "RUNNING" | awk '{print $1}' | cut -d':' -f1)
                WANMAC=$(cat /sys/class/net/"$WANINTERFACE"/address)
                echo 'SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="$WANMAC", ATTR{dev_id}=="0x0", ATTR{type}=="1", KERNEL=="eth*", NAME="$
        }
        WLAN () {
                local TEMP
                local WLANMACARRAY
                local ARRAY
                local WLANNUM
                WLANMAC=$(cat /sys/class/net/w*/address)
                TEMP=$(mktemp)
                echo $WLANMAC > $TEMP
                WLANMACARRAY=$(sed ':a;N;$!ba;s/\n/ /g' $TEMP)
                declare -a ARRAY=($WLANMACARRAY)
                WLANNUM=$(echo "$WLANMACARRAY" | wc -w)
        PersistantNames (){
                        (( NUM = $i - 1 ))
                        echo '"SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="${ARRAY[$NUM]}", ATTR{dev_id}=="0x0", ATTR{type}=="1", KERNEL$
                }
                run $WLANNUM AddPersistantNames
        }
}

CreateLan () {
        ip link add LAN type bridge
        LANCONFORIG=$(cat /etc/pi-router/config/LAN)
        echo "$LANCONFORIG" > /etc/network/interfaces.d/LAN
}

SetIPs () {
        WLAN () {
                local TEMP
                WLANINTERFACES=$(ls /sys/class/net | grep -v "lo" | grep -v "e")
                TEMP=$(mktemp)
                echo $WLANINTERFACES > $TEMP
                WLANINTERFACEARRAY=$(sed ':a;N;$!ba;s/\n/ /g' $TEMP)
                declare -a ARRAY=($WLANINTERACEARRAY)
                WLANI
        }
        WAN () {
                if [[ $WANSTATIC = 1 ]]; then
                        WANCONF=$(cat /etc/pi-router/config/WANStatic
                else
                        WANCONF=$(cat /etc/pi-router/config/DHCP)
                fi
                echo "$WANCONF" > /etc/network/interfaces.d/WAN
        }

}