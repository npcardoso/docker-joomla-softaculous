FROM mysql:5.6

ENV MYSQL_DATABASE=joomla

ADD backup/dump.sql /docker-entrypoint-initdb.d/
