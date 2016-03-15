run:
```
    vagrant up
    vagrant ssh # open a shell on the vagrant box
```

## To install jupyter notebook ( formally known as iPython notebook)
Because python depends on System libraries and python libs which also 
depend on system libs this VagrantFile and DockertFile will build it in a
Docker Containter and Vagrant will treat it as a "box"

This leads to a very fast to launch and run dev box to work with python and the jupyter notebook from.

You will need to have (installed vagrant)[https://www.vagrantup.com/downloads.html] and if you are on linux and want to run the container nativley (recommended for speed) you will need to (install docker)[https://docs.docker.com/engine/installation/] although Vagrant will attempt to do so if it can't find it.

## <a name="launch"></a>launch

Modify the Vagrant file to use your [email and product key that you got for graphlab from Dato (see below)](#graphlab) 
in particular uncomment the line that starts with `#d.build_args` by removing the `#`
and edit `email` and `grphlabkey` on that line

You could aso edit the Dockerfile to give default values to the ARGS , see [docker docs](https://docs.docker.com/engine/reference/builder/#arg)

Once this small edit is done you can run the commands below to create and launch the vagrant box.
Bear in mind that the first time you run it vagrant up will provission the Docker Container. This can take 5-10 mins the first time (on a fast network). To speed this up a premade image exists in ./shells which the Vagrantfile uses by default. see [FAQ](#faq) below to build from the Dockerfile

```
   vagrant up
   vagrant ssh
   source /dato-env/bin/activate
   jupyter notebook
```

now open your browser at http://localhost:8888 et voila!

### <a name="graphlab"></a>getting graphlab key and license.
While sframes is opensource and free the Graphlab Create libraries from Dato
require a product key in order to install it. the way to get it is

1. go to https://dato.com/download/academic.html
  - you an find this link from the Dato website, click on "Free Trial" then "academic program"
2. register and select the "Student of Coursera" option
3. pick a long-ish expiration date
4. on success you will get a product key registered against your email
  - eg 

    Data products for graphlab registered non comercial for coursera use         
    Registered email address: your.namefoo.bar.com                       
    Product key: AAAA-BBBB-CCCC-DDDD-EEEE-DDDD-FFFF-AAAA

* save these details they are needed to install Graphlab Create. 
* in this case modify the Vagrantfile to use your email and key (see above)

## <a name="faq"></a>FAQ
* Why docker rather than VIrtualbox?
  - Faster to launch as it is just using my existing kernel but isolated into containers

* Why vagrant not docker directly?
  - vagrant makes it easy to "get onto the box" using `vagrant ssh`
    - which is easier than useing docker to search for the running container etc...
    - if you want to use docker this is how:- 
        
    you can just run Docker directly to get a shell doing

        docker build -t mypycontainer1 .
        docker run mypycontainer1

    in another terminal type:

        docker ps

    look for the containerId of mypycontainer1

    then type:
        docker exec -it -u vagrant containid /bin/bash

* How can I modify the Docker container to add more tools?
  - Edit the Dockerfile to add the [docker commands](https://docs.docker.com/engine/reference/builder/)
  - Edit the Vagrantfile to use build-dir rather than image (see the comments in the Vagrantfile)
  - run `vagrant halt` `vagrant reload` to rebuild the container.
    - bear in mind that Docker caching is good for a quick build so put your changes near the bottom of the file
    - if you don't want to rebuild everything
    
* Can I cut my new build as an image?
  - sure, but if you ran vagrant to run the Dockerfile it has already done so locally for you
  - but if you want to capture it wrap it up and allow someone else to run it as an image without having to 
  - build it then do this:

    docker images
       look for your image

    extract it to a tar.gz
    modify Vagrant file to point d.image=<path to your image>
