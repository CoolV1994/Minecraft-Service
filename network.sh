# !/bin/bash
#

# Load config
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
#SCRIPT_DIR="$(dirname "$0")"
SERVER_SETTINGS="$SCRIPT_DIR/servers.cfg"
. $SERVER_SETTINGS

# Check array for containing values
array_contains() {
	ARRAY=$#
	FIND=${!ARRAY}
	for ((I=1; I < $ARRAY; I++)) {
		if [ ${!I} == $FIND ]
		then
			return 0
		fi
	}
	return 1
}

# Validate command before passing to server scripts
command_valid() {
	COMMAND=$1
	case $COMMAND in
		start)
			return 0
		;;
		stop)
			return 0
		;;
		restart)
			return 0
		;;
		status)
			return 0
		;;
		save)
			return 0
		;;
		screen)
			return 0
		;;
		backup)
			return 0
		;;
		cmd)
			return 0
		;;
		command)
			return 0
		;;
		*)
			echo "Usage: $0 <group> <server> { start | stop | restart | status | save | screen | backup | cmd <command> }"
		;;
	esac
	return 1
}

# Execute the command
run_command() {
	DIR=$1
	COMMAND=${@:2}
	bash $BASE/$DIR/$SCRIPT $COMMAND
}

# Command 1 server
server_command() {
	GROUP=$1
	SERVER=$2
	COMMAND=${@:3}
	eval declare -A SERVERS=(${SERVER_GROUPS[$GROUP]})

	# Error: Inavlid Server
	if ! $(array_contains "${!SERVERS[@]}" "$SERVER")
	then
		echo "Server: $SERVER does not exist."
		echo "Servers:"
		for SERVER in ${!SERVERS[@]}
		do
			echo "- $SERVER"
		done
		return
	fi

	# Server Found: Run command
	SERVER_DIR=${SERVERS[$SERVER]}
	run_command $SERVER_DIR $COMMAND
}

# Command all servers
all_server_command() {
	GROUP=$1
	COMMAND=${@:2}
	eval declare -A SERVERS=(${SERVER_GROUPS[$GROUP]})
	for SERVER in ${!SERVERS[@]}
	do
		server_command $GROUP $SERVER $COMMAND
	done
}

# Error: No Arguments
if [ $# -lt 2 ]
then
	echo "Usage: $0 <group> <server> <command>"
	exit 0
fi

# Validate command before passing to server scripts
#if [ ! command_valid $3 ]
#then
#	exit 0
#fi

# Parse arguments
if [[ $1 == "@" ]]
then
	for GROUP in ${!SERVER_GROUPS[@]}
	do
		# ./network.sh @ <command>
		# All servers in all groups
		all_server_command $GROUP ${@:2}
	done
else
	# Error: Inavlid Group
	if ! $(array_contains "${!SERVER_GROUPS[@]}" "$1")
	then
		echo "Group: $1 does not exist."
		echo "Groups:"
		for GROUP in ${!SERVER_GROUPS[@]}
		do
			echo "- $GROUP"
		done
		exit 0
	fi
	# Execute command
	if [[ $2 == "@" ]]
	then
		# ./network.sh <group> @ <command>
		# All servers in 1 group
		all_server_command $1 ${@:3}
	else
		# ./network.sh <group> <server> <command>
		# 1 server in 1 group
		server_command $1 $2 ${@:3}
	fi
fi

exit 0
