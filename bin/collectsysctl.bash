for i in $(seq 1 8)
do
	ssh iad-mongo-usr10${i}-v240.ihr "sudo /sbin/sysctl -a" | sort > sysctl_usr10${i}.out
done
for i in $(seq 1 4)
do
	ssh iad-mongo-fac10${i}-v240.ihr "sudo /sbin/sysctl -a" | sort > sysctl_fac10${i}.out
done
for i in $(seq 1 3)
do
	ssh iad-mongo-shared10${i}-v240.ihr "sudo /sbin/sysctl -a" | sort > sysctl_shared10${i}.out
done
