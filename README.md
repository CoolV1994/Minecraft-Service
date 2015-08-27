# Minecraft Server Script
Easily control your Minecraft server in Linux

# Installation (1 Server)
Copy file `server.sh` your server folder. Ex: `/home/minecraft/Survival`

With your shell, use command `chmod +x /home/minecraft/Survival/server.sh` to mark the file as executable.

Then use command `ln -s /home/minecraft/Survival/server.sh /bin/minecraft` to make a shortcut in /bin.

You can now control your Minecraft server by using the simple command `minecraft`.

Then use command `ln -s /home/minecraft/Survival/server.sh /etc/init.d/minecraft` to make a shortcut in `/etc/init.d`.

Your Minecraft network is now a Linux service, you can use this to start your server automatically on reboots, etc...

Example: To start your server, use command `minecraft start`.

Use `minecraft` with no arguments for a list of commands.

Any command not handled by this script will be passed on to the minecraft server.

Example: The command `minecraft say Hello everybody!` will send a message to everyone online saying "_Hello everybody!_"

# Installation (Multiple Servers)
> ## Recommendations
> It is recommended that you create a seperate folder to store your Spigot.jar, and plugin jars.

> Then by using shortcuts, create a link for each Jar to its respective folder.

> This will allow you to simplify things such as updating plugins, and will help save HDD space.

Copy file `network.sh` to `/home/minecraft` or your user directory.

Copy file `server.sh` to each server folder in the network. Ex: `/home/minecraft/Survival`

Copy file `(bungee) server.sh` to your BungeeCord folder. Ex: `/home/minecraft/Bungee`

With your shell, use command `chmod +x /home/minecraft/network.sh` to mark the file as executable.

Also mark each of the server scripts executable. Ex: `chmod +x /home/minecraft/Survival/server.sh`

Then use command `ln -s /home/minecraft/network.sh /bin/minecraft` to make a shortcut in `/bin`.

You can now control your Minecraft server by using the simple command `minecraft`.

Then use command `ln -s /home/minecraft/network.sh /etc/init.d/minecraft` to make a shortcut in `/etc/init.d`.

Your Minecraft network is now a Linux service, you can use this to start your server automatically on reboots, etc...

Example: To start your server/network, use command `minecraft start` or `minecraft <server> start`.

Use `minecraft` with no arguments for a list of commands.

Any command not handled by this script will be passed on to the minecraft server, or all servers if no server is specified.

Example: The command `minecraft say Hello everybody!` will send a message to everyone on every server saying "_Hello everybody!_"

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
