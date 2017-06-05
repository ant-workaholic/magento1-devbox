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
	&& yum clean all
#ADD supervisord_*.ini /etc/supervisord.d/


COPY httpd.conf /etc/httpd/conf/httpd.conf
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN curl -SL https://raw.githubusercontent.com/colinmollenhour/modman/master/modman -o modman \
    && chmod +x ./modman \
    && mv ./modman /usr/local/bin/

# Add magento user
RUN useradd magento -u1000 && \
    usermod -G magento httpd && \
    usermod -G httpd magento



# Expose apache.
EXPOSE 80

# By default start up apache in the foreground, override with /bin/bash for interative.
CMD /usr/sbin/httpd -D FOREGROUND