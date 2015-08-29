#!/bin/bash

# gpg --output chef/carp-staging/client.pem.gpg --encrypt --recipient ikapriz@gmail.com chef/carp-staging/client.pem

if [[ "$1" == "" ]]
then
	echo "Please enter name of the private key file or 'none'"
	exit 1
fi


if [[ "$2" != "" ]]
then
	base=$2
else
	base=$HOME
fi

echo "Setting up the home environment in $base"

if [[ ! -d $base ]]
then
	mkdir $base
	
	if [[ $? != 0 ]]
	then
		exit 1
	fi
fi

if [[ "$1" != "none" ]]
then
	gpg --no-use-agent --output - $1 | gpg --import | tee 

	if [[ $? -ne 0 ]]
	then
		exit 1
	fi

	#decrypt

	for encoded in $(find . -name "*.gpg")
	do
		decoded=${encoded%%.gpg}
		gpg --output $decoded --decrypt $encoded

		if [[ $? -ne 0 ]]
		then
			exit 1
		fi
	done
fi

read -p "Move config files to $base - please enter Y or N: " -n 1 -r

echo $REPLY;

echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

for sourcefile in $(find .)
do
	echo $sourcefile
	destfile="${base}${sourcefile#.}"
	echo $destfile
done

