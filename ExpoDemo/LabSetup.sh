# ****************************************************************************
# Lab Set up contains: 
# 	- Check and Install Kubectl
#	- Create new GKE cluster in Kubernetes with 4 worker nodes
#	- Download and install Istio components(Service Mesh)
#	- Install Bookinfo application
#	- Setup Ingress Gateway for external access(outside the GKE cluster)
#	- Verify user's bookinfo access using GATEWAY_URL
# ****************************************************************************
#!/bin/bash
function setupKubectl(){

	KUBECTL_VERSION=$(kubectl version --short | grep Client)

	if [ "$KUBECTL_VERSION" == "" ]; then
		echo "kubectl is NOT installed. Installing kubectl"
		sudo apt-get update && sudo apt-get install -y apt-transport-https
		curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
		echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list

		sudo apt-get update
		sudo apt-get install -y kubectl

		echo "Kubectl is install .Continue to GKE cluster Install .................."

	else
	
		echo "kubectl version : " $KUBECTL_VERSION "is installed"
		echo "Continue to GKE cluster Install .................."
	fi

}

function setupGKECluster(){

	echo "Cluster Name Must be a match of regex '(?:[a-z](?:[-a-z0-9]{0,38}[a-z0-9])?)"
	read -p "Enter the gke cluster name = " CLUSTERNAME

	gcloud container clusters create $CLUSTERNAME \
	 --cluster-version=latest \
	 --zone us-central1-c \
	 --num-nodes 4
         
	GKE_STATUS=$(gcloud container clusters list | grep $CLUSTERNAME)

	sleep 10

	if [ "$GKE_STATUS" != "" ]; then
		echo "Setting up GKE cluster rolebinding as admin"

		kubectl create clusterrolebinding cluster-admin-binding \
  		--clusterrole=cluster-admin \
		--user=$(gcloud config get-value core/account)
	else
		echo  GKE cluster creation failed !! .Please select correct naming format for GKE cluster 
		exit 1;
	fi

}

function InstallIstio(){

	echo Checking if Istio is already Installed and in Path
 
	ISTIOCTL_VERSION=$(istioctl version | grep Version)

	if ([ "$ISTIOCTL_VERSION" == "" ] && [ ! -d $WORKDIR/istio-1.0.6 ]); then
		cd $WORKDIR
		echo Downloading Istio  
		curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.0.6 sh -
		export PATH="$PATH:$WORKDIR/istio-1.0.6/bin"

	else

		export PATH="$PATH:$WORKDIR/istio-1.0.6/bin"
		echo  Istio is already Installed proceeding to Istio Setup 

	fi
}



function setUpIstio(){

	echo " Install Istio with mutual authentication between sidecars"
	kubectl apply -f $WORKDIR/istio-1.0.6/install/kubernetes/istio-demo-auth.yaml

	echo " Check that pods are running under istio-system namespace"
	echo "Look for Istio base components :-pilot, mixer, ingress, egress & add-ons : prometheus, servicegraph, grafana)"
	sleep 60 

	kubectl get pods -n istio-system
	echo "Envoy sidecars can be automatically injected into each pod .We also need to enable sidecar injection for the namespace (‘default’) that we will use for our microservices. " 
	kubectl label namespace default istio-injection=enabled

	echo " verify that label was successfully applied"
	kubectl get namespace -L istio-injection
	sleep 60 
	echo " verify that label was successfully applied"
	kubectl get namespace -L istio-injection

	echo " Let’s deploy the BookInfo sample app now:"
	kubectl apply -f $WORKDIR/istio-1.0.6/samples/bookinfo/platform/kube/bookinfo.yaml
}

function InstallBookInfo(){

	echo " Let’s deploy the BookInfo gateway now:"
	kubectl apply -f $WORKDIR/istio-1.0.6/samples/bookinfo/networking/bookinfo-gateway.yaml

	export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
	export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
	export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
	echo Installation of bookInfo app is complete 
	echo Please open link $GATEWAY_URL/productpage in your browser



}

echo Checking if Kubectl is installed on your system 
echo Kubectl is required to connect to GKE cluster
setupKubectl
sleep 5 

echo Installing Google Kubernetes Cluster of 4 nodes 
read -p "Enter the location of the Istio set up = " WORKDIR

setupGKECluster
sleep 10 
InstallIstio
sleep 5 
setUpIstio
sleep 5
InstallBookInfo
