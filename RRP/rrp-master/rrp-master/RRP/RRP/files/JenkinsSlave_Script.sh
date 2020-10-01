if ! [ -f /sys/hypervisor/uuid ]; then
    sudo mkdir jenkins_slave
    sudo chmod -R 777 jenkins_slave
    sudo add-apt-repository -y ppa:openjdk-r/ppa
    sudo apt-get update
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
