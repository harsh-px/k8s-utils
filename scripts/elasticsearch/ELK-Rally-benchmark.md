## Elasticsearch benchmark  with Rally

### Setup rally on Centos 7

Rally requires Pyhon 3.4+, PIP3,  JDK8, git 1.9+, gcc, gcc-c++, gradle

Install Python 3.5 with PIP3


    $ sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm
    $ sudo yum -y install python36u
    $ /usr/bin/pyhon3.6 -V
    $ sudo yum -y install python36u-pip
    $ sudo yum -y install python36u-devel
  

Install JDK 

    $ sudo yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel


Install GIT 1.9+

    $ yum install -y curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker
    $ cd /usr/src
    $ wget https://www.kernel.org/pub/software/scm/git/git-1.9.4.tar.gz
    $ tar xzf git-1.9.4.tar.gz
    $ cd git-1.9.4
    $ make prefix=/usr/local/git all
    $ make prefix=/usr/local/git install
    $ echo "export PATH=$PATH:/usr/local/git/bin" >> /etc/bashrc
    $ source /etc/bashrc
    $ git --version
    
      git version 1.9.4


Install gcc gcc-c++

    $ yum install -y gcc gcc-c++ unzip


Install gradle 3.4

    $ wget https://services.gradle.org/distributions/gradle-3.4.1-bin.zip
    $ sudo mkdir -p /opt/gradle
    $ sudo unzip -d /opt/gradle gradle-3.4.1-bin.zip
    $ export PATH=$PATH:/opt/gradle/gradle-3.4.1/bin
    $ gradle -v

   
Install Rally

    $ /usr/bin/pip3.6 install esrally 

Configure Rally

     $ esrally configure

         ____        ____
        / __ \____ _/ / /_  __
       / /_/ / __ `/ / / / / /
      / _, _/ /_/ / / / /_/ /
     /_/ |_|\__,_/_/_/\__, /
                /____/

     Running simple configuration. Run the advanced configuration with:

     esrally configure --advanced-config

     INFO:rally.config:Running simple configuration routine.
      * Autodetecting available third-party software
        git    : [OK]
        gradle : [OK]
        JDK 8  : [OK]

      * Setting up benchmark data directory in [/root/.rally/benchmarks] (needs several GB).
      Enter your Elasticsearch project directory: [default: '/root/.rally/benchmarks/src']:
      Using default value '/root/.rally/benchmarks/src'

      Configuration successfully written to [/root/.rally/rally.ini]. Happy benchmarking!

      To benchmark Elasticsearch with the default benchmark run:

      esrally

      For help, type esrally --help or see the user documentation at https://esrally.readthedocs.io/en/0.6.0/


## Running the Rally benchmark test

Run default logging track and against the target host at ``10.111.107.223`` with port ``9200``


      esrally --track=logging --target-hosts=10.111.107.223:9200 --pipeline=benchmark-only


It will takes several minutes to an hour to complete the test; and then collect the Rally Final Score.

   
    
    


  


