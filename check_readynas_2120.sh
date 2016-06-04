#!/bin/bash

##
#
# receive statusinfo from Netgear ReadyNAS 2100 for Nagios
#
# you can get all snmp-options with:
#   snmpwalk -m ALL -v 2c -c MYCOMMUNITY MYIPADDRESS  .1.3.6.1.4.1.4526
#
#
# Usage: 
#  ./check_readynas_2120.sh IP-ADDRESS SNMP-COMMUNITY STATUSCHECK
#
#based in script by Jan Toenjes <jtoenje@uni-goettingen.de>
#
##


# temperature values for warning or critical / hdd (from datasheet)
MAXDISKTEMPCRIT="60"
MINDISKTEMPCRIT="5"
MAXDISKTEMPWARN="50"
MINDISKTEMPWARN="15"

# unused systemtemperature values for warning or critical / (from webinterface)
MAXSYSTEMPCRIT="65"
MINSYSTEMPCRIT="0"
MAXSYSTEMPWARN="55"
MINSYSTEMPWARN="10"


# nagios return values
export STATE_OK=0
export STATE_WARNING=1
export STATE_CRITICAL=2
export STATE_UNKNOWN=3  
export STATE_DEPENDENT=4
                                        

# check disk temperature for warning or critical values
function checkDiskTemperature () {

	true=$(echo "$1 >= $MAXDISKTEMPWARN" | bc)
		if [ $true = 1 ] ; then
			returnValue=$STATE_WARNING ;
		fi
		
	true=$(echo "$1 >= $MAXDISKTEMPCRIT" | bc)
		if [ $true = 1 ] ; then
			returnValue=$STATE_CRITICAL ;
		fi
		
	true=$(echo "$1 <= $MINDISKTEMPWARN" | bc)
		if [ $true = 1 ] ; then
			returnValue=$STATE_WARNING ;
		fi
		  
	true=$(echo "$1 <= $MINDISKTEMPCRIT" | bc)
		if [ $true = 1 ] ; then
			returnValue=$STATE_CRITICAL ;
		fi
	return $returnValue
}


# check third parameter and return the information
case "$3" in
	disk1status)
		#DSK1=` snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.3.1.2.1 | sed 's/.*ING: " //g' | sed 's/"//g'`
		DSK1=` snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.3.1.2.1 | awk '{print $4}'`
		#DSK1STAT=`snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.3.1.9.1 | sed 's/.*ING: "//g' | sed 's/"//g'`
		DSK1STAT=`snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.3.1.9.1 | awk '{print $4}'`
		if [ $DSK1STAT == "\""ONLINE"\"" ]; then
		  intReturn=$STATE_OK
		else
		  intReturn=$STATE_WARNING
		fi

		outMessage="Disk1: $DSK1 - $DSK1STAT"
	;;


	disk2status)
		DSK2=` snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.3.1.2.2 | awk '{print $4}'`
		DSK2STAT=`snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.3.1.9.2 | awk '{print $4}'`

		if [ $DSK2STAT == "\""ONLINE"\"" ]; then
		  intReturn=$STATE_OK
		else
		  intReturn=$STATE_WARNING
		fi	

		outMessage="Disk2: $DSK2 - $DSK2STAT"
	;;


	disk3status)
		DSK3=` snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.3.1.2.3 | awk '{print $4}'`	
		DSK3STAT=`snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.3.1.9.3 | awk '{print $4}'`
	
		if [ $DSK3STAT == "\""ONLINE"\"" ]; then
		  intReturn=$STATE_OK
		else
		  intReturn=$STATE_WARNING
		fi

		outMessage="Disk3: $DSK3 - $DSK3STAT"
	;;


	disk4status)
		DSK4=` snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.3.1.2.4 | awk '{print $4}'`
		DSK4STAT=`snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.3.1.9.4 | awk '{print $4}'`
	
		if [ $DSK4STAT == "\""ONLINE"\"" ]; then
		  intReturn=$STATE_OK
		else
		  intReturn=$STATE_WARNING
		fi	
		
		outMessage="Disk4: $DSK4 - $DSK4STAT"
	;;	


	disk1temp)
		#DSK1TEMP=`snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.3.1.5.1 | awk '{print $4}'`
		#DSK1CEL=`echo "scale=2;(5/9)*($DSK1TEMP-32)"|bc`
		DSK1CEL=`snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.3.1.10.1 | awk '{print $4}'`
		
		checkDiskTemperature $DSK1CEL
		intReturn=$?
		outMessage="Disk1: $DSK1CEL Celsius | 'disk1'=$DSK1CEL" ;
	;;


	disk2temp)
		#DSK2TEMP=`snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.3.1.5.2 | awk '{print $4}'`
		#DSK2CEL=`echo "scale=2;(5/9)*($DSK2TEMP-32)"|bc`
		DSK2CEL=`snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.3.1.10.2 | awk '{print $4}'`
                checkDiskTemperature $DSK2CEL
		intReturn=$?
		outMessage="Disk2: $DSK2CEL Celsius | 'disk2'=$DSK2CEL"
	;;


	disk3temp)
		#DSK3TEMP=`snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.3.1.5.3 | awk '{print $4}'`
		#DSK3CEL=`echo "scale=2;(5/9)*($DSK3TEMP-32)"|bc`
		DSK3CEL=`snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.3.1.10.3 | awk '{print $4}'`
                checkDiskTemperature $DSK3CEL
		intReturn=$?
		outMessage="Disk3: $DSK3CEL Celsius | 'disk3'=$DSK3CEL"
	;;


	disk4temp)
		#DSK4TEMP=`snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.3.1.5.4 | awk '{print $4}'`
		#DSK4CEL=`echo "scale=2;(5/9)*($DSK4TEMP-32)"|bc`
		DSK4CEL=`snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.3.1.10.4 | awk '{print $4}'`
                checkDiskTemperature $DSK4CEL
		intReturn=$?
		outMessage="Disk4: $DSK4CEL Celsius | 'disk4'=$DSK4CEL"
	;;	

	fan1)
		FAN1=`snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.4.1.2.1 |  awk '{print $4}'`
		intReturn=$STATE_OK
		outMessage="Fan1: $FAN1 | 'speed1'=$FAN1"
	;;


	fan2)
		FAN2=`snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.4.1.2.2 |  awk '{print $4}'`
		intReturn=$STATE_OK
		outMessage="Fan2: $FAN2 | 'speed2'=$FAN2"
	;;	
	
        systemp)
		SYSTEMP=`snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.5.1.2.1 | awk '{print $4}'`
		SYSCEL=`echo "scale=2;(5/9)*($SYSTEMP-32)"|bc`
		SYSCELINT=`echo $SYSCEL | cut -c1-2`
		SYSTEMPOK=`snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.5.1.3.1 | sed 's/.*ING: "//g' | sed 's/"//g'`
		#if [ $SYSTEMPOK == "ok" ]; then
		if [ $SYSCELINT -lt "35" ]; then
		  intReturn=$STATE_OK
		else
		  intReturn=$STATE_WARNING
		fi	
		outMessage="System Temperature: $SYSCEL°C - $SYSTEMPOK | 'sys_temp'=$SYSCELINT "
	;;	


	raidstatus)
		RAID=` snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.7.1.3.1 | awk '{print $4}' | sed 's/"//g'`
		RAIDSTAT=`snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.7.1.4.1 | awk '{print $4}' | sed 's/"//g'`

		if [ $RAIDSTAT == "REDUNDANT" ]; then
		  intReturn=$STATE_OK
		else
		  intReturn=$STATE_WARNING
		fi	

		outMessage="RAID: $RAID - $RAIDSTAT"
	;;

	freespace)
		SPACE=` snmpget $1 -v2c -c $2 .1.3.6.1.4.1.4526.22.7.1.5.1 | awk '{print $4}'`
		intReturn=$STATE_OK
		MB=`echo "scale=2; $SPACE/1024" | bc`
		outMessage="Free Space: $MB mb | 'space'=$MB"
	;;		                                                                

	*)
		intReturn=$STATE_OK
		outMessage="  Usage: $0 IPADDRESS SNMPCOMMUNITY STATUS \n \n  Available statuses are: \n\n    disk1status|disk2status|disk3status|disk4status \n    disk1temp|disk2temp|disk3temp|disk4temp \n    fan1|fan2 \n    systemp \n    raidstatus \n    freespace"

	;;
esac


echo -e $outMessage
exit $intReturn
