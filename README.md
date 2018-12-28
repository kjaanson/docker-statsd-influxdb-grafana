# Docker Image with Telegraf (StatsD), InfluxDB, Grafana and Mosquitto

Forked from https://github.com/samuelebistoletti/docker-statsd-influxdb-grafana

Major changes from the original

Changes from original
  * Changed Dockerfile to do the heavylifting (package download and install) at the beginning and include configs at the end
  * Made volumes of data folders of different services
  * Changed supervisord config to run processes directly as foreground processes in some cases.

## Versions

### Warning, breaking change: upgrade from version 1.0.x of this image is not supported, all persisted data in volumes will be lost if you delete the container.

* Docker Image:      2.2.0
* Ubuntu:            16.04
* InfluxDB:          1.7.0
* Telegraf (StatsD): 1.8.3-1
* Grafana:           5.3.2

## Quick Start

To start the container the first time launch:

```sh
sh docker-run.sh
```

You can replace `latest` with the desired version listed in changelog file.

To stop the container launch:

```sh
docker stop docker-statsd-influxdb-grafana
```

To start the container again launch:

```sh
docker start docker-statsd-influxdb-grafana
```

### Mapped ports

```
Host		Container		Service

1883    1883      mosquitto
3003		3003			grafana
3004		8888			influxdb-admin (chronograf)
8086		8086			influxdb
8125		8125			statsd
22022		22        sshd
```
## SSH

```sh
ssh root@localhost -p 22022
```
Password: root

## Grafana

Open <http://localhost:3003>

```
Username: root
Password: root
```

### Add data source on Grafana

1. Using the wizard click on `Add data source`
2. Choose a `name` for the source and flag it as `Default`
3. Choose `InfluxDB` as `type`
4. Choose `direct` as `access`
5. Fill remaining fields as follows and click on `Add` without altering other fields

```
Url: http://localhost:8086
Database:	telegraf
User: telegraf
Password:	telegraf
```

Basic auth and credentials must be left unflagged. Proxy is not required.

Now you are ready to add your first dashboard and launch some query on database.

## InfluxDB

### Web Interface

Open <http://localhost:3004>

```
Username: root
Password: root
Port: 8086
```

### InfluxDB Shell (CLI)

1. Establish a ssh connection with the container
2. Launch `influx` to open InfluxDB Shell (CLI)
