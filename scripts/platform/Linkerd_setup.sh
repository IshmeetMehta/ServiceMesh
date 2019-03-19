
# ****************************************************************************
# Purpose of the script: 
# 	- Check and Install Kubectl
#	- Create new cluster in Kubernetes
#	- Download and Install Linkerd
#	- Install Emoji sample app
#	- Enable LoadBalancer for Linkerd-web app
# ****************************************************************************

echo Check and install Kubectl if it does not exist

KUBECTL_VERSION=$(kubectl version --short | grep Client)

if [ "$KUBECTL_VERSION" == "" ]; then
	echo "kubectl is NOT installed. Installing kubectl"
	sudo apt-get update && sudo apt-get install -y apt-transport-https
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
	echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
	sudo apt-get update
	sudo apt-get install -y kubectl
fi

read -p "Enter zone name ["us-central1-c"]: " ZONE_NAME
ZONE_NAME=${ZONE_NAME:-"us-central1-c"}

echo Enter Cluster Name [lowercase letters ONLY]
read CLUSTER_NAME

echo Creating Cluster...
gcloud container clusters create $CLUSTER_NAME \
	 --cluster-version=latest \
	 --machine-type=n1-standard-2 \
	 --zone $ZONE_NAME \
	 --num-nodes 4

echo Creating ClusterRoleBinding ...

kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole=cluster-admin \
  --user=$(gcloud config get-value core/account)
	
echo Installing Linked2 CLI ...
curl -sL https://run.linkerd.io/install | sh

echo Adding Linkerd2 to path
export PATH=$PATH:$HOME/.linkerd2/bin

L2_VERSION = $(linkerd version | grep Client)
if [ "$L2_VERSION" == "" ]; then
   echo "LINKERED Client Could NOT be installed"
   exit 1 # Stops script execution right here
else
	echo "LINKERED Client is installed"
fi

echo Installing Linkerd onto the cluster with automatic proxy injection enabled...
linkerd install --proxy-auto-inject | kubectl apply -f -

echo Checking linkerd status...
linkerd check

echo Exposing linkerd-web as Load Balancer...
kubectl patch svc linkerd-web -p '{"spec":{"type":"LoadBalancer"}}' -n linkerd

kubectl -n linkerd get deploy

echo ****************************************************
echo Cluster created and Linkerd installed successfully
echo ****************************************************

echo Do you want to deploy Emoji sample app [Y/n]?

read SAMPLE_APP_DEPLOY
if [ "$SAMPLE_APP_DEPLOY" == "Y" ]; then
	curl -sL https://run.linkerd.io/emojivoto.yml | kubectl apply -f -
	kubectl get -n emojivoto deploy -o yaml | linkerd inject - | kubectl apply -f -  
fi

# end of script