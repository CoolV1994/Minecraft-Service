# !/bin/bash
#

# Load config
#SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
SCRIPT_DIR="$(dirname "$0")"
SERVER_SETTINGS="$SCRIPT_DIR/server.cfg"
. $SERVER_SETTINGS

# Run as designated user
ME=`whoami`
as_user() {
	if [ $ME == $SERVER_USER ]
	then
		bash -c "$1"
	else
		sudo -u $SERVER_USER bash -c "$1"
	fi
}

# Check if server is running
is_running() {
	if pgrep -u $SERVER_USER -f $SERVER_JAR > /dev/null
	then
		return 0
	else
		return 1
	fi
}

server_start() {
	if is_running
	then
		echo "$SERVER_NAME is already running."
	else
		echo "Starting $SERVER_NAME..."
		PRE_LOG_LENGTH=`wc -l "$LOG_FILE" | awk '{print $1}'`
		INVOCATION="$SERVER_EXE $SERVER_PARAMS"
		as_user "cd $SERVER_DIR && screen -dmS $SCREEN_NAME $INVOCATION"
		sleep $START_TIME
		if is_running
		then
			echo "$SERVER_NAME is now running."
		else
			echo "Could not start $SERVER_NAME."
		fi
		# Print output
		CURRENT_LOG_LENGTH=`wc -l "$LOG_FILE" | awk '{print $1}'`
		tail -n $((CURRENT_LOG_LENGTH-PRE_LOG_LENGTH)) "$LOG_FILE"
	fi
}

server_stop() {
	if is_running
	then
		echo "$SERVER_NAME is running. Stopping server..."
		server_command $STOP_COMMAND
		sleep $STOP_TIME
		if is_running
		then
			echo "$SERVER_NAME is still running."
		else
			echo "$SERVER_NAME has stopped."
		fi
	else
		echo "$SERVER_NAME is not running."
	fi
}

server_status() {
	if is_running
	then
		echo "$SERVER_NAME is running."
	else
		echo "$SERVER_NAME is not running."
	fi
}

server_command() {
	COMMAND=$*
	if [ -z "$COMMAND" ]
	then
		# Show full command usage when for no args when sending server commands by default
		#echo "Usage: $0 { start | stop | restart | status | save | screen | backup | cmd <command> }"
		echo "Usage: $0 cmd <command>"
		return
	fi
	if is_running
	then
		echo "$SERVER_NAME is running. Executing $COMMAND..."
		PRE_LOG_LENGTH=`wc -l "$LOG_FILE" | awk '{print $1}'`
		as_user "screen -p 0 -S $SCREEN_NAME -X eval 'stuff \"$COMMAND\"\015'"
		sleep $COMMAND_TIME
		# Print output
		CURRENT_LOG_LENGTH=`wc -l "$LOG_FILE" | awk '{print $1}'`
		tail -n $((CURRENT_LOG_LENGTH-PRE_LOG_LENGTH)) "$LOG_FILE"
	else
		echo "$SERVER_NAME is not running."
	fi
}

server_save() {
	for CMD in ${!SAVE_COMMANDS[*]}
	do
		server_command ${SAVE_COMMANDS[$CMD]}
	done
}

server_screen() {
	if is_running
	then
		as_user "screen -p 0 -S $SCREEN_NAME -r"
	else
		echo "$SERVER_NAME is not running."
	fi
}

server_backup() {
	# Save server
	server_save
	# Disable saving
	for CMD in ${!SAVE_DISABLE_COMMANDS[*]}
	do
		server_command ${SAVE_DISABLE_COMMANDS[$CMD]}
	done
	# Archive files
	for FILE in ${!BACKUP[*]}
	do
		ARGS=${BACKUP[$FILE]}
		echo "Backing up $FILE..."
		as_user "cd $SERVER_DIR && 7za a $BACKUP_DIR/${FILE}_${BACKUP_TIME}.zip $ARGS"
		echo "$FILE has been archived."
	done
	# Re-enable saving
	for CMD in ${!SAVE_ENABLE_COMMANDS[*]}
	do
		server_command ${SAVE_ENABLE_COMMANDS[$CMD]}
	done
	echo "Server backup complete."
}

case $1 in
	start)
		server_start
	;;
	stop)
		server_stop
	;;
	restart)
		server_stop
		server_start
	;;
	status)
		server_status
	;;
	save)
		server_save
	;;
	screen)
		server_screen
	;;
	cmd)
		server_command ${@:2}
	;;
	command)
		server_command ${@:2}
	;;
	spigot-restart)
		sleep $SPIGOT_RESTART_TIME
		server_start
	;;
	backup)
		server_backup
	;;
	*)
		# Optional: pass command to server by default
		#server_command $*
		echo "Usage: $0 { start | stop | restart | status | save | screen | backup | cmd <command> }"
	;;
esac

exit 0
