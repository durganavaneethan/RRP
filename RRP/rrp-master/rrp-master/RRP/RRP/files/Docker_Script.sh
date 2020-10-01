if ! [ -f /sys/hypervisor/uuid ]; then
    sudo mkdir jenkins_slave
    sudo chmod -R 777 jenkins_slave
    sudo add-apt-repository -y ppa:openjdk-r/ppa
    sudo apt-get update
    sudo apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
    sudo apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-trusty main'
    sudo apt-get update
    sudo apt-get install -y docker-engine
    sudo service docker start
    sudo docker run -d --restart=always -p 5000:5000 --name registry registry:2
    sudo apt-get install -y openjdk-8-jdk
    sudo apt-get install -y maven
    sudo apt-get install -y git
    sudo chmod -R 777 /usr/share/maven
    sudo chmod -R 777 /usr/share/maven/conf
    java -version
    mvn -version
else
    sudo mkdir jenkins_slave
    sudo chmod -R 777 jenkins_slave
    sudo yum -y update
    sudo yum install -y docker
    echo 'OPTIONS="--insecure-registry=34.224.201.94:5000"' >> /etc/sysconfig/docker
    sudo service docker start
    sudo chmod -R 777 /var/run/docker.sock
    curl -L https://github.com/docker/compose/releases/download/1.7.0/docker-compose-`uname -s`-`uname -m` > ./docker-compose
    sudo mv ./docker-compose /usr/bin/docker-compose
    sudo chmod -R 777 /usr/bin/docker-compose
    sudo docker run -d --restart=always -p 5000:5000 --name registry registry:2
    sudo yum install -y java-1.8.0-openjdk-devel
    sudo yum remove -y java-1.7.0-openjdk
    sudo cp -rf files/apache-maven-3.3.9 /opt/
    sudo chmod -R 777 /opt/apache-maven-3.3.9/
    cd /etc
    sudo chmod -R 666 profile
    sudo echo 'export M2_HOME=/opt/apache-maven-3.3.9' >> profile
    sudo echo 'export M2=$M2_HOME/bin' >> profile
    sudo echo 'export PATH=$M2:$PATH' >> profile
    source /etc/profile
    #export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.131-2.b11.el7_3.x86_64/jre
    cd
    sudo yum install -y git
    java -version
    mvn -version
fi
