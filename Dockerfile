#/bin/bash
FROM centos:6.8

########## base config for server ##########
# -----------------------------------------------------------------------------
# PHP 5.6 repository
# -----------------------------------------------------------------------------
RUN rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm

# Supervisor to run all services
RUN yum install -y httpd

# -----------------------------------------------------------------------------
# Base Apache, PHPOrder
# -----------------------------------------------------------------------------
RUN yum -y install \
	elinks \
	mod_ssl \
	php56w \
	php56w-common \
	php56w-pdo \
	php56w-mysqlnd \
    php56w-xml \
    php56w-soap \
    php56w-intl \
    php56w-mbstring \
	php56w-cli \
	php56w-gd \
	php56w-pecl-apcu \
	php56w-pecl-memcached \
    php56w-pecl-xdebug \
    php56w-pecl-opcache \
    sendmail \
    php-pecl-xdebug \
    sudo \
	&& yum clean all
#ADD supervisord_*.ini /etc/supervisord.d/
# Added Xdebug config for SSH connections


COPY init-files/xdebug.ini /etc/php.d/xdebug.ini.join
RUN xd_file=$(php -i | grep xdebug.ini | grep -oE '/.+xdebug.ini') && \
  cat /etc/php.d/xdebug.ini.join >> ${xd_file} && \
  rm -f /etc/php.d/xdebug.ini.join

COPY httpd.conf /etc/httpd/conf/httpd.conf
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN curl -SL https://raw.githubusercontent.com/colinmollenhour/modman/master/modman -o modman \
    && chmod +x ./modman \
    && mv ./modman /usr/local/bin/

# Expose apache.
EXPOSE 80

# By default start up apache in the foreground, override with /bin/bash for interative.
CMD /usr/sbin/httpd -D FOREGROUND
