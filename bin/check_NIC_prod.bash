#!/bin/bash

for i in $(seq 1 6)
do
	ssh --StrictHostKeyChecking=no "iad-mongo-usr10${i}-prod.ihr" "sudo grep NIC /var/log/messages"
done

for i in $(seq 1 4)
do
	ssh --StrictHostKeyChecking=no "iad-mongo-fac10${i}-prod.ihr" "sudo grep NIC /var/log/messages"
done

for i in $(seq 1 3)
do
	ssh --StrictHostKeyChecking=no "iad-mongo-shared10${i}-prod.ihr" "sudo grep NIC /var/log/messages"
done

