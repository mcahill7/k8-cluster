#!/bin/bash

export KOPS_STATE_STORE=s3://k8mason
ssh-keygen -t rsa -b 4096 -P "" -f ~/.ssh/id_rsa
kops create secret --name k8mason.k8s.local sshpublickey admin -i ~/.ssh/id_rsa.pub
kops create cluster --name k8mason.k8s.local --zones us-east-2b --state s3://k8mason --yes