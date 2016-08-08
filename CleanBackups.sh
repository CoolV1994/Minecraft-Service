#!/bin/bash
#
find /home/minecraft/Backups/* -mtime +4 -print -exec rm {} \;