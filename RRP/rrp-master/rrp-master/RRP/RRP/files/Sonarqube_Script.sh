if ! [ -f /sys/hypervisor/uuid ]; then
    sudo mkdir /home/RRP/data
    sudo mkdir /home/RRP/data/docker
    sudo mkdir /home/RRP/data/docker/sonar
    sudo mkdir /home/RRP/data/docker/sonar/extn
    docker -v
	if [ $? -eq 127 ] ; then
            sudo apt-get update
            sudo apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
            sudo apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-trusty main'
            sudo apt-get update
            sudo apt-get install -y docker-engine
	    sudo service docker start
	    curl -L https://github.com/docker/compose/releases/download/1.7.0/docker-compose-`uname -s`-`uname -m` > ./docker-compose
    	    sleep 20
    	    sudo mv ./docker-compose /usr/bin/docker-compose
	    sudo chmod +x /usr/bin/docker-compose
	    sleep 30
	    sudo docker-compose -f /home/RRP/files/docker-compose.yml up -d
	    sleep 100
	    cd /home/RRP/data/docker/sonar/extn/
	    sudo mkdir plugins
	    cd /home/RRP/data/docker/sonar/extn/plugins
	    sleep 20
	    sudo docker stop files_sonarqube_1
	    sleep 20
	    sudo docker stop files_db_1
	    sleep 20
	    sudo docker-compose -f /home/RRP/files/docker-compose.yml up -d
	    sleep 20
        else
	    sudo service docker start
            curl -L https://github.com/docker/compose/releases/download/1.7.0/docker-compose-`uname -s`-`uname -m` > ./docker-compose
            sleep 20
            sudo mv ./docker-compose /usr/bin/docker-compose
            sudo chmod +x /usr/bin/docker-compose
            sleep 30
            sudo docker-compose -f /home/RRP/files/docker-compose.yml up -d
            sleep 100
            cd /home/RRP/data/docker/sonar/extn/
            sudo mkdir plugins
            cd /home/RRP/data/docker/sonar/extn/plugins
            sleep 20
            sudo docker stop files_sonarqube_1
            sleep 20
            sudo docker stop files_db_1
            sleep 20
            sudo docker-compose -f /home/RRP/files/docker-compose.yml up -d
            sleep 20
	fi
else
    sudo mkdir /home/ec2-user/data
    sudo mkdir /home/ec2-user/data/docker
    sudo mkdir /home/ec2-user/data/docker/sonar
    sudo mkdir /home/ec2-user/data/docker/sonar/extn
    if findmnt -S /dev/xvdb | grep -F "TARGET" > /dev/null; then
	echo Filesystem is mounted
    else
        sudo mkfs -t ext4 -F /dev/xvdb
        sudo mount /dev/xvdb /home/ec2-user/data/docker
        sudo cp /etc/fstab /etc/fstab.orig
        sudo sed -i '$ a /dev/xvdb  /home/ec2-user/data/docker  ext4  defaults  1  1'  /etc/fstab
    fi
    docker -v
        if [ $? -eq 127 ] ; then
            sudo yum -y update
	    sudo yum install -y git
            sudo yum install -y docker
            sudo service docker start
            curl -L https://github.com/docker/compose/releases/download/1.7.0/docker-compose-`uname -s`-`uname -m` > ./docker-compose
            sleep 20
            sudo mv ./docker-compose /usr/bin/docker-compose
            sudo chmod +x /usr/bin/docker-compose
            sleep 30
            docker-compose -f /home/ec2-user/files/docker-compose.yml up -d
            sleep 100
            cd /home/ec2-user/data/docker/sonar/extn/
            sudo mkdir plugins
            cd /home/ec2-user/data/docker/sonar/extn/plugins
            sleep 20
            sudo cp -rf /home/ec2-user/files/sonar-java-plugin-4.2.jar /home/ec2-user/data/docker/sonar/extn/plugins
            sleep 20
            sudo docker stop files_sonarqube_1
            sleep 20
            sudo docker stop files_db_1
            sleep 20
            docker-compose -f /home/ec2-user/files/docker-compose.yml up -d
            sleep 20
        else
	    sudo yum install -y git
            sudo service docker start
            curl -L https://github.com/docker/compose/releases/download/1.7.0/docker-compose-`uname -s`-`uname -m` > ./docker-compose
            sleep 20
            sudo mv ./docker-compose /usr/bin/docker-compose
            sudo chmod +x /usr/bin/docker-compose
            sleep 30
            docker-compose -f /home/ec2-user/files/docker-compose.yml up -d
            sleep 100
            cd /home/ec2-user/data/docker/sonar/extn/
            sudo mkdir plugins
            cd /home/ec2-user/data/docker/sonar/extn/plugins
            sleep 20
            sudo cp -rf /home/ec2-user/files/sonar-java-plugin-4.2.jar /home/ec2-user/data/docker/sonar/extn/plugins
            sleep 20
            sudo docker stop files_sonarqube_1
            sleep 20
            sudo docker stop files_db_1
            sleep 20
            docker-compose -f /home/ec2-user/files/docker-compose.yml up -d
            sleep 20
        fi
fi
