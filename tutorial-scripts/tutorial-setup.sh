#!/usr/bin/bash
cd "$(dirname "$0")"

oc adm groups new devops

oc apply -f ./master.key
oc delete pod -n kube-system -l name=sealed-secrets-controller
