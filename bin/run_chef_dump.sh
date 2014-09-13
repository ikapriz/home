#!/bin/bash

# This directories are required for the script
MACHINE=`hostname -a`
BASENAME=`basename $0`
sdate=`date +'%Y%m%d_%H%M%S'`
NAGIOS_HOST=$(hostname)
NAGIOS_HOST=${NAGIOS_HOST%%.*}
NAGIOS_SERVICE='Mongodb-Backups'

COMPONENTS="databag environment cookbook node client role "

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
LIST="$LOGDIR/LIST"
DBAGLIST="$LOGDIR/dbaglist"

trap "rm -rf $LOGDIR $LOCKFILE" EXIT

LOG="/var/log/chefdba/${BASENAME}_${sdate}_${port}.log"

exec > >(tee $LOG)

# Create backup directory
dir="$dir/${BASENAME}_${sdate}"

mkdir $dir >$OUT 2>$ERR
RETCODE=$?

echo -n "Creating backup directory $dir: "
if [[ $RETCODE -ne 0 ]]
then
	echo  "FAIL"
	cat $OUT
	cat $ERR
else
	echo "OK"
fi

for COMPONENT in $COMPONENTS
do
	COMPDIR="$dir/$COMPONENT"

	mkdir $COMPDIR >$OUT 2>$ERR
	RETCODE=$?

	echo -n "Creating component directory $COMPDIR: "
	if [[ $RETCODE -ne 0 ]]
	then
		echo  "FAIL"
		cat $OUT
		cat $ERR
	else
		echo "OK"
	fi

	if [[ $COMPONENT == 'databag' ]]
	then
		COMPONENT="data bag"
	fi

	if [[ $COMPONENT == 'cookbook' ]]
	then
		knife $COMPONENT list -a >$LIST 2>$ERR
		RETCODE=$?
	else
		knife $COMPONENT list >$LIST 2>$ERR
		RETCODE=$?
	fi

	echo -n "Generating list of ${COMPONENT}s: "
	if [[ $RETCODE -ne 0 ]]
	then
		echo  "FAIL"
		cat $LIST
		cat $ERR
	else
		echo "OK"
	fi

	if [[ $COMPONENT == 'cookbook' ]]
	then

		while read cookbook versions 
		do
			for v in $versions
			do
				echo -n "Dumping $COMPONENT $cookbook version $v: "
				knife cookbook download $cookbook $v -d $COMPDIR >$OUT 2>$ERR

				RETCODE=$?

				if [[ $RETCODE -ne 0 ]]
				then
					echo  "FAIL"
					cat $OUT
					cat $ERR
				else
					echo "OK"
				fi

			done
		done < $LIST

	elif [[ $COMPONENT == 'data bag' ]]
	then
		for i in $(cat $LIST)
		do
			DBAGDIR="$COMPDIR/$i"
			mkdir $DBAGDIR >$OUT 2>$ERR

			RETCODE=$?

			echo -n "Creating data bag directory $DBAGDIR: "

			if [[ $RETCODE -ne 0 ]]
			then
				echo  "FAIL"
				cat $OUT
				cat $ERR
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

