FROM ubuntu:16.04
MAINTAINER Samuele Bistoletti <samuele.bistoletti@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

# Default versions
ENV TELEGRAF_VERSION 1.8.3-1
ENV INFLUXDB_VERSION 1.7.0
ENV GRAFANA_VERSION  5.3.2
ENV CHRONOGRAF_VERSION 1.7.2

# Database Defaults
ENV INFLUXDB_GRAFANA_DB datasource
ENV INFLUXDB_GRAFANA_USER datasource
ENV INFLUXDB_GRAFANA_PW datasource

ENV MYSQL_GRAFANA_USER grafana
ENV MYSQL_GRAFANA_PW grafana

# Fix bad proxy issue
COPY system/99fixbadproxy /etc/apt/apt.conf.d/99fixbadproxy

# Clear previous sources
RUN rm /var/lib/apt/lists/* -vf

# Base dependencies
RUN apt-get -y update && \
 apt-get -y dist-upgrade && \
 apt-get -y --force-yes install \
  apt-utils \
  ca-certificates \
  curl \
  git \
  htop \
  libfontconfig \
  mysql-client \
  mysql-server \
  nano \
  net-tools \
  openssh-server \
  supervisor \
  mosquitto mosquitto-clients \
  wget && \
 curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
 apt-get install -y nodejs

# Install InfluxDB
RUN wget https://dl.influxdata.com/influxdb/releases/influxdb_${INFLUXDB_VERSION}_amd64.deb && \
	dpkg -i influxdb_${INFLUXDB_VERSION}_amd64.deb && rm influxdb_${INFLUXDB_VERSION}_amd64.deb

# Install Telegraf
RUN wget https://dl.influxdata.com/telegraf/releases/telegraf_${TELEGRAF_VERSION}_amd64.deb && \
	dpkg -i telegraf_${TELEGRAF_VERSION}_amd64.deb && rm telegraf_${TELEGRAF_VERSION}_amd64.deb

# Install chronograf
RUN wget https://dl.influxdata.com/chronograf/releases/chronograf_${CHRONOGRAF_VERSION}_amd64.deb && \
  dpkg -i chronograf_${CHRONOGRAF_VERSION}_amd64.deb

# Install Grafana
RUN wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_${GRAFANA_VERSION}_amd64.deb && \
	dpkg -i grafana_${GRAFANA_VERSION}_amd64.deb && rm grafana_${GRAFANA_VERSION}_amd64.deb

# Cleanup
RUN apt-get clean && \
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Configure Mosquitto
RUN mkdir -p /mqtt/config /mqtt/data /mqtt/log
COPY mosquitto /mqtt/config
RUN chown -R mosquitto:mosquitto /mqtt
VOLUME ["/mqtt/config", "/mqtt/data", "/mqtt/log"]




# Configure Supervisord, SSH and base env
COPY supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /root

RUN mkdir -p /var/log/supervisor && \
    mkdir -p /var/run/sshd && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo 'root:root' | chpasswd && \
    rm -rf .ssh && \
    rm -rf .profile && \
    mkdir .ssh

COPY ssh/id_rsa .ssh/id_rsa
COPY bash/profile .profile

# Configure MySql
COPY scripts/setup_mysql.sh /tmp/setup_mysql.sh
RUN /tmp/setup_mysql.sh
# Set Mysql data folder as a volume
VOLUME /var/lib/mysql

# Configure InfluxDB
COPY influxdb/influxdb.conf /etc/influxdb/influxdb.conf
COPY influxdb/init.sh /etc/init.d/influxdb
# Set Infludb data folder as a volume
VOLUME /var/lib/influxdb

# Configure Telegraf
COPY telegraf/telegraf.conf /etc/telegraf/telegraf.conf
COPY telegraf/init.sh /etc/init.d/telegraf

# Configure Grafana with provisioning
ADD grafana/provisioning /etc/grafana/provisioning
ADD grafana/dashboards /var/lib/grafana/dashboards
COPY grafana/grafana.ini /etc/grafana/grafana.ini


EXPOSE 1883 9001 3003 8888 8086 8125 22

CMD ["/usr/bin/supervisord"]
