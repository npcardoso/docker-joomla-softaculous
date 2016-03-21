Docker Joomla Akeeba Backup
======

This repository contains an environment for easily booting a Joomla Backup.

## Restoring a backup

To restore a backup, copy the tar.gz file onto the "backup" directory.
Either rename the file to "backup.tar.gz" or change the corresponding
environment in the "environment.sh" file.

You can start the containers by running:

```
docker-compose build
docker-compose run
```

Once the container is running you will get a joomla website on
http://localhost/ or https://localhost/ (self-signed certificate).
