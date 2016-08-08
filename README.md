# Minecraft Server Script
Easily control your Minecraft server in Linux


# Installation
Copy file `network.sh` to `/home/minecraft` or your user directory.

Copy and modify file `servers.cfg` to `/home/minecraft`.

Copy file `server.sh` to `/home/minecraft` or your user directory.

Then use command `ln -s /home/minecraft/server.sh /home/minecraft/Survival` to make a shortcut in each server folder in the network.

Copy and modify file `server.cfg` to `/home/minecraft/Survival` and the rest of your minecraft servers / proxies.

Note: There is a predefined a `server.cfg` file for BungeeCord servers. Just rename `server (bungee).cfg` to `server.cfg` and upload to your BungeeCord folder.

With your shell, use command `chmod +x /home/minecraft/network.sh` and `chmod +x /home/minecraft/server.sh` to mark the scripts as executable.

Also mark each of the server scripts executable. Ex: `chmod +x /home/minecraft/Survival/server.sh`

Then use command `ln -s /home/minecraft/network.sh /bin/minecraft` to make a shortcut in `/bin`.

You can now control your Minecraft server by using the simple command `minecraft`.

Then use command `ln -s /home/minecraft/network.sh /etc/init.d/minecraft` to make a shortcut in `/etc/init.d`.

Your Minecraft network is now a Linux service, you can use this to start your server automatically on reboots, etc...

Example: To start your server/network, use command `minecraft @ start` or `minecraft <group> <server> start`.

Optional Feature: Any command not handled by this script will be passed on to the minecraft server, or all servers if no server is specified.

Example: The command `minecraft server @ cmd broadcast Hello everybody!` will broadcast a message to everyone on every server saying "_Hello everybody!_"


## Start on Server Boot
### Fedora / CentOS
`chkconfig --add minecraft`
### Ubuntu / Debian
`update-rc.d minecraft defaults`


# Spigot
If you use Spigot for your Minecraft server, copy file`restart.sh` and place it in your server's root folder.

Example: `/home/minecraft/Survival`

Use command `chmod +x restart.sh` to mark the file as executable.

This will allow you to automatically start your server back up after using the `/restart` command in-game.

Note: Remember to edit your `Spigot.yml`...

Change: `restart-script: ./start.sh`
To: `restart-script: ./restart.sh`.


# Usage
Use as `minecraft <group> <server> <command>`.
* start - Start the Minecraft server
* stop - Stop the Minecraft server
* restart - Restart the Minecraft server
* status - Check the server's status (Running or not Running)
* save - Save the world (etc..)
* backup - Create an archive of the server
* cmd (mc command) - Use a Minecraft command (`ban Player123`, `say Hello`, etc...)

You can use `@` to command all servers in a group or all groups.

Ex: `minecraft server @ <command>` - Command all 'server' in server group.

Ex: `minecraft @ <command>` - Command all servers in all groups.


# Requirements
* Linux machine
* Screen
* Java
