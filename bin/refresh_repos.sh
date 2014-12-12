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

		if [[  $repo == 'ingestion' ]]
		then
			git clone "git@github.com:iheartradio/postgresingestion.git" ingestion
		else
			git clone "git@github.com:iheartradio/${repo}.git"
		fi

		git checkout master
		git pull origin master
	fi
	cd  ~
done
