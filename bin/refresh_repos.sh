#!/bin/bash

cd ~

for i in $(cat ~/bin/repo_list)
do
	if [[ -d $i ]]
	then
		echo "Refreshing $i"
		cd $i
		git checkout master
		git pull
	else
		echo "Cloning $i"
		organization=${i%%\/*}
		repo=${i##*\/}
		echo $organization
		echo $repo

		cd $organization
		echo "git clone  \"git@github.ihrint.com:${organization}/${repo}.git\""
		git clone "git@github.ihrint.com:${organization}/${repo}.git"
	fi
	cd  ~
done
