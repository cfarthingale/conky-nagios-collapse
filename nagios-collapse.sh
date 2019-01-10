#!/bin/bash
declare -A PINGSTATUS
declare -A LOADSTATUS
declare -A SSHSTATUS
declare -A USERSTATUS
declare -A DISKSTATUS
declare -A DISKPERC
#
HOSTS=(Server0 Server1 Server2 Server3)
#
for hostyness in "${HOSTS[@]}"; do
        PINGSTATUS[$hostyness]="$(/usr/local/nagios/libexec/check_custom check-ping-fast "$hostyness")" ;
        if [ "$(echo "${PINGSTATUS[$hostyness]}"|cut -d' ' -f1)" = "CRITICAL" ];then continue; fi
        LOADSTATUS[$hostyness]="$(/usr/local/nagios/libexec/check_nrpe -H "$hostyness" -c check_load|cut -d' ' -f 1-2,7-9|cut -d'|' -f1)" ;
        SSHSTATUS[$hostyness]="$(/usr/local/nagios/libexec/check_custom check-ssh-fast "$hostyness" 32022)" ;
        USERSTATUS[$hostyness]="$(/usr/local/nagios/libexec/check_nrpe -H "$hostyness" -c check_users|cut -d' ' -f2-5)" ;
        DISKSTATUS[$hostyness]="$(/usr/local/nagios/libexec/check_nrpe -H "$hostyness" -c check_disk|cut -d' ' -f2-3,7-8)" ;
        DISKPERC[$hostyness]="$(/usr/local/nagios/libexec/check_nrpe -H "$hostyness" -c check_disk_percentage)" ;
done
#
for checkyness in "${HOSTS[@]}"; do
	echo "+ \${execbar echo ${DISKPERC[$checkyness]}} - $checkyness"
	if [ "$(echo "${PINGSTATUS[$checkyness]}"|cut -d' ' -f1)" = "WARNING" ];then
	echo " + \${color orange}${PINGSTATUS[$checkyness]}\${color}"
	fi
	if [ "$(echo "${PINGSTATUS[$checkyness]}"|cut -d' ' -f1)" = "CRITICAL" ];then
	echo " + \${color red}${PINGSTATUS[$checkyness]}\${color}"
	fi
	if [ "$(echo "${LOADSTATUS[$checkyness]}"|cut -d' ' -f1)" = "WARNING" ];then
	echo " + \${color orange}${LOADSTATUS[$checkyness]}\${color}"
	fi
	if [ "$(echo "${LOADSTATUS[$checkyness]}"|cut -d' ' -f1)" = "CRITICAL" ];then
	echo " + \${color red}${LOADSTATUS[$checkyness]}\${color}"
	fi
	if [ "$(echo "${SSHSTATUS[$checkyness]}"|cut -d' ' -f1)" = "connect" ];then
	echo " + \${color red}CRITICAL - NO SSH CONNECTION\${color}"
	fi
	if [ "$(echo "${SSHSTATUS[$checkyness]}"|cut -d' ' -f1)" = "CRITICAL" ];then
	echo " + \${color red}${SSHSTATUS[$checkyness]}\${color}"
	fi
	if [ "$(echo "${USERSTATUS[$checkyness]}"|cut -d' ' -f1)" = "WARNING" ];then
	echo " + \${color orange}${USERSTATUS[$checkyness]}\${color}"
	fi
	if [ "$(echo "${USERSTATUS[$checkyness]}"|cut -d' ' -f1)" = "CRITICAL" ];then
	echo " + \${color red}${USERSTATUS[$checkyness]}\${color}"
	fi
	if [ "$(echo "${DISKSTATUS[$checkyness]}"|cut -d' ' -f1)" = "WARNING" ];then
	echo " + \${color orange}${DISKSTATUS[$checkyness]}\${color}"
	fi
	if [ "$(echo "${DISKSTATUS[$checkyness]}"|cut -d' ' -f1)" = "CRITICAL" ];then
	echo " + \${color red}${DISKSTATUS[$checkyness]}\${color}"
	fi
done
exit 0
