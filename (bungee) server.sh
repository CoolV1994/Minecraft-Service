#!/bin/bash
#
### SETTINGS
#
# Server Name
SERVERNAME='Bungee'
# Linux Username
USERNAME='minecraft'
# Server Root Folder
MCPATH="/home/$USERNAME/$SERVERNAME"
# Server Jar File
SERVERJAR="$MCPATH/BungeeCord.jar"
# Max RAM to Allocate
RAM='1G'
# Server Java Command
INVOCATION="java -server -Xmx${RAM} -Xms1G -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=128M -jar $SERVERJAR"
# Backup Folder
BACKUPPATH="/home/$USERNAME/Backups/$SERVERNAME"

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
			echo "$SERVERJAR is now running."
		else
			echo "Could not start $SERVERJAR."
		fi
	fi
}

mc_stop() {
	if pgrep -u $USERNAME -f $SERVERJAR > /dev/null
	then
		pre_log_len=`wc -l "$MCPATH/proxy.log.0" | awk '{print $1}'`
		echo "$SERVERJAR is running. Stopping server..."
		as_user "screen -p 0 -S $SERVERNAME -X eval 'stuff \"end\"\015'"
		# Wait 10 seconds to finish stopping
		sleep 5
		# Print output
		echo "$SERVERJAR has stopped."
	else
		echo "$SERVERJAR is not running..."
	fi
}

mc_command() {
	command="$1";
	if [ "$command" == "" ]
	then
		echo "Usage: server.sh  [ start | stop | restart | status | save | backup | \"command\" ]"
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
		tail -n $[`wc -l "$MCPATH/proxy.log.0" | awk '{print $1}'`-$pre_log_len] "$MCPATH/proxy.log.0"
	else
		echo "$SERVERJAR is not running..."
	fi
}

mc_backup() {
	NOW=`date "+%Y-%m-%d_%Hh%M"`

	# Backup Server Plugins
	echo "Backing up server plugins..."
	as_user "cd $MCPATH && zip -r $BACKUPPATH/Plugins_${NOW}.zip plugins"
	echo "The plugins have been archived."

	# Backup Server Data (Config...)
	echo "Backing up server data..."
	as_user "cd $MCPATH && zip --exclude=proxy.log.* $BACKUPPATH/Server_${NOW}.zip *"
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
	backup)
		mc_backup
	;;
	status)
		mc_status
	;;
	*)
		mc_command "$*"
	;;
esac

exit 0