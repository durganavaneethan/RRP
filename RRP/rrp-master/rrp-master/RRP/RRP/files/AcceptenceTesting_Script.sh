if ! [ -f /sys/hypervisor/uuid ]; then
    sudo mkdir data
    sudo mkdir data/selenium-hub 
    sudo chmod -R 777 data/selenium-hub
    docker -v
    if [ $? -eq 127 ] ; then
        sudo apt-get update
        sudo apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
        sudo apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-trusty main'
        sudo apt-get update
        sudo apt-get install -y docker-engine
        sudo service docker start
        sudo docker run --restart=always --name selenium-hub -d -p 4444:4444 -v /home/RRP/data/selenium-hub:/selenium-hub selenium/hub:3.0.1-fermium
        sudo docker run --restart=always --name selenium-nodechrome -d --link selenium-hub:hub selenium/node-chrome:3.0.1-fermium
        sleep 30
        sudo docker run --restart=always --name selenium-nodefirefox -d --link selenium-hub:hub selenium/node-firefox:3.0.1-fermium
        sleep 40
    else
        sudo docker start
        sudo docker run --restart=always --name selenium-hub -d -p 4444:4444 -v /home/RRP/data/selenium-hub:/selenium-hub selenium/hub:3.0.1-fermium
        sudo docker run --restart=always --name selenium-nodechrome -d --link selenium-hub:hub selenium/node-chrome:3.0.1-fermium
        sleep 30
        sudo docker run --restart=always --name selenium-nodefirefox -d --link selenium-hub:hub selenium/node-firefox:3.0.1-fermium
        sleep 40

    fi
else
    sudo mkdir /home/ec2-user/data
    sudo mkdir /home/ec2-user/data/selenium-hub
    sudo chmod -R ugo+rw /home/ec2-user/data/selenium-hub
    if findmnt -S /dev/xvdb | grep -F "TARGET" > /dev/null; then
        echo Filesystem is mounted
    else
        sudo mkfs -t ext4 -F /dev/xvdb
        sudo mount /dev/xvdb /home/ec2-user/data/selenium-hub
        sudo cp /etc/fstab /etc/fstab.orig
        sudo sed -i '$ a /dev/xvdb /home/ec2-user/data/selenium-hub  ext4  defaults  1  1'  /etc/fstab
    fi
    docker -v
    if [ $? -eq 127 ] ; then
      sudo yum -y update
      sudo yum install -y git
      sudo yum install -y docker
      sudo service docker start
      sudo docker run --restart=always --name selenium-hub -d -p 4444:4444 -v /home/ec2-user/data/selenium-hub:/selenium-hub selenium/hub:3.0.1-fermium
      sleep 10
      sudo docker run --restart=always --name selenium-nodechrome -d --link selenium-hub:hub selenium/node-chrome:3.0.1-fermium
      sleep 30
      sudo docker run --restart=always --name selenium-nodefirefox -d --link selenium-hub:hub selenium/node-firefox:3.0.1-fermium
      sleep 40



    else
        sudo yum install -y git
        sudo service docker start
        sudo docker run --restart=always --name selenium-hub -d -p 4444:4444 -v /home/ec2-user/data/selenium-hub:/selenium-hub selenium/hub:3.0.1-fermium
        sleep 10
        sudo docker run --restart=always --name selenium-nodechrome -d --link selenium-hub:hub selenium/node-chrome:3.0.1-fermium
        sleep 30
        sudo docker run --restart=always --name selenium-nodefirefox -d --link selenium-hub:hub selenium/node-firefox:3.0.1-fermium
        sleep 40
        
    fi
fi

