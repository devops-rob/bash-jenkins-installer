#!/bin/bash

apps=(
      	'epel-release'
        'nano'
	      'net-tools'
        'wget'
	      'vim'
        'java-1.8.0-openjdk.x86_64'
    )

fwservice=(http https)

fwport=(8080/tcp 443/tcp)

#the below separates the list entry above to allow for loop to work on entire list
app=$( IFS=$'\n'; echo "${apps[*]}" )

#functions
function start-services {
    sudo systemctl start jenkins.service
    sudo systemctl enable jenkins.service
}

function app-install {
    for a in $app
    do
        yum install $app -y

    done
}

function java-path {
sudo cp /etc/profile /etc/profile_backup
    echo 'export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk' | sudo tee -a /etc/profile
    echo 'export JRE_HOME=/usr/lib/jvm/jre' | sudo tee -a /etc/profile
    source /etc/profile
    echo $JAVA_HOME
    echo $JRE_HOME
}

#install repository for Jenkins
function install-jenkins {
    wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
    sudo rpm --import http://pkg.jenkins-ci.org/redhat-stable/jenkins-ci.org.key
    yum install jenkins -y
    yum update -y
}
#Firewall config
function configure-firewalld {
    for port in $fwport
    do
        sudo firewall-cmd --zone=public --permanent --add-port=$fwport

    done

    for service in $fwservice
    do

        sudo firewall-cmd --zone=public --permanent --add-service=$fwservice

    done

    sudo firewall-cmd --reload
}

app-install
java-path
install-jenkins
configure-firewalld
start-services
