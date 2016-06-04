#!/bin/bash

##########CONFIG SECTION ##############
#el host debe ser expresado como fqdn
HOST=$1
#credenciales a usar para autentificar
MW_LOGIN="admin"
MW_PASSWD="password"
cores=4 
#pagina (con subpaginas) a parsear
MAIN_PAGE="http://$HOST:81/sysinfo/"

########END  CONFIG SECTION ##########

#esto se hace de esta manera o sino la pagina devuuelve error 500 no cookies. DON'T TOUCH.
MAIN_PAGE_LOGIN_1PASS="http://$HOST:81/session_login.cgi"
MAIN_PAGE_LOGIN_2PASS="http://$HOST:81/session_login.cgi?user=$MW_LOGIN"
MAIN_PAGE_LOGIN_3PASS="http://$HOST:81/session_login.cgi?user=$MW_LOGIN&pass=$MW_PASSWD"

#donde guardo la cookie
PATH_FILE_COOKIE=/tmp/cookies.txt

#user agent para que me deje cojer las cookies DON'T TOUCH
useragent="Mozilla/5.0 (X11; Linux amd64; rv:32.0b4) Gecko/20140804164216 ArchLinux KDE Firefox/32.0b4"

#autentificacion y cojer cookies y session
#esto se hace de esta manera o sino la pagina devuuelve error 500 no cookies. DON'T TOUCH.
wget -U "$useragent" --load-cookies $PATH_FILE_COOKIE --save-cookies $PATH_FILE_COOKIE --keep-session-cookies "$MAIN_PAGE_LOGIN_1PASS" -k -e robots=off -O /dev/null
wget -U "$useragent" --load-cookies $PATH_FILE_COOKIE --save-cookies $PATH_FILE_COOKIE --keep-session-cookies "$MAIN_PAGE_LOGIN_2PASS" -k -e robots=off -O /dev/null
wget -U "$useragent" --load-cookies $PATH_FILE_COOKIE --save-cookies $PATH_FILE_COOKIE --keep-session-cookies "$MAIN_PAGE_LOGIN_3PASS" -k -e robots=off -O /dev/null

#cat cookies.txt

#obtengo la URL para luego Parsearla
cd /tmp
wget "$MAIN_PAGE" --recursive --level=1 --no-parent --page-requisites --restrict-file-names=windows --cut-dirs=2 --html-extension --convert-links --keep-session-cookies --reject sali* --load-cookies $PATH_FILE_COOKIE

#el comando a comprobar
COMMAND=$2
#valor en % de warning
WARNING=$3
#valor en % de critical
CRITICAL=$4
# solo para check de cpu, numero de cores que tiene la maquina.



cpu1=$(grep mainbody /tmp/$HOST+81/index.html |grep -viE 'running|CabildoT1A|BytePass' | sed 's/<[^>]\+>//g' | cut -f1,2 | grep "for the last minute" | awk '{print $5}')
cpu5=$(grep mainbody /tmp/$HOST+81/index.html |grep -viE 'running|CabildoT1A|BytePass' | sed 's/<[^>]\+>//g' | cut -f1,2 | grep "for the last 5 minutes" | awk '{print $6}')
cpu15=$(grep mainbody /tmp/$HOST+81/index.html |grep -viE 'running|CabildoT1A|BytePass' | sed 's/<[^>]\+>//g' | cut -f1,2 | grep "for the last 15 minutes" | awk '{print $6}')



filesystemroot=$(grep mainbody /tmp/$HOST+81/index.html |grep -viE 'running|CabildoT1A|BytePass' | sed 's/<[^>]\+>//g' | cut -f1,2 | grep "LogVolrootvol" | awk '{print $1}')
filesystem=$(grep mainbody /tmp/$HOST+81/index.html |grep -viE 'running|CabildoT1A|BytePass' | sed 's/<[^>]\+>//g' | cut -f1,2 | grep "LogVolobsuser" | awk '{print $1}')


filesystemrootspacetotal=$(grep mainbody /tmp/$HOST+81/index.html |grep -viE 'running|CabildoT1A|BytePass' | sed 's/<[^>]\+>//g' | cut -f1,2 | grep "LogVolrootvol" | awk '{print $2}')
filesystemrootspacetotalraw=$(grep mainbody /tmp/$HOST+81/index.html |grep -viE 'running|CabildoT1A|BytePass' | sed 's/<[^>]\+>//g' | grep "LogVolrootvol" | awk '{print $2}'| sed 's/G//g' )
filesystemrootspaceused=$(grep mainbody /tmp/$HOST+81/index.html |grep -viE 'running|CabildoT1A|BytePass' | sed 's/<[^>]\+>//g' | cut -f1,2 | grep "LogVolrootvol" | awk '{print $3}')
filesystemrootspaceusedraw=$(grep mainbody /tmp/$HOST+81/index.html |grep -viE 'running|CabildoT1A|BytePass' | sed 's/<[^>]\+>//g' | grep "LogVolrootvol" | awk '{print $3}' | sed 's/G//g' )



filesystemspacetotal=$(grep mainbody /tmp/$HOST+81/index.html |grep -viE 'running|CabildoT1A|BytePass' | sed 's/<[^>]\+>//g' | cut -f1,2 | grep "LogVolobsuser" | awk '{print $2}')
filesystemspacetotalraw=$(grep mainbody /tmp/$HOST+81/index.html |grep -viE 'running|CabildoT1A|BytePass' | sed 's/<[^>]\+>//g' | cut -f1,2 | grep "LogVolobsuser" | awk '{print $2}'| sed 's/T//g')
filesystemspaceused=$(grep mainbody /tmp/$HOST+81/index.html |grep -viE 'running|CabildoT1A|BytePass' | sed 's/<[^>]\+>//g' | cut -f1,2 | grep "LogVolobsuser" | awk '{print $3}')
filesystemspaceusedraw=$(grep mainbody /tmp/$HOST+81/index.html |grep -viE 'running|CabildoT1A|BytePass' | sed 's/<[^>]\+>//g' | cut -f1,2 | grep "LogVolobsuser" | awk '{print $3}' | sed 's/T//g')


memorytotal=$(grep mainbody /tmp/$HOST+81/memory.cgi.html |grep -viE 'running|CabildoT1A|BytePass' | sed 's/<[^>]\+>//g' | grep "Main memory" | awk '{print $3}')
memoryused=$(grep mainbody /tmp/$HOST+81/memory.cgi.html |grep -viE 'running|CabildoT1A|BytePass' | sed 's/<[^>]\+>//g' | grep "Main memory" | awk '{print $4}')
memoryfree=$(grep mainbody /tmp/$HOST+81/memory.cgi.html |grep -viE 'running|CabildoT1A|BytePass' | sed 's/<[^>]\+>//g' | grep "Main memory" | awk '{print $5}')

if [ $COMMAND == "check_root_disk" ]
	then

	#calculo el porcentaje y dejo solo la parte entera con decimales
	 porcentaje=$(echo "scale = 2; $filesystemrootspaceusedraw*100/$filesystemrootspacetotalraw" | bc|cut -d"." -f1)
	perfdatarootdisk="'usado'=$filesystemrootspaceusedraw;"
        if [[ $porcentaje -gt $CRITICAL ]];
        then
               
		echo "CRITICAL! $filesystemroot al $porcentaje% |$perfdatarootdisk"
		exit 2
        else
        	if [[ $porcentaje -gt $WARNING ]]
               then
			echo "WARNING! $filesystemroot al $porcentaje% |$perfdatarootdisk"
 			exit 1
                else
                        echo "OK  $filesystemroot al $porcentaje% |$perfdatarootdisk"
 			exit 0
                 fi
         fi
 fi
 if [ "$COMMAND" == "check_user_disk" ]
	then

	#calculo el porcentaje y dejo solo la parte entera con decimales
	 porcentaje=$(echo "scale = 2; $filesystemspaceusedraw*100/$filesystemspacetotalraw" | bc|cut -d"." -f1)
	perfdatauserdisk="'usado'=$filesystemspaceusedraw;"
        if [[ $porcentaje -gt $CRITICAL ]]
        then
               
		echo "CRITICAL! $filesystem al $porcentaje% |$perfdatauserdisk"
		exit 2
        else
        	if [[ $porcentaje -gt $WARNING ]]
               then
			echo "WARNING! $filesystem al $porcentaje% |$perfdatauserdisk"
 			exit 1
                else
                        echo "OK $filesystem al $porcentaje% |$perfdatauserdisk"
 			exit 0
                 fi
         fi
 fi

 if [ $COMMAND == "check_mem" ]
	then
	
	#calculo el porcentaje y dejo solo la parte entera con decimales
	 porcentaje=$(echo "scale = 2; $memoryused*100/$memorytotal" | bc|cut -d"." -f1)
	perfdatamem="'mem'=$memoryused;"
        if [[ $porcentaje -gt $CRITICAL ]]
        then
               
		echo "CRITICAL! Memoria al $porcentaje% |$perfdatamem"
		exit 2
        else
        	if [[ $porcentaje -gt $WARNING ]]
               then
			echo "WARNING! Memoria al $porcentaje% |$perfdatamem"
 			exit 1
                else
                        echo "OK! Memoria al $porcentaje% |$perfdatamem"
 			exit 0
                 fi
         fi
 fi

if [ $COMMAND == "check_cpu" ]

	then
	#calculo el porcentaje y dejo solo la parte entera con decimales
	porcentajecpu1=$(echo "scale = 2; $cpu1*100/$cores" | bc|cut -d"." -f1)
	porcentajecpu5=$(echo "scale = 2; $cpu5*100/$cores" | bc|cut -d"." -f1)
	porcentajecpu15=$(echo "scale = 2; $cpu15*100/$cores" | bc|cut -d"." -f1)
	#printf "\n\n\n"
	perfdatacpu1="'cpu1'=$porcentajecpu1;"
	perfdatacpu5="'cpu5'=$porcentajecpu5;"
	perfdatacpu15="'cpu15'=$porcentajecpu15;"
        if [ $porcentajecpu1 -gt $CRITICAL ] || [ $porcentajecpu5 -gt $CRITICAL ]||[$porcentajecpu15 -gt $CRITICAL ]
        then
               
		echo "CRITICAL! cpu1:$porcentajecpu1% cpu5:$porcentajecpu5% cpu15:$porcentajecpu15% |$perfdatacpu1 $perfdatacpu5 $perfdatacpu15"
		exit 2
        else
        	if [ $porcentajecpu1 -gt $WARNING ] || [ $porcentajecpu5 -gt $WARNING ]||[$porcentajecpu15 -gt $WARNING ]
               then
			echo "WARNING!  cpu1:$porcentajecpu1% cpu5:$porcentajecpu5% cpu15:$porcentajecpu15% |$perfdatacpu1 $perfdatacpu5 $perfdatacpu15" 
 			exit 1
                else
                        echo "OK! cpu1:$porcentajecpu1% cpu5:$porcentajecpu5% cpu15:$porcentajecpu15% |$perfdatacpu1 $perfdatacpu5 $perfdatacpu15"
 			exit 0
                 fi
         fi
 fi 
 
