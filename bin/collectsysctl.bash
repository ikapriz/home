for i in $(seq 1 8)
do
	ssh iad-mongo-usr10${i}-v240.ihr "sudo /sbin/sysctl -a" | sort > sysctl${i}.out
done
