# Minecraft Server Script
Easily control your Minecraft server in Linux

# Installation
Copy file `minecraft` to `/etc/init.d`.

With your shell, use command `chmod +x /etc/init.d/minecraft` to mark the file as executable.

Then use command `ln -s /etc/init.d/minecraft /bin` to make a shortcut in `/bin`.

You can now control your Minecraft server by using the simple command `minecraft`.

Example: To start your server, use command `minecraft start`.

Use `minecraft` with no arguments for a list of commands.

Any command not handled by this script will be passed on to the minecraft server.

Example: The command `minecraft say Hello everybody!` will send a message to everyone online saying "_Hello everybody!_"

## Start on Server Boot
### Fedora / CentOS
`chkconfig --add minecraft`
### Ubuntu / Debian
`update-rc.d minecraft defaults`

# Spigot
If you use Spigot for your Minecraft server, copy file`restart.sh` and place it in your server's root folder.

Example: `/home/users/minecraft/Spigot`

Use command `chmod +x restart.sh` to mark the file as executable.

This will allow you to automatically start your server back up after using the `/restart` command in-game.

Note: Remember to edit your `Spigot.yml`...

Change: `restart-script: ./start.sh`
To: `restart-script: ./restart.sh`.

# Usage
Use as `minecraft <command>`.
* start - Start the Minecraft server
* stop - Stop the Minecraft server
* restart - Restart the Minecraft server
* status - Check the server's status (Running or not Running)
* save - Save the world (etc..)
* backup - Create an archive of the server
* `mc command` - Use a Minecraft command (`ban Player123`, `say Hello`, etc...)

# Requirements
* Linux machine
* Screen
* Java
