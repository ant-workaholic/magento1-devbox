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
	php56w-devel \
	php56w-pecl-apcu \
	php56w-pecl-memcached \
    php56w-pecl-xdebug \
    php56w-pecl-opcache \
    sendmail \
    sudo \
	&& yum clean all

RUN yum install -y iproute python-setuptools hostname inotify-tools yum-utils which jq && \
  yum clean all && \
  easy_install supervisor

COPY supervisord.conf /etc/supervisord.conf

# Add magento user
RUN /usr/sbin/useradd magento -u1000 && \
    usermod -G magento apache && \
    usermod -G apache magento

# Supervisord services
COPY /init-files/supervisord_*.ini /etc/supervisord.d/

COPY httpd.conf /etc/httpd/conf/httpd.conf
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN curl -SL https://raw.githubusercontent.com/colinmollenhour/modman/master/modman -o modman \
    && chmod +x ./modman \
    && mv ./modman /usr/local/bin/

# By default start up apache in the foreground, override with /bin/bash for interative.
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]