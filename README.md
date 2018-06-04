# Docker Log-driver plugin for Docker

Docker Logging Plugin allows docker containers to send their logs to your own log server.

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
