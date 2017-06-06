#/bin/bash
FROM centos:7

########## base config for server ##########
# -----------------------------------------------------------------------------
# PHP 5.6 repository
# -----------------------------------------------------------------------------
ENV LC_ALL en_US.UTF-8
#Add repos
RUN yum update -y \
  && rpm -U https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
  # define locale
  && localedef -c -f UTF-8 -i en_US en_US.UTF-8 \
  # Supervisor to run all services
  && yum install -y supervisor \
  # Git
  && rpm -U http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-2.noarch.rpm \
  && yum install -y git



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


# Add magento user
RUN /usr/sbin/useradd magento -u1000 && \
    usermod -G magento apache && \
    usermod -G apache magento


COPY httpd.conf /etc/httpd/conf/httpd.conf
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN curl -SL https://raw.githubusercontent.com/colinmollenhour/modman/master/modman -o modman \
    && chmod +x ./modman \
    && mv ./modman /usr/local/bin/



# Expose apache.
EXPOSE 80

# By default start up apache in the foreground, override with /bin/bash for interative.
CMD /usr/sbin/httpd -D FOREGROUND
