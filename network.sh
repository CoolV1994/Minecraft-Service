#!/bin/bash
#
### SETTINGS
#
# Linux Username
USERNAME='minecraft'
# Folder base
BASE="/home/${USERNAME}"
# Server Script
SCRIPT='server.sh'
# Bungee Server
BUNGEE='Bungee'
# Minecraft Servers
SERVERS=("Survival" "Creative" "Factions")

ME=`whoami`
as_user() {
	if [ $ME == $USERNAME ] ; then
		bash -c "$1"
	else
		su - $USERNAME -c "$1"
	fi
}

mc_start() {
	sh $BASE/$BUNGEE/$SCRIPT start
	for server in ${!SERVERS[*]}
	do
		sh $BASE/${SERVERS[$server]}/$SCRIPT start
	done
}

mc_stop() {
	sh $BASE/$BUNGEE/$SCRIPT stop
	for server in ${!SERVERS[*]}
	do
		sh $BASE/${SERVERS[$server]}/$SCRIPT stop
	done
}

mc_command() {
	command="$1";
	if [ "$command" == "" ]
	then
		echo "Usage: network.sh [ start | stop | restart | status | save | backup | \"command\" | \"server\"]"
		return
	fi
	for server in ${!SERVERS[*]}
	do
		sh $BASE/${SERVERS[$server]}/$SCRIPT $command
	done
}

mc_saveall() {
	for server in ${!SERVERS[*]}
	do
		sh $BASE/${SERVERS[$server]}/$SCRIPT save
	done
}

mc_backup() {
# Backup Bungee Server?
#	as_user "sh $BASE/$BUNGEE/$SCRIPT backup"
	for server in ${!SERVERS[*]}
	do
		sh $BASE/${SERVERS[$server]}/$SCRIPT backup
	done
}

mc_status() {
	sh $BASE/$BUNGEE/$SCRIPT status
	for server in ${!SERVERS[*]}
	do
		sh $BASE/${SERVERS[$server]}/$SCRIPT status
	done
}

mc_votemsg() {
	sh $BASE/Survival/$SCRIPT votemsg
#	for server in ${!SERVERS[*]}
#	do
#		sh $BASE/${SERVERS[$server]}/$SCRIPT votemsg
#	done
}

#Start-Stop here
case "$1" in
	survival)
		sh $BASE/Survival/$SCRIPT "${*:2}"
	;;
	creative)
		sh $BASE/Creative/$SCRIPT "${*:2}"
	;;
	factions)
		sh $BASE/Factions/$SCRIPT "${*:2}"
	;;
	bungee)
		sh $BASE/$BUNGEE/$SCRIPT "${*:2}"
	;;
	start)
		mc_start
	;;
	stop)
		mc_stop
	;;
	restart)
		mc_stop
		mc_start
	;;
	save)
		mc_saveall
	;;
	backup)
		mc_saveall
		mc_command "save-off"
		mc_backup
		mc_command "save-on"
	;;
	status)
		mc_status
	;;
	votemsg)
		mc_votemsg
	;;
	*)
		mc_command "$*"
	;;
esac

exit 0