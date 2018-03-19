# escape=`
FROM texasaggie97/apache-php7.1

MAINTAINER Mark Silva version: 0.1

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get --yes upgrade
RUN apt-get install --yes software-properties-common gpg && `
    add-apt-repository ppa:iconnor/zoneminder
RUN apt-get update && apt-get --yes upgrade && apt-get --yes dist-upgrade
RUN apt-get install --yes zoneminder

VOLUME ["/var/run", "/var/lib/mysql"]

RUN chmod 740 /etc/zm/zm.conf && `
    chown root:www-data /etc/zm/zm.conf && `
    chown -R www-data:www-data /usr/share/zoneminder/ && `
    a2enconf zoneminder && `
    a2enmod cgi && `
    a2enmod rewrite

COPY ./zoneminder-docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/zoneminder-docker-entrypoint.sh"]

EXPOSE 80

# CMD ["/bin/bash"]
