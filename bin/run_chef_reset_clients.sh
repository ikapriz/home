#!/bin/bash



for client in "$@"
do
	echo "running $client"
	ssh $client "sudo cat /etc/ssh/sshd_config"
	ssh $client "sudo sed -i.bak 's/^\(PermitRootLogin \).*/\1yes/' /etc/ssh/sshd_config"
	ssh $client "sudo cat /etc/ssh/sshd_config"
	ssh $client "sudo /sbin/service sshd restart"
	ssh $client "sudo rm -rf /etc/chef"
	ssh $client "sudo /usr/bin/curl -O https://www.opscode.com/chef/install.sh "
	ssh $client "sudo /bin/bash install.sh"
	ssh $client "sudo rpm -qa | grep chef"
	ssh $client "sudo /bin/rpm -e chef-12.0.3-1.x86_64"
	knife client delete $client -y
	knife node delete $client -y
	knife bootstrap $client
	knife node from file ~/OPS/iheart-chef/node_json/$client.json
	ssh $client "sudo chef-client -l debug"

done
