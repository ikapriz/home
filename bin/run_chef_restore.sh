#!/bin/bash

# This directories are required for the script
MACHINE=`hostname -a`
BASENAME=`basename $0`
sdate=`date +'%Y%m%d_%H%M%S'`

#COMPONENTS="databag environment cookbook node client role "
COMPONENTS="role node environment cookbook"

function usage {
        echo $1

        echo "Usage: $0 -h <host_ip_or_name> -p <port> -d <backup_dir>[-s <days>]"
        echo "    <host_ip_or_name> - host ip or name for mongos instancei or one of the replica server"
        echo "    <port> - port number  listenserver on (default port number is 27017)"
        echo "    <days> - Remove backups older than <days>"
        echo "    <backup_dir> - Use this directory for backups"
	echo ""
        echo "Usage: $0 -f <config_file>"
	echo "  config file format:"
	echo "		host=<host_ip_or_name>"
	echo "		port=<port>"
	echo "		days=<days>"
        exit $2
}

function upload_cookbook
{
	
	for i in $*
	do
		name=${i%-*.*.*}
		version=${i##*-}

		knife cookbook create $name -o $COOKBOOKS  >$OUT 2>$ERR

		RETCODE=$?

		echo -n "Creating empty $i ($name $version): "

		if [[ $RETCODE -ne 0 ]]
		then
			echo  "FAIL"
			cat $OUT
			cat $ERR
			exit 1
		else
			echo "OK"
		fi

		sed -i "s/0.1.0/$version/" $COOKBOOKS/$name/metadata.rb

		knife cookbook upload $name -o $COOKBOOKS -d >$OUT 2>$ERR

		RETCODE=$?

		echo -n "Uploading empty $i ($name): "

		if [[ $RETCODE -ne 0 ]]
		then
			echo  "FAIL"
			cat $OUT
			cat $ERR
			exit 1
		else
			echo "OK"
		fi

		rm -rf $COOKBOOKS/$name
	done
	
	for i in $*
	do
		cp -r $COMPDIR/$i $COOKBOOKS/$name

		knife cookbook upload $name -o $COOKBOOKS -d >$OUT 2>$ERR

		RETCODE=$?

		echo -n "Uploading $i ($name): "

		if [[ $RETCODE -ne 0 ]]
		then
			echo  "FAIL"
			cat $OUT
			cat $ERR
			exit 1
		else
			echo "OK"
		fi

		rm -rf $COOKBOOKS/$name
	done
}

# set defaults

host=''
port=''
days=60
dir='/data/backups'

# Parse the parameters
while getopts ":h:p:f:s:d:" opt; do
  case $opt in
    h)
      host_par=$OPTARG
      ;;
    p)
      port_par=$OPTARG
      ;;
    s)
      days=$OPTARG
      ;;
    d)
      dir=$OPTARG
      ;;
    f)
      conffile=$OPTARG
      conffile_set=1
      ;;
    \?)
      usage "Invalid option: -$OPTARG"  1
      ;;
  esac
done

LOGDIR=`mktemp -d /var/log/chefdba/mongo_${BASENAME}_XXXXXXX`
LOCKFILE="/var/log/mongo/${BASENAME}_${port}.lock"
OUT="$LOGDIR/out"
ERR="$LOGDIR/err"
COOKBOOKS="$LOGDIR/COOKBOOKS"
mkdir $COOKBOOKS
DBAGLIST="$LOGDIR/dbaglist"

trap "rm -rf $LOGDIR $LOCKFILE" EXIT

LOG="/var/log/chefdba/${BASENAME}_${sdate}_${port}.log"

exec > >(tee $LOG)

for COMPONENT in $COMPONENTS
do
	COMPDIR="$dir/$COMPONENT"

	if [[ $COMPONENT == 'databag' ]]
	then
		COMPONENT="data bag"
	fi

	if [[ $COMPONENT == 'cookbook' ]]
	then
		cookbooks=`ls $COMPDIR| sort -r |tr "\\n" " "`

		upload_cookbook $cookbooks

	elif [[ $COMPONENT == 'environment' || $COMPONENT == 'node' || $COMPONENT == 'role' ]]
	then
		for comp in $(ls $COMPDIR)
		do
			if [[ $COMPONENT == 'environment' && $comp = '_default.json' ]]
			then
				continue
			fi

			knife $COMPONENT from file $COMPDIR/$comp >$OUT 2>$ERR

			RETCODE=$?

			echo -n "Uploading $COMPONENT $comp: "

			if [[ $RETCODE -ne 0 ]]
			then
				echo  "FAIL"
				cat $OUT
				cat $ERR
			else
				echo "OK"
			fi
		done

	elif [[ $COMPONENT == 'data bag' ]]
	then
			DBAGDIR="$COMPDIR/$i"
			mkdir $DBAGDIR >$OUT 2>$ERR

			RETCODE=$?

			echo -n "Creating data bag directory $DBAGDIR: "

			if [[ $RETCODE -ne 0 ]]
			then
				echo  "FAIL"
				cat $OUT
				cat $ERR
				exit 1
			else
				echo "OK"
			fi

			knife data bag show $i >$DBAGLIST 2>$ERR

			RETCODE=$?

			echo -n "Creating list if items for data bag $i: "

			if [[ $RETCODE -ne 0 ]]
			then
				echo  "FAIL"
				cat $DBAGLIST
				cat $ERR
			else
				echo "OK"
			fi

			for item in $(cat $DBAGLIST)
			do
				knife $COMPONENT edit $i $item -e /usr/bin/vi  <<-EOD >$OUT 2>$ERR
					:w $DBAGDIR/$item.json
					:q!
				EOD

				RETCODE=$?

				echo -n "Dumping $COMPONENT $i $item: "

				if [[ $RETCODE -ne 0 ]]
				then
					echo  "FAIL"
					cat $OUT
					cat $ERR
				else
					echo "OK"
				fi
			done
	else
		for i in $(cat $LIST)
		do
			knife $COMPONENT edit -e /usr/bin/vi $i <<-EOD >$OUT 2>$ERR
				:w $COMPDIR/$i.json
				:q!
			EOD

			RETCODE=$?

			echo -n "Dumping $COMPONENT $i: "

			if [[ $RETCODE -ne 0 ]]
			then
				echo  "FAIL"
				cat $OUT
				cat $ERR
			else
				echo "OK"
			fi
		done
	fi
done

