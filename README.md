# k8-cluster

Deploying your first Kubernetes cluster on AWS using Kops 

Intro 

Kubernetes is an open source platform designed for managing docker containers across hosts, automating deployments, scaling, and maintenance of applications. The project was started by Google and is one of the leading tools in Container Orchestration. In this blog post we are going to deploy a Kubernetes cluster on AWS using Kops. Kops is short for Kubernetes Ops and is an official Kubernetes project for managing Kubernetes clusters. It allows you to create, destroy, upgrade and maintain clusters from the command line.  

Tools 

In order to follow along with this blog post you will need kops to automate the provisioning and configuration of the Kubernetes cluster, kubectl for controlling the Kubernetes cluster, and aws cli to create an s3 bucket. 

If you already have pip installed you can install aws cli using the following: 

$pip install awscli –upgrade ---user 

You'll want to configure the aws cli by running the the following command 

$aws configure 

To install Kubectl, run the following: 

$wget -O kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl 

$chmod +x ./kubectl 

$sudo mv ./kubectl /usr/local/bin/kubectl 

To install Kops, run the following: 

$wget -O kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64  

$chmod +x ./kops 

$sudo mv ./kops /usr/local/bin/kops 

Create S3 Bucket 

Now we'll need an S3 bucket to store the state of our Kubernetes cluster. Kops uses this bucket to store information about the cluster like how many nodes exist and the version of Kubernetes running. 

$aws s3 mb s3://k8-store --region us-east-2 

Create SSH Key 

Here we will create an SSH key to access the cluster nodes. 

$ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_k8 

Create Cluster with Kops 

Using Kops we can now create a cluster using the previously created ssh key and the default kops configuration. 

$kops create cluster --name k8mason.k8s.local --zones us-east-2b --state s3://k8mason --yes 

The 'kops create cluster' command creates the cloud based resources your cluster needs to operate like VPC, EC2 instances, security groups to support the cluster. It will take a few minutes for the infrastructure to be created and for Kubernetes to be installed on the EC2 instances. 

When the cluster is finished being created you can run the following command to validate it and see the nodes. This will also give you the DNS name of the ELB for master which we will use later. 

$kops validate cluster 

The default kops configuration will launch two nodes of type t2.medium and one Master of type c4.large.  

Setup Dashboard 

Now that we have the cluster deployed we can create the dashboard by running the following: 

$kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml 

To login to the dashboard you'll need the credentials created by Kops. Execute the following command to get the credentials 

$kops get secrets kube --type secret –oplaintext 

Appending /ui to Master's ELB DNS name and login with the admin username and password you got from the command above. You now have access to the Dashboard. 

Destroy Cluster 

To destroy the cluster using kops, we run the following command: 

$kops delete cluster --name k8mason.k8s.local --yes 

 

 

 

 

 

 

 

 

 
