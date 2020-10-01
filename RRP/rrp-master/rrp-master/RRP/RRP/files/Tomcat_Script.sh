if ! [ -f /sys/hypervisor/uuid ]; then
    sudo mkdir data
    sudo mkdir data/logs
    sudo mkdir data/work
    sudo mkdir data/temp
    sudo mkdir data/hsperfdata_root
    sudo chmod -R ugo+rw data/logs
    sudo chmod -R ugo+rw data/work
    sudo chmod -R ugo+rw data/temp
    sudo chmod -R ugo+rw data/hsperfdata_root
    docker -v
    if [ $? -eq 127 ] ; then
        sudo apt-get update
        sudo apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
        sudo apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-trusty main'
        sudo apt-get update
        sudo apt-get install -y docker-engine
        sudo service docker start
        sudo docker run -d --restart=always --name Tomcat -p 8088:8080 -v /home/RRP/data/logs/:/opt/tomcat/logs -v /home/RRP/data/work/:/opt/tomcat/work  -v /home/RRP/data/temp/:/opt/tomcat/temp -v /home/RRP/hsperfdata_root/:/tmp/hsperfdata_root consol/tomcat-7.0
        sleep 50
    else
        sudo service docker start
        sudo docker run -d --restart=always --name Tomcat -p 8088:8080 -v /home/RRP/data/logs/:/opt/tomcat/logs -v /home/RRP/data/work/:/opt/tomcat/work  -v /home/RRP/data/temp/:/opt/tomcat/temp -v /home/RRP/hsperfdata_root/:/tmp/hsperfdata_root consol/tomcat-7.0
        sleep 50
    fi
else 
    sudo mkdir /home/ec2-user/data
    sudo mkdir /home/ec2-user/data/logs
    sudo mkdir /home/ec2-user/data/work
    sudo mkdir /home/ec2-user/data/temp
    sudo mkdir /home/ec2-user/data/hsperfdata_root
    if findmnt -S /dev/xvdb | grep -F "TARGET" > /dev/null; then
	echo Filesystem is mounted
    else
    	sudo mkfs -t ext4 -F /dev/xvdb
        sudo mount /dev/xvdb /home/ec2-user/data/logs
        sudo mount /dev/xvdb /home/ec2-user/data/work
        sudo mount /dev/xvdb /home/ec2-user/data/temp
        sudo mount /dev/xvdb /home/ec2-user/data/hsperfdata_root
        sudo cp /etc/fstab /etc/fstab.orig
        sudo sed -i '$ a /dev/xvdb /home/ec2-user/data/logs  ext4  defaults  1  1'  /etc/fstab
        sudo sed -i '$ a /dev/xvdb /home/ec2-user/data/work  ext4  defaults  1  1'  /etc/fstab
        sudo sed -i '$ a /dev/xvdb /home/ec2-user/data/temp  ext4  defaults  1  1'  /etc/fstab
        sudo sed -i '$ a /dev/xvdb /home/ec2-user/data/hsperfdata_root  ext4  defaults  1  1'  /etc/fstab
    fi
    sudo chmod -R ugo+rw /home/ec2-user/data/logs
    sudo chmod -R ugo+rw /home/ec2-user/data/work
    sudo chmod -R ugo+rw /home/ec2-user/data/temp
    sudo chmod -R ugo+rw /home/ec2-user/data/hsperfdata_root
    docker -v
    if [ $? -eq 127 ] ; then
        sudo yum -y update
	sudo yum install -y git
	sudo yum install -y docker
        sudo service docker start
        sudo docker run -d --restart=always --name Tomcat -p 8088:8080 -v /home/ec2-user/data/logs/:/opt/tomcat/logs -v /home/ec2-user/data/work/:/opt/tomcat/work  -v /home/ec2-user/data/temp/:/opt/tomcat/temp -v /home/ec2-user/hsperfdata_root/:/tmp/hsperfdata_root consol/tomcat-7.0
        sleep 50
    else
	sudo yum install -y git
        sudo service docker start
        sudo docker run -d --restart=always --name Tomcat -p 8088:8080 -v /home/ec2-user/data/logs/:/opt/tomcat/logs -v /home/ec2-user/data/work/:/opt/tomcat/work  -v /home/ec2-user/data/temp/:/opt/tomcat/temp -v /home/ec2-user/hsperfdata_root/:/tmp/hsperfdata_root consol/tomcat-7.0
        sleep 50
    fi
fi
