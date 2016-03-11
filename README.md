run:
    vagrant up
    vagrant ssh # open a shell on the vagrant box

you can just run Docker directly to get a shell doing

docker build -t mypycontainer1 .
docker run mypycontainer1

in another term type
   docker ps # look for the containerId of mypycontainer1

then type
   docker exec -it -u vagrant containid /bin/bash

## To install jupyter notebook ( formally known as iPython notebook)
Because python depends on System libraries and python libs which also 
depend on system libs this VagrantFile and DockertFile will build it in a
Docker Containter and Vagrant will treat it as a "box"

### launch
   vagrant up
   vagrant ssh
   source dato-env/bin/activate
   jupyther notebook

now open your browser at http://localhost:8888 et voila!

### FAQ
* Why docker rather than VIrtualbox?
  - Faster to launch as just using my existing kernel just isolated into containers
* Whu vagrant not docker directly?

