#!/bin/bash

for item in $(cat allips.csv)
do
  while IFS="," read -r net_ip project
  do
    echo "Getting Name and Zone of instance $net_ip and project $project"
    echo -n "$project", >> instances.csv
    echo $(gcloud compute instances list --project $project --filter="status=RUNNING" --filter="INTERNAL_IP=$net_ip" --format="csv[no-heading](name,networkInterfaces[0].networkIP,zone)") >> instances.csv
  done< <(echo $item)
done


for line in $(cat instances.csv)
do
  while IFS="," read -r project_id name network_ip zone
  do
    echo "getting sshkeys metadata for instance $name ip $network_ip and zone $zone of project $project_id";
    gcloud compute instances describe $name --project $project_id --zone $zone --format="get(metadata.items.key['ssh-keys'].value)" > ssh-keys.txt; cat ssh-keys.txt | grep 'google-ssh' > ssh-metadata.txt;
    echo "setting sshkeys metadata for instance $name ip $network_ip and zone $zone of project $project_id"
    gcloud compute instances add-metadata $name --metadata-from-file ssh-keys=ssh-metadata.txt --project $project_id --zone $zone
    rm -rf ssh-keys.txt;
    rm -rf ssh-metadata.txt;
  done< <(echo $line)
done
