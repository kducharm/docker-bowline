FROM centos:7
MAINTAINER David Numan david.numan_at_civicactions.com

RUN yum -y update; yum clean all
RUN yum -y install epel-release && yum clean all

RUN yum -y install git mysql wget sudo python-setuptools nano vim pv && \
    yum clean all

# Install php
# TODO

# Install apache
RUN yum -y install httpd mod_ssl && yum clean all

# Apache config.
#RUN sed -i 's,/var/www/html,/var/www/docroot,' /etc/httpd/conf/httpd.conf
#RUN echo "Include conf/docker-host.conf" >> /etc/httpd/conf/httpd.conf
#ADD ./conf/apache2/docker-host.conf /etc/httpd/conf/docker-host.conf

# Composer.
#RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin -d detect_unicode=0 && \
#  ln -s /usr/bin/composer.phar /usr/bin/composer

# Solution for https://bugzilla.redhat.com/show_bug.cgi?id=1020147
RUN sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers

# Set a custom entrypoint.
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
