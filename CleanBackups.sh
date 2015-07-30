#!/bin/bash
#
find /home/gawd/Backups/* -mtime +4 -print -exec rm {} \;