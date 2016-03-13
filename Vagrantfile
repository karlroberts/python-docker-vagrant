# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
   
  config.vm.provision "file", source: "~/.gitconfig", destination: ".gitconfig"

  # docker - initially build from a Dockerfile then when happy cut an image
  config.vm.hostname = "docker-host"
  config.vm.provider "docker" do |d, override|
    # Uncomment below to use th image rather than build  from Dockerfile
    #d.image = "foo/myimage"

    # Comment build_dir to use Image rather than build from Dockerfile
    d.build_dir = "."

    # Uncomment elow to specify a particular Dockerfile default is DockerFile in build_dir
    #d.dockerfile = "Dockerfile"

    #                                     
    #                                                                                                                 4908-0CC7-1900-78B1-3A8F-300D-7D7F-1971
    # SET YOUR GRAPHLAB email and graphlabkey BELOW and tag the container image
    d.build_args = ["--tag=mlpythontag", "--build-arg", "email=you.email@foo.bar.com", "--build-arg", "graphlabkey=AAAA-AAAA-AAAA-AAAA-AAAA-AAAA-AAAA-AAAA"]

    # vagrant can auto map the ssh ports
    d.has_ssh = true
    d.name = "mlpython01"
    d.create_args  = ["-w", "/home/vagrant"]

    # map the host:container ports. ipython notebook uses 8888
    d.ports = ["8888:8888"]
  end

  config.vm.provider "virtualbox"

  config.vm.provider "vmware_fusion"

  #port forwards
  # If you run Docker in a Virtual Machin Box rather than nativly in Host systems Docker
  # you may need to expose the VM ports to your host if you want to connect to the ipython notebook
  # in this example you would then go to http://localhost:8887 on your Host OS
  ## ipython notebook
  # config.vm.network "forwarded_port", guest: 8888, host: 8887, protocol: "tcp"
  

end
