#!/bin/sh

gcloud container clusters get-credentials "$1" --zone="$2"

ip=$(kubectl get nodes -o json | jq -r '.items[].status.addresses[0] | select(.type == "InternalIP") | .address')
kubectl patch svc ingress-nginx-controller -n ingress-nginx -p="{\"spec\":{\"externalIPs\":[\"$ip\"]}}"
