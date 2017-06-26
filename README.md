# docker-shiny

Docker container for [shiny server][1]

Originally based on quantumobject/docker-shiny.

## Usage

To run container use the command below:

    $ docker run -d -p 3838:3838 ucbscf/docker-shiny

To run the container with your own Shiny applications located in a directory on
your system, expose that directory path to the Shiny server inside the container:

    $ docker run -d -p 3838:3838 -v <LOCAL DIRECTORY PATH>:/srv/shiny-server ucbscf/docker-shiny

When modified or adding files  to \<LOCAL DIRECTORY PATH\> you need to restart the container to allow it to change the files to the right ownership and permission.  

## Accessing the Shiny Server applications:

After that check with your browser at addresses plus the port 3838 :

  - **http://host_ip:3838/**

To access it , configured and edit files inside of the container :

    $ docker exec -it container-id /bin/bash

## More Info

About Shiny Server: [shiny.rstudio.com][2]

Shiny Server [Administrator's Guide][3]

[1]:http://www.rstudio.com/products/shiny/download-server
[2]:http://shiny.rstudio.com
[3]:http://rstudio.github.io/shiny-server/latest
