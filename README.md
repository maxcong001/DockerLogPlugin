# Holocene
## build status --> [![Build Status](https://travis-ci.org/maxcong001/dockerlogplugin.svg?branch=master)](https://travis-ci.org/maxcong001/dockerlogplugin)


## overview
Holocene allows docker containers collect log, filter log, then send their logs to your own log server.

[![Holocene](https://github.com/maxcong001/dockerlogplugin/blob/master/doc/image/holocene-flow.PNG)](https://github.com/maxcong001/dockerlogplugin/blob/master/doc/image/holocene-flow.PNG)    

#### build-in docker log driver
Docker Logging drivers enables users to forward container logs to another service for processing. Docker includes several logging drivers as built-ins(jsonfile, syslog, journal, gelf, fluentd, awslogs, splunk, etwlogs, gcplogs), however can never hope to support all use-cases with built-in drivers. 
#### docker plugin system
Plugins allow Docker to support a wide range of logging services without requiring to embed client libraries for these services in the main Docker codebase. 
#### Holocene overview
Holocene is a Docker log plugin. If Holocene is enabled, Docker daemon start a new  special container. In the container, a restful server is started.
When a new container starts, Docker daemon send restful message to the plugin with log stream path and other info(like container id), then Holocene create a new go routine and do the processing work, then dispatch the message to the remote log server.

Holocene plugin system:

Holocene plugin system is inspired by Redis. Redis have feature named "module" in its latest version.
Holocene will open some key APIs to user. to develop a new plugin, you just need to implement these APIs. You can impelment the logic and build out a dynamic library then tell Holocene in the confiuration. In the phase 2 of Holocene, it will have CLI interface and REST-FUL API.

Holocene will support two kinds of plugin:
1. filter plugin. By default is: Regular expression
2. output plugin. By default TCP
## how to use Holocene
1. prepare your plugin 
2. docker push your plugin to your own registory or official docker hub
3. docker plugin install dockerlogplugin:latest, it will atumaitcly download the plugin
4. enable the plugin : docker plugin enable dockerlogplugin:latest
5. start a docker with the plugin : docker run --log-driver=dockerlogplugin:latest    

*Note: When a plugin is first referred to -- either by a user referring to it by name (e.g. docker run --volume-driver=foo) or a container already configured to use a plugin being started -- Docker looks for the named plugin in the plugin directory and activates it with a handshake.   
Plugins are not activated automatically at Docker daemon startup. Rather, they are activated only lazily, or on-demand, when they are needed.*      
or use systemd to active plugin:    
Plugins may also be socket activated by systemd. The official Plugins helpers natively supports socket activation. In order for a plugin to be socket activated it needs a service file and a socket file.

The service file (for example /lib/systemd/system/your-plugin.service):
```
[Unit]
Description=Your plugin
Before=docker.service
After=network.target your-plugin.socket
Requires=your-plugin.socket docker.service

[Service]
ExecStart=/usr/lib/docker/your-plugin

[Install]
WantedBy=multi-user.target
```
The socket file (for example /lib/systemd/system/your-plugin.socket):
```
[Unit]
Description=Your plugin

[Socket]
ListenStream=/run/docker/plugins/your-plugin.sock

[Install]
WantedBy=sockets.target
```
This will allow plugins to be actually started when the Docker daemon connects to the sockets they’re listening on (for instance the first time the daemon uses them or if one of the plugin goes down accidentally).    
More detail about how to active plugin, see : [https://docs.docker.com/engine/extend/plugin_api/#plugin-activation](https://docs.docker.com/engine/extend/plugin_api/#plugin-activation)

## Getting Started

You need to install Docker Engine >= 1.12.

Additional information about Docker plugins [can be found here.](https://docs.docker.com/engine/extend/plugins_logging/)


### Developing

For development, you can clone and run make

```
git clone https://github.com/maxcong001/dockerlogplugin
cd dockerlogplugin
make
```

### Installing

To install the plugin, you can run

```
docker plugin install dockerlogplugin:latest 
docker plugin ls
```

This command will pull and enable the plugin

### Using
```
docker plugin enable dockerlogplugin:latest
```

#### Example

```
$ docker run --log-driver=dockerlogplugin:latest

```

## compare to fluentd
### what is fluentd    
[![what is fluentd](https://github.com/maxcong001/dockerlogplugin/blob/master/doc/image/what-is-fluentd.png)](https://github.com/maxcong001/dockerlogplugin/blob/master/doc/image/what-is-fluentd.png)
  

Fluentd has a docker build-in driver called “fluentd”. 
This driver collect log message, packet them and send them to fluentd-container. 
Fluentd container will filter/routing the message 

fluentd homepage: [https://www.fluentd.org/](https://www.fluentd.org/)

### fluentd vs holocene
[![compare to fluentd](https://github.com/maxcong001/dockerlogplugin/blob/master/doc/image/holocenevsfluentd.PNG)](https://github.com/maxcong001/dockerlogplugin/blob/master/doc/image/holocenevsfluentd.PNG)
Compared to fluentd:
1. No extra container is needed.
2. Fluentd container receive all the message form containers, which will become bottom-neck of the system if message flood comes.
Holocene(go routine) has the same life cycle with container.
3. Fluentd build-in driver is a go-routine started by dockerd, so there may be impact on dockerd for stability, but Holocene is a separate container, it has no impact on dockerd.
4. Have the same feature as fluentd(filter, routing)
5. Written by go/C,C++ with high performance, fluentd is written by Ruby    
……                                                                   

## compare to fluent-bit

### what is fluent-bit
Fluent-bit use docker build-in log driver called "fluentd" and do the same work as fluentd. 
Fluent bit is written by C language with high performance compared to fluentd, but less flexible.
fluent-bit homepage: [https://fluentbit.io/](https://fluentbit.io/)
### advantage
#### PH1

description | Holocene | fluent-bit
------------- | ------------------- | ----
 more Flexible|just realize the API, build dynamic lib, then pass the lib path in the configuration. For user, just need to focus on the logic | need to build special image if you add new driver  | 
 more stable |docker-deamon just send REST-FUL API message to tell the plugin container what to do, if plugin crash, has little affect to docker-d | for fluent build-in docker driver, if driver crash, it will have bad effect on docker-d
 high performance  | 1. get docker log data directly form container.     2 no need to pack/unpack log message | 1. get log data from container.     2. pack log message.     3. send to fluent-bit container.     4. Fluent-bit container receive the message and unpack it, then do the following logic
 health life cycle   | Holocene has the same life cycle with docker-d|need to start a special container and should take care the life cycle of this container    
#### PH2
description | Holocene | fluent-bit
------------- | ------------------- | ----
programmable Holocene  | Start a REST-FUL server for configuration, which can receive config change run-time and do related work. | no such function



