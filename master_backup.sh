#!/usr/bin/env bash
/usr/bin/mkdir -p /mnt/backup
/usr/bin/mount /dev/md125 /mnt/backup

rsync -av \
--delete --delete-excluded \
--exclude=/home/*/.cache/ \
--exclude=/media \
--exclude=/mnt \
--exclude=/proc \
--exclude=/run \
--exclude=/sys \
--exclude=/tmp \
--exclude=/var/tmp \
/ /mnt/backup/master/

/usr/bin/umount /mnt/backup
/usr/bin/rm -fd /mnt/backup
