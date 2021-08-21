#!/bin/sh

gcloud container clusters get-credentials "$1"

vm_name=$(kubectl get nodes -o json | jq -r '.items[0].metadata.name')
access_config=$(gcloud compute instances describe "$vm_name" --format json | jq -r '.networkInterfaces[].accessConfigs[].name' 2> /dev/null)

if [ -n "$access_config" ]; then
  gcloud compute instances delete-access-config "$vm_name" --access-config-name="$access_config"
fi

gcloud compute instances add-access-config "$vm_name" --access-config-name="external-nat" --address="$2"
