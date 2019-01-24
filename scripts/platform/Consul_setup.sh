#!/bin/bash

####Install pre-reqs for Consul cluster #########
# The following clients must be installed on the machine to use this set up script:
#
#*** Working GIT client
#** [consul](https://www.consul.io/downloads.html) 1.4.0-rc
#* [cfssl](https://pkg.cfssl.org) and [cfssljson](https://pkg.cfssl.org) 1.2
# Set consul and cfssl and cfssljson in UNIX  path 

# Uncheck Cleanup script to delete consul cluster


function create-cluster()
{
 	gcloud container clusters create consul --cluster-version=latest --num-nodes=4
}

function create-clusterrole()
{
	kubectl create clusterrolebinding myname-cluster-admin-binding \
  --clusterrole=cluster-admin \
  --user=$(gcloud config get-value core/account) 
}

function clone-repo()
{
	if [ ! -d "$consuldir" ] ; then
        echo "Cloning repo in your WORKDIR"
		git clone https://github.com/kelseyhightower/consul-on-kubernetes.git
	else

        echo "Found previous git clones. Delete dir consul-on-kubernetes and try again"
		exit 1;
	fi
}


function create-ca()
{
	cfssl gencert -initca consul-on-kubernetes/ca/ca-csr.json | cfssljson -bare ca
}


function create-consul-tls-certs()
{
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=consul-on-kubernetes/ca/ca-config.json \
  -profile=default \
   consul-on-kubernetes/ca/consul-csr.json | cfssljson -bare consul
}

function create-gossip()
{

GOSSIP_ENCRYPTION_KEY=$(consul keygen)
kubectl create secret generic consul \
  --from-literal="gossip-encryption-key=${GOSSIP_ENCRYPTION_KEY}" \
  --from-file=ca.pem \
  --from-file=consul.pem \
  --from-file=consul-key.pem

}

function kubectl-commands-consul(){
	##Store the Consul server configuration file in a ConfigMap:

kubectl create configmap consul --from-file=consul-on-kubernetes/configs/server.json

#Create a headless service to expose each Consul member internally to the cluster:

kubectl create -f consul-on-kubernetes/services/consul.yaml

#Create the Consul Service Account

kubectl apply -f consul-on-kubernetes/serviceaccounts/consul.yaml

kubectl apply -f consul-on-kubernetes/clusterroles/consul.yaml

#Create the Consul StatefulSet

#Deploy a three (3) node Consul cluster using a StatefulSet:

kubectl create -f consul-on-kubernetes/statefulsets/consul.yaml

#Each Consul member will be created one by one. Verify each member is Running before moving to the next step.

echo " COnsul set up complete ... waiting for consul pods to come up "
echo " COnsul set up complete ... waiting for consul pods to come up "
echo " COnsul set up complete ... waiting for consul pods to come up "
echo " COnsul set up complete ... waiting for consul pods to come up "

sleep 60
kubectl get pods
}

function healthCheck()
{
	consul members
}

function port-forwarding()
{
	kubectl port-forward consul-0 8500:8500
}

function cleanup()
{

read -p "Enter the gke cluster name = " RMCLUSTERNAME
read -p "Enter the location of the set up = " RMWORKDIR

if [[ -d "${RMWORKDIR}" && ! -L "${RMWORKDIR}" ]] ; then
    echo "Found directory deleting previous working directory"
    rm -rf $RMWORKDIR
else
    echo "Invalid directory path ... Exiting"
        exit 1;
fi


rm ca-key.pem ca.csr ca.pem consul-key.pem consul.csr consul.pem
kubectl delete statefulset consul
kubectl delete pvc data-consul-0 data-consul-1 data-consul-2
kubectl delete svc consul
kubectl delete jobs consul-join
kubectl delete secrets consul
kubectl delete configmaps consul
gcloud container clusters delete RMCLUSTERNAME

}

read -p "Enter the gke cluster name = " CLUSTERNAME
read -p "Enter the location of the set up = " WORKDIR

if [[ -d "${WORKDIR}" && ! -L "${WORKDIR}" ]] ; then
    echo "Found directory ,, checking previously downloaded git clones"
    cd $WORKDIR
else
    echo "Invalid directory path ... Exiting now"
	exit 1;
fi

consuldir="consul-on-kubernetes"


clone-repo
echo "Installing consul cluster $CLUSTERNAME in $WORKDIR"
create-cluster
sleep 20
echo " Installed Kube cluster ... configuring consul "
create-clusterrole
sleep 10
create-ca
sleep 10
create-consul-tls-certs
sleep 10
create-gossip
sleep 10
kubectl-commands-consul
echo " Forwarding Port to start consul - UI "
port-forwarding & 
sleep 10
echo " Running Healthcheck "
healthCheck
echo " Open UI - http://127.0.0.1:8500/ui/dc1/services/consul "
