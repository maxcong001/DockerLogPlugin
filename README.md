# Docker Log-driver plugin for Docker
## overview
Docker Logging Plugin allows docker containers filter log, then send their logs to your own log server.
#### build-in docker log driver
Docker Logging drivers enables users to forward container logs to another service for processing. Docker includes several logging drivers as built-ins(jsonfile, syslog, journal, gelf, fluentd, awslogs, splunk, etwlogs, gcplogs), however can never hope to support all use-cases with built-in drivers. 
#### docker plugin system
Plugins allow Docker to support a wide range of logging services without requiring to embed client libraries for these services in the main Docker codebase. 
#### Holocene overview
Holocene is a Docker log plugin. If Holocene is enabled, Docker daemon start a new  special container. In the container, a restful server is started.
When a new container starts, Docker daemon send restful message to the plugin with log stream path and other info(like container id), then Holocene create a new go routine and do the processing work, then dispatch the message to the remote log server.

Holocene plugin system:

Holocene plugin system is inspired by Redis. Redis have feature named "module" in its latest version.
Holocene will open some key APIs to user, to develop a new plugin, you just need to implement these ideas.
If any user want their special requirement. He can impelment the logic and build out a dynamic library then tell Holocene in the confiuration.

Holocene will support two kind of plugin:
1. filter plugin. By default is: Regular expression
2. output plugin. By default TCP

## build status --> [![Build Status](https://travis-ci.org/maxcong001/dockerlogplugin.svg?branch=master)](https://travis-ci.org/maxcong001/dockerlogplugin)
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

### advantage
#### PH1

discription | Holocene | fluent-bit
------------- | ------------------- | ----
 more Flexible|just realize the API, build dynamic lib, then pass the lib path in the configuration. For user, just need to focus on the logic | need to build special image if you add new driver  | 
 more stable |docker-deamon just send REST-FUL API message to tell the plugin container what to do, if plugin crash, has little affect to docker-d | for fluent build-in docker driver, if driver crash, it will have bad effect on docker-d
 high performance  | 1. get docker log data directly form container.     2 no need to pack/unpack log message | 1. get log data from container.     2. pack log message.     3. send to fluent-bit container.     4. Fluent-bit container receive the message and unpack it, then do the following logic
 health life cycle   | Holocene has the same life cycle with docker-d|need to start a special container and should take care the life cycle of this container    
#### PH2
discription | Holocene | fluent-bit
------------- | ------------------- | ----
programmable Holocene  | Start a REST-FUL server for configuration, which can receive config change run-time and do related work. | no such function



