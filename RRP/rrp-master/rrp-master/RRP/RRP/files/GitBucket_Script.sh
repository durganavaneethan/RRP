if ! [ -f /sys/hypervisor/uuid ]; then
    sudo mkdir data
    sudo mkdir data/gitbucket
    sudo chmod -R 777 data/gitbucket
    docker -v
    if [ $? -eq 127 ] ; then
        sudo apt-get update
        sudo apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
        sudo apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-trusty main'
        sudo apt-get update
        sudo apt-get install -y docker-engine
        sudo service docker start
        sudo docker run --restart=always --name gitbucket -d -p 8081:8080 -v /home/RRP/data/gitbucket:/gitbucket f99aq8ove/gitbucket
    else
        sudo service docker start
        sudo docker run --restart=always --name gitbucket -d -p 8081:8080 -v /home/RRP/data/gitbucket:/gitbucket f99aq8ove/gitbucket
        sudo docker -v
    fi
else
    sudo mkdir /home/ec2-user/data
    sudo mkdir /home/ec2-user/data/gitbucket
    sudo chmod -R ugo+rw /home/ec2-user/data/gitbucket
    if findmnt -S /dev/xvdb | grep -F "TARGET" > /dev/null; then
	echo Filesystem is mounted
    else
        sudo mkfs -t ext4 -F /dev/xvdb
        sudo mount /dev/xvdb /home/ec2-user/data/gitbucket
        sudo cp /etc/fstab /etc/fstab.orig
        sudo sed -i '$ a /dev/xvdb /home/ec2-user/data/gitbucket  ext4  defaults  1  1'  /etc/fstab
    fi
    docker -v
    if [ $? -eq 127 ] ; then
        sudo yum -y update
	sudo yum install -y git
        sudo yum install -y docker
        sudo service docker start
        sudo docker run --restart=always --name gitbucket -d -p 8081:8080 -v /home/ec2-user/data/gitbucket:/gitbucket f99aq8ove/gitbucket
        sudo docker -v
        sleep 40
        sudo docker restart gitbucket
    else
	sudo yum install -y git
        sudo service docker start
        sudo docker run --restart=always --name gitbucket -d -p 8081:8080 -v /home/ec2-user/data/gitbucket:/gitbucket f99aq8ove/gitbucket
        sudo docker -v
        sleep 40
        sudo docker restart gitbucket
    fi
fi

