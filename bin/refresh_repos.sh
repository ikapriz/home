#!/bin/bash

cd ~

for i in $(cat ~/bin/repo_list)
do
	organization=${i%%\/*}
	repo=${i##*\/}

	if [[ $organization == 'OPS-QAC1' && $repo == 'iheart-chef' ]]
	then
		master='qac1-exclusive'
	else
		master='master'
	fi

	if [[ -d $i ]]
	then
		echo "Refreshing $i"
		cd $i
		git checkout $master
		git pull
	else
		echo "Cloning $i"
		echo $organization
		echo $repo

		cd $organization
		echo "git clone  \"git@github.ihrint.com:${organization}/${repo}.git\""
		git clone "git@github.ihrint.com:${organization}/${repo}.git"
		git checkout $master
		git pull
	fi
	cd  ~
done
