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
		echo "Checking $i"
		cd $i
		git status
	fi
	cd  ~
done
