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
docker plugin enable ${PLUGIN_NAME}:${PLUGIN_TAG}
```

#### Example

```
$ docker run --log-driver=dockerlogplugin:latest

```
