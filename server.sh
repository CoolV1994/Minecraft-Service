#!/bin/bash
#
### SETTINGS
#
# Server Name
SERVERNAME='Survival'
# Linux Username
USERNAME='minecraft'
# Server Root Folder
MCPATH="/home/$USERNAME/$SERVERNAME"
# Server Jar File
SERVERJAR="$MCPATH/$SERVERNAME.jar"
# Max RAM to Allocate
RAM='2G'
# Server Java Command
INVOCATION="java -server -Xmx${RAM} -Xms1G -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=128M -jar $SERVERJAR"
# Minecraft Worlds
WORLDS=("Survival" "Survival_nether" "Survival_the_end")
# Backup Folder
BACKUPPATH="/home/$USERNAME/Backups/$SERVERNAME"
# Vote Message
VOTECMD="say Have you voted today? Use command /vote"

ME=`whoami`
as_user() {
	if [ $ME == $USERNAME ] ; then
		bash -c "$1"
	else
		su - $USERNAME -c "$1"
	fi
}

mc_start() {
	if pgrep -u $USERNAME -f $SERVERJAR > /dev/null
	then
		echo "$SERVERJAR is already running."
	else
		echo "Starting $SERVERJAR..."
		cd $MCPATH
		as_user "cd $MCPATH && screen -dmS $SERVERNAME $INVOCATION"
		# Wait 5 seconds to start up
		sleep 5
		if pgrep -u $USERNAME -f $SERVERJAR > /dev/null
		then
			# Print output
			tail -n $[`wc -l "$MCPATH/logs/latest.log" | awk '{print $1}'`] "$MCPATH/logs/latest.log"
		else
			echo "Could not start $SERVERJAR."
		fi
	fi
}

mc_stop() {
	if pgrep -u $USERNAME -f $SERVERJAR > /dev/null
	then
		pre_log_len=`wc -l "$MCPATH/logs/latest.log" | awk '{print $1}'`
		echo "$SERVERJAR is running. Stopping server..."
		as_user "screen -p 0 -S $SERVERNAME -X eval 'stuff \"stop\"\015'"
		# Wait 10 seconds to finish stopping
		sleep 10
		# Print output
		tail -n $[`wc -l "$MCPATH/logs/latest.log" | awk '{print $1}'`-$pre_log_len] "$MCPATH/logs/latest.log"
	else
		echo "$SERVERJAR is not running..."
	fi
}

mc_command() {
	command="$1";
	if [ "$command" == "" ]
	then
		echo "Usage: server.sh [ start | stop | restart | status | save | backup | \"command\" ]"
		return
	fi
	if pgrep -u $USERNAME -f $SERVERJAR > /dev/null
	then
		pre_log_len=`wc -l "$MCPATH/logs/latest.log" | awk '{print $1}'`
		echo "$SERVERJAR is running. Executing $command..."
		as_user "screen -p 0 -S $SERVERNAME -X eval 'stuff \"$command\"\015'"
		# Wait 1 second for the command to run and print to the log file
		sleep 1
		# Print output
		tail -n $[`wc -l "$MCPATH/logs/latest.log" | awk '{print $1}'`-$pre_log_len] "$MCPATH/logs/latest.log"
	else
		echo "$SERVERJAR is not running..."
	fi
}

mc_saveall() {
	if pgrep -u $USERNAME -f $SERVERJAR > /dev/null
	then
		echo "$SERVERJAR is running. Saving the world..."
		# Save the World
		as_user "screen -p 0 -S $SERVERNAME -X eval 'stuff \"save-all\"\015'"
		# Say World saved.
		as_user "screen -p 0 -S $SERVERNAME -X eval 'stuff \"say World saved.\"\015'"
		# Save WorldGuard Regions
		as_user "screen -p 0 -S $SERVERNAME -X eval 'stuff \"region save\"\015'"
		sync
		# Wait 10 seconds to finish saving
		sleep 10
		echo "World saved."
	else
		echo "$SERVERJAR was not running. Noting to save."
	fi
}

mc_backup() {
	NOW=`date "+%Y-%m-%d_%Hh%M"`

	# Backup Server World
	for world in ${!WORLDS[*]}
	do
		echo "Backing up world ${WORLDS[$world]}..."
		as_user "cd $MCPATH && zip -r $BACKUPPATH/${WORLDS[$world]}_${NOW}.zip ${WORLDS[$world]}"
		echo "${WORLDS[$world]} has been archived."
	done

	# Backup Server Plugins
	echo "Backing up server plugins..."
	as_user "cd $MCPATH && zip -r --exclude=plugins/dynmap/web/tiles/* $BACKUPPATH/Plugins_${NOW}.zip plugins"
	echo "The plugins have been archived."

	# Backup Server Data (Bans, White-list, etc...)
	echo "Backing up server data..."
	as_user "cd $MCPATH && zip $BACKUPPATH/Server_${NOW}.zip *"
	echo "The server data has been archived."

	echo "Server backup complete."
}

mc_status() {
	if pgrep -u $USERNAME -f $SERVERJAR > /dev/null
	then
		echo "$SERVERJAR is running."
	else
		echo "$SERVERJAR is not running."
	fi
}

#Start-Stop here
case "$1" in
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
	spigot-restart)
		# Wait 30 seconds for the server to fully stop then start again
		sleep 30
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
		mc_command $VOTECMD
	;;
	*)
		mc_command "$*"
	;;
esac

exit 0