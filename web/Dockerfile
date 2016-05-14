# use joomla base image
FROM joomla


# Environment
ENV ROOT_DIR /var/www/html
ENV CERTIFICATE_FILE /bootstrap/certificate.pem
ENV APACHE_DIR /etc/apache2
ENV CERTIFICATE_DEST ${APACHE_DIR}/ssl/


# Dependencies
RUN pear install pear/XML_RPC2


# Apache
ADD certificate.pem ${CERTIFICATE_DEST}
ADD apache2.conf ${APACHE_DIR}
RUN bash -c \
    "ln -s ${APACHE_DIR}/mods-available/ssl.* ${APACHE_DIR}/mods-enabled ; \
    ln -s ${APACHE_DIR}/mods-available/socache_shmcb.* ${APACHE_DIR}/mods-enabled"
RUN chmod 600 ${CERTIFICATE_DEST} -R


# Files
ADD backup ${ROOT_DIR}


# Entry Point
ADD run.sh /root/
ENTRYPOINT /root/run.sh
