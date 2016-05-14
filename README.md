Docker Joomla Softaculous Backup Restoring Container
======

This repository contains an environment for easily booting a Joomla backup.

## Restoring a backup

You can restore a backup by running:

```
./restore.sh <backup.tar.gz>
```

Once the container is running you will get a joomla website on
http://localhost/ or https://localhost/ (self-signed certificate).
