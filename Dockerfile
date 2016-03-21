# use joomla base image
FROM joomla

ENTRYPOINT /bootstrap/restore_backup.sh
