#
# Karls dev env for Coursera Machine Learning
#
# Docker image based on ubuntu. It installs 'jupyter notebook' and the 
# graphlab and matplotlib libraries
#
# It is designed to work with Vagrant so you can just edit your work files
# in this directory, or when ssh'd to the box the same files are available at
# /vagrant
#
# The 'vagrant' user is already setup and his hime dir is /home/vagrant
# his ssh keys are in place so you should not need a password but if you do it 
# is 'vagrant'
# 
# The 'root' user on the box also has the password 'vagrant'
#
#
#
# The Docker image sets up the notebook as a server exposing port 8888 on the 
# host OS, so you can simply see it from you normal browser at
# http://localhost:8888
#
# This Docker build is designed to be used with vagrant as an interactive shell
# environmnet. So you simply do :-
#
#    vagrant up                         # launch the box
#    vagrant ssh                        # ssh onto the box
#    source /graphlab-env/bin/activate  #change PATH so we use the  graphlab virtual-env
#    jupyter notebook                   # kick of the notebook
#
# If you'd rather use the Docker as simply a jupyter notebook server that 
# just starts notebook, then look at the bottom of the file for the comment and
# uncomment notes.
#
#
FROM ubuntu:trusty-20160302

# Get rid of bourne shell issues
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# mandiatry build-args
ARG email
ARG graphlabkey
ENV MYEMAIL=$email
ENV MYGRAPHLABKEY=$graphlabkey

# Information
RUN echo "using build-arg email of: " $MYEMAIL
RUN echo "using build-arg graphlabkey of: " $MYGRAPHLABKEY

RUN if [ -z ${MYEMAIL+x} ]; then echo "OOPS YOU DID NOT SET --build-arg emmail=<your email>"; exit 13; else echo "using email=$MYEMAIL";fi 
RUN if [ -z ${MYGRAPHLABKEY+x} ]; then echo "OOPS YOU DID NOT SET --build-arg graphlabkey=<your graphlabkey>"; exit 13; else echo "using graphlabkey=$MYGRAPHLABKEY";fi 


RUN echo I will run the following command to install graphlab
RUN echo "source dato-env/bin/activate --system-site-packages && pip install --upgrade pip && pip install --upgrade --no-cache-dir https://get.dato.com/GraphLab-Create/1.8.3/${MYEMAIL}/${MYGRAPHLABKEY}/GraphLab-Create-License.tar.gz"


RUN echo "Building Karl's Machine Learning Specialisation env"

RUN echo "The Course uses Python with 'ipython notebook' for experimenting and demos"
RUN echo "Also we need the libraries 'matplotlib' for graphs and 'graphlab' for SFrames"
RUN echo "These python libraries also depend on various OS level libraries." && echo
RUN echo "In addition graphlab must be built in a python virtualenv, to keep \
it isolated from python lib changes and because it's pip install fails to \
properly tidy itself up after running tests and tries to remove all the tmp \
pip directories, these directories may not be empty so the install aborts!"

RUN echo "Note that the modern iPython notebook is now called 'jupyter notebook'"
RUN echo "The install instructions for jupyter notebook. see http://jupyter.readthedocs.org/en/latest/install.html."
RUN echo "In adition see the blog at http://pandaquality.blogspot.com.au/2015/05/how-to-install-ipython-notebook.html , it lists some dependencies needed for ipython notebook"

RUN echo "We set jupyter notebook to be a server that listens to any ip addtress so i can get to it from host OS"
RUN echo "to secure it see http://jupyter-notebook.readthedocs.org/en/latest/public_server.html"
RUN echo "nb ipython notebook is now jupyter notebook"

# Add OS level packages and libraries
#
# basic normal utils like curl git gzip and python
# 
# python pip installs require some crypto to validate downloads.
# see:  http://urllib3.readthedocs.org/en/latest/security.html
#
# libffi6 needed by python openssl cryptography 
# libssl-dev needed by python cryptography
# freetype needed by matplotlib
# zlib1g-dev needed by matplotlib
# libpng-dev needed by matplotlib
#
RUN apt-get update -y && apt-get -y install \ 
  gzip zip unzip \
  git \
  openssh-server \
  vim \
  curl wget \
  g++ \
  libssl-dev \
  libffi6 libffi-dev \
  libzmq3-dev \
  libxft-dev \
  libpng-dev \
  freetype* \
  python3 python-pip python-dev \
  build-essential

# set up ssh server run space
RUN mkdir -p /var/run/sshd
RUN chmod 700 /var/run/sshd

# Add vagrant user and passwd and insecure vagrant key
# change root passwd to vagrant
RUN ["/bin/bash", "-c" ,"echo -e \"vagrant\\nvagrant\" | passwd"]
# create vagrant user and add ssh keys
RUN useradd -m -s /bin/bash vagrant
# set vagrant passwd to vagrant
RUN ["/bin/bash", "-c" ,"echo -e \"vagrant\\nvagrant\" | passwd vagrant"]
# add vagrant insecure key so you can simple log into the box with 'vagrant ssh'
RUN mkdir -p /home/vagrant/.ssh
RUN chmod 700  /home/vagrant/.ssh 
ADD shells/vagrant.pub  /home/vagrant/.ssh/authorized_keys
RUN chmod 600 /home/vagrant/.ssh/authorized_keys
RUN chown -R vagrant:vagrant /home/vagrant/.ssh
# all vagrant use to sudo to root
RUN echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# add the docker config in case we want to add docker on the docker :-/
ADD shells/etc_default_docker.txt /etc/default/docker

#
# use python pip to install python tools inc itself
RUN echo "Installing python-y stuff using pip"

RUN pip install --upgrade pip
# prevent insecure platform warnings on pip downloads
RUN pip install --upgrade ndg-httpsclient
RUN pip install --upgrade cryptography
RUN pip install --upgrade pyopenssl ndg-httpsclient pyasn1
RUN pip install --upgrade urllib3[secure]
RUN pip install --upgrade virtualenv

# install iPython notebook
RUN pip install pyzmq
RUN pip install jinja2
RUN pip install pygments
RUN pip install tornado
RUN pip install jsonschema
RUN pip install ipython
RUN pip install --upgrade ipython[notebook]
RUN pip install --upgrade matplotlib

# do it all in a python virtualenv or else graphlab cant install because it tried to deleate a pip tmp dir after runnin tornado tests
RUN virtualenv dato-env
RUN echo "Gonna now run this graphlab install"
RUN echo "source dato-env/bin/activate --system-site-packages && pip install --upgrade pip && pip install --upgrade --no-cache-dir https://get.dato.com/GraphLab-Create/1.8.3/${MYEMAIL}/${MYGRAPHLABKEY}/GraphLab-Create-License.tar.gz"
RUN source dato-env/bin/activate --system-site-packages && pip install --upgrade pip && pip install --upgrade --no-cache-dir https://get.dato.com/GraphLab-Create/1.8.3/${MYEMAIL}/${MYGRAPHLABKEY}/GraphLab-Create-License.tar.gz

# config jupytrer notebook to be a server that listens on all ip's so i can get to it from Host OS
RUN su - vagrant -c "jupyter notebook --generate-config"
RUN echo "c.NotebookApp.ip = '*'" >> /home/vagrant/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.port = 8888" >> /home/vagrant/.jupyter/jupyter_notebook_config.py

# copy the graphlab/config file to the vagrant user so he can use the licence in there.
# create the config dir if neccessary as the vagrant user
RUN su - vagrant -c "mkdir -p /home/vagrant/.graphlab"
RUN cp /root/.graphlab/config /home/vagrant/.graphlab
RUN chown -R vagrant:vagrant /home/vagrant/.graphlab

# link the lessons and assignments in the /vagrant folder (ie in the root dir of the build that vagrant maps)
RUN su - vagrant -c "ln -s /vagrant/lessons ./lessons  && ln -s /vagrant/assignments ./assignments"


# let Docker know we will expose the ipthon port
EXPOSE 8888
# Add Tini. Tini operates as a process subreaper for jupyter. This prevents
# kernel crashes if the notebook server is run for a long time.
ENV TINI_VERSION v0.6.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

# If I wanted to run the notebook as a server from a container uncomment next 2 lines and romove the lines after these two
RUN mkdir -p /usr/local/bin
RUN echo -e "#!/bin/bash \n\
service ssh restart\n\
su - vagrant -c \"source /dato-env/bin/activate && jupyter notebook --port=8888 --no-browser --ip=0.0.0.0\" & \n\
top -b " \
>> /usr/local/bin/launch
RUN chmod a+x /usr/local/bin/launch

#ENTRYPOINT ["service", "ssh", "restart", "&&","/usr/bin/tini", "--"]
ENTRYPOINT ["/usr/local/bin/launch"]
# CMD ["top", "-b"]
# CMD ["source", "/dato-env/bin/activate", "&&", "jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0"]

# kick off sshd and run top for ever so the container keeps running so we can ssh to this box.
#ENTRYPOINT service ssh restart && top -b
# CMD ["-c"]
