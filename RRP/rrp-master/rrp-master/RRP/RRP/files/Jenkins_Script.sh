if ! [ -f /sys/hypervisor/uuid ]; then
    sudo mkdir data
    sudo mkdir data/jenkins_data
    sudo chmod -R 777 data/jenkins_data
    docker -v
    if [ $? -eq 127 ] ; then
        sudo apt-get update
        sudo apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
        sudo apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-trusty main'
        sudo apt-get update
        sudo apt-get install -y docker-engine
        sudo service docker start
        sudo docker pull jenkins
        sudo chmod -R 777 data
        sudo docker run -d --restart=always --name newjenkins -p 8082:8080 -p 50000:50000 -v /home/RRP/data/jenkins_data/:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -t jenkins
        sudo sleep 100
        sudo ex +g/authorizationStrategy/d -scwq data/jenkins_data/config.xml
        sleep 40
        sudo cp -rf /home/RRP/files/credentials.xml /home/RRP/data/jenkins_data
        sudo cp -rf /home/RRP/files/hudson.tasks.Maven.xml /home/RRP/data/jenkins_data
        sudo cp -rf /home/RRP/files/org.jenkinsci.plugins.docker.commons.tools.DockerTool.xml /home/RRP/data/jenkins_data
        sudo cp -rf /home/RRP/files/tools /home/RRP/data/jenkins_data/
        sudo cp -rf /home/RRP/files/Dockerfile /home/RRP/data/jenkins_data/
        sudo chmod -R 777 /home/RRP/data/jenkins_data/tools/hudson.tasks.Maven_MavenInstallation/test/
        sudo chmod -R 777 /home/RRP/data/jenkins_data/tools/org.jenkinsci.plugins.docker.commons.tools.DockerTool/testdocker/
	sudo chmod -R 777 /var/run/docker.sock
        sudo docker restart newjenkins
    else
        sudo service docker start
        sudo docker pull jenkins
        sudo chmod -R 777 data
        sudo docker run -d --restart=always --name newjenkins -p 8082:8080 -p 50000:50000 -v /home/RRP/data/jenkins_data/:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -t jenkins
        sudo sleep 100
        sudo ex +g/authorizationStrategy/d -scwq data/jenkins_data/config.xml
        sleep 40
        sudo cp -rf /home/RRP/files/credentials.xml /home/RRP/data/jenkins_data
        sudo cp -rf /home/RRP/files/hudson.tasks.Maven.xml /home/RRP/data/jenkins_data
        sudo cp -rf /home/RRP/files/org.jenkinsci.plugins.docker.commons.tools.DockerTool.xml /home/RRP/data/jenkins_data
        sudo cp -rf /home/RRP/files/tools /home/RRP/data/jenkins_data/
        sudo cp -rf /home/RRP/files/Dockerfile /home/RRP/data/jenkins_data/
        sudo chmod -R 777 /home/RRP/data/jenkins_data/tools/hudson.tasks.Maven_MavenInstallation/test/
        sudo chmod -R 777 /home/RRP/data/jenkins_data/tools/org.jenkinsci.plugins.docker.commons.tools.DockerTool/testdocker/
	sudo chmod -R 777 /var/run/docker.sock
        sudo docker restart newjenkins
    fi
else
    sudo mkdir data
    sudo mkdir data/jenkins_data
    sudo chmod -R 777 data/jenkins_data
    if findmnt -S /dev/xvdb | grep -F "TARGET" > /dev/null; then
	echo "Filesystem is mounted"
    else
	sudo mkfs -t ext4 -F /dev/xvdb
	sudo mount /dev/xvdb/ /home/ec2-user/data/jenkins_data
	sudo cp /etc/fstab /etc/fstab.orig
	sudo sed -i '$ a /dev/xvdb/  /home/ec2-user/data/jenkins_data  ext4  defaults  1  1'  /etc/fstab
    fi
    docker -v
    if [ $? -eq 127 ] ; then
        sudo yum -y update
	sudo yum install -y git
        sudo yum install -y docker
	echo 'OPTIONS="--insecure-registry=34.224.201.94:5000"' >> /etc/sysconfig/docker
        sudo service docker start
        sudo docker pull jenkins
        sudo chmod -R 777 /home/ec2-user/data
        sudo chmod -R 777 /home/ec2-user/data/jenkins_data
        sudo docker run -d --restart=always --name newjenkins -p 8082:8080 -p 50000:50000 -v /home/ec2-user/data/jenkins_data/:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -t jenkins
        sudo sleep 100
	sudo docker run -d -p 5000:5000 --restart=always --name registry registry:2
        sudo ex +g/authorizationStrategy/d -scwq /home/ec2-user/data/jenkins_data/config.xml
        sleep 40
        sudo cp -rf /home/ec2-user/files/credentials.xml /home/ec2-user/data/jenkins_data
        sudo cp -rf /home/ec2-user/files/hudson.tasks.Maven.xml /home/ec2-user/data/jenkins_data
        sudo cp -rf /home/ec2-user/files/org.jenkinsci.plugins.docker.commons.tools.DockerTool.xml /home/ec2-user/data/jenkins_data
        sudo cp -rf /home/ec2-user/files/tools /home/ec2-user/data/jenkins_data/
        sudo cp -rf /home/ec2-user/files/Dockerfile /home/ec2-user/data/jenkins_data/
        sudo chmod -R 777 /home/ec2-user/data/jenkins_data/tools/hudson.tasks.Maven_MavenInstallation/test/
        sudo chmod -R 777 /home/ec2-user/data/jenkins_data/tools/org.jenkinsci.plugins.docker.commons.tools.DockerTool/testdocker/
	sudo cp -rf /home/ec2-user/files/*.pem /home/ec2-user/data/jenkins_data
	sudo chmod -R 777 /home/ec2-user/data/jenkins_data/*.pem
	sudo chmod -R 777 /var/run/docker.sock
        sudo docker restart newjenkins
    else
	sudo yum install -y git
	echo 'OPTIONS="--insecure-registry=34.224.201.94:5000"' >> /etc/sysconfig/docker
        sudo service docker restart
        sudo docker pull jenkins
        sudo chmod -R 777 /home/ec2-user/data
        sudo chmod -R 777 /home/ec2-user/data/jenkins_data
        sudo docker run -d --restart=always --name newjenkins -p 8082:8080 -p 50000:50000 -v /home/ec2-user/data/jenkins_data/:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -t jenkins
        sudo sleep 100
	sudo docker run -d -p 5000:5000 --restart=always --name registry registry:2
        sudo ex +g/authorizationStrategy/d -scwq /home/ec2-user/data/jenkins_data/config.xml
        sleep 40
        sudo cp -rf /home/ec2-user/files/credentials.xml /home/ec2-user/data/jenkins_data
        sudo cp -rf /home/ec2-user/files/hudson.tasks.Maven.xml /home/ec2-user/data/jenkins_data
        sudo cp -rf /home/ec2-user/files/org.jenkinsci.plugins.docker.commons.tools.DockerTool.xml /home/ec2-user/data/jenkins_data
        sudo cp -rf /home/ec2-user/files/tools /home/ec2-user/data/jenkins_data/
        sudo cp -rf /home/ec2-user/files/Dockerfile /home/ec2-user/data/jenkins_data/
        sudo chmod -R 777 /home/ec2-user/data/jenkins_data/tools/hudson.tasks.Maven_MavenInstallation/test/
        sudo chmod -R 777 /home/ec2-user/data/jenkins_data/tools/org.jenkinsci.plugins.docker.commons.tools.DockerTool/testdocker/
	sudo cp -rf /home/ec2-user/files/*.pem /home/ec2-user/data/jenkins_data
	sudo chmod -R 777 /home/ec2-user/data/jenkins_data/*.pem
	sudo chmod -R 777 /var/run/docker.sock
        sudo docker restart newjenkins

    fi
fi
