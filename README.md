# Shiny Load Balanced Cluster
## Architecture
![alt tag](https://raw.github.berkeley.edu/SCF/shiny-lb/master/images/shiny-lb-arch.png?token=AAAAYaIG7iCI1eci7j3b0DtefMw9sCY8ks5Y97V7wA%3D%3D)

## Synopsis
The Shiny-lb project was developed as an effort to leverage physical servers, Docker, and Shiny Server to create a load balanced, scalable Shiny Server deployment that can support hundreds of concurrent users.  The current community version of Shiny Server only supports one single R worker process that has issues supporting over 150 concurrent users; to extend its usability beyond this limitation, we deploy Docker containers that run a Shiny Server instance each, this in turn runs its own R worker process.

## Requirements
To build the proxy and node containers, ensure that you have the following:
  * Docker engine version 1.12.x or later.
  * Docker Compose 1.11.x or later (or any that can support version '2' docker-compose.yml syntax).
  * Make 4.1+ (optional)

## Building the containers
We provided a Makefile for each of container "blueprint"; it uses docker compose to build and can be executed by simply running "make" in the respective directory (e.g. shiny-nodes).  To do a manual build using Docker Compose:
 1. Make the configuration changes per your organization (see Testing...).
 2. Run 'docker-compose build' as the root user.
 3. When complete run 'docker-compose up -d' as the root user.
By default, the proxy uses port 3838 while the nodes will use 40038-40041.  The Docker Compose configuration 
will launch four node instances, each on one of the node ports listed prior

To verify that the containers are running, execute 'docker ps' as root - the output will be similar to the block below.  This assumes that all of the containers are running in the same physical server:
```
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS              PORTS                                         NAMES
40a920d93e95        nginxproxy_shiny_lb       "nginx"                  27 minutes ago      Up 27 minutes       0.0.0.0:3838->80/tcp, 0.0.0.0:3839->443/tcp   shiny_lb
5e9eda83c63e        shinynodes_shiny_node_3   "/bin/sh -c '/usr/bin"   39 minutes ago      Up 39 minutes       0.0.0.0:40040->3838/tcp                       shiny_node3
1627a7278e22        shinynodes_shiny_node_4   "/bin/sh -c '/usr/bin"   39 minutes ago      Up 39 minutes       0.0.0.0:40041->3838/tcp                       shiny_node4
651e450c74fc        shinynodes_shiny_node_2   "/bin/sh -c '/usr/bin"   39 minutes ago      Up 39 minutes       0.0.0.0:40039->3838/tcp                       shiny_node2
df0b7e63914b        shinynodes_shiny_node_1   "/bin/sh -c '/usr/bin"   39 minutes ago      Up 39 minutes       0.0.0.0:40038->3838/tcp                       shiny_node1
```

## Testing the out-of-the-box implementation.
In order to test this implementation two changes are required:
  * Add the name of the test server to /path/to/shiny-lb/nginx-lb/etc/nginx/nginx.conf
    * e.g. server_name foo.server.com
  * Add the name of the server(s) running shiny nodes, for testing purposes this can be the same server
    * e.g. server foo.server.com:40038 fail_timeout=300 max_conns=150;
      * server foo2.server.com:40038... etc.
    * please note that this cannot be 'localhost'.
  * Build the proxy and node containers.
Once the containers have been built, the test URL becomes http://foo.server.com:3838/ where foo.server.com is the FQDN of your test server.

## Manually building containers without Docker Compose (TBD).
