#!/bin/bash

cd ~

for i in $(cat ~/bin/repo_list)
do
	organization=${i%%\/*}
	repo=${i##*\/}

	if [[ -d $i ]]
	then
		echo "Refreshing $i"
		cd $i
		git checkout master
		git pull
	else
		echo "Cloning $i"
		echo $organization
		echo $repo

		cd $organization

		if [[ $repo == 'iheart-chef' || $repo == 'authorization' || $repo == 'ingestion' || $repo == 'postgresql' || $repo == 'mongodb' ]]
		then
			git clone "git@github.ihrint.com:${organization}/${repo}.git"
			git checkout master
			git pull origin master
		else
			git clone "git@github.com:iheartradio/${repo}.git"
			git checkout master
			git pull origin master
		fi
	fi
	cd  ~
done
