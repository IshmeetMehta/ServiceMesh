
# ****************************************************************************
# Purpose of the script: 
# 	- Create new cluster in Kubernetes
#	- Check and download Istio bookinfo samples
#	- Install Bookinfo application
#	- Setup LoadBalancer IP for external access
#
# ****************************************************************************

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

echo ***************************************************************
echo Cluster $CLUSTER_NAME created.
echo ***************************************************************

echo Do you want to deploy sample app [Y/n]?
read SAMPLE_APP_DEPLOY

if [ "$SAMPLE_APP_DEPLOY" != "Y" ]; then
	exit 0
fi

# Initialize environment variables
ISTIO_VERSION=1.0.5
NAME="istio-$ISTIO_VERSION"

echo Check if Istio Samples exists in the system
ISTIOCTL_VERSION=$(istioctl version | grep Version)

if [ "$ISTIOCTL_VERSION" == "" ]; then
	echo Downloading Istio samples...
	curl -L https://git.io/getLatestIstio | sh -
	export PATH=$PWD/$NAME/bin:$PATH
else
	echo "Istio samples already downloaded"
fi

echo Deploying Bookinfo application...
kubectl apply -f $NAME/samples/bookinfo/platform/kube/bookinfo.yaml

echo Waiting for a min to complete the installation bookinfo app and services...
sleep 60

echo Verify that application has been deployed correctly
kubectl get services
kubectl get pods

echo Setup loadBalancer IP for bookinfo application
kubectl patch svc productpage -p '{"spec":{"type":"LoadBalancer"}}'

echo sleep 60 sec for external IP to be ready...
sleep 60

echo Getting External IP...
export LOADBALANCER_IP=$(kubectl get svc productpage -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export PORT=$(kubectl get svc productpage -o jsonpath='{.spec.ports[0].port}')
export GATEWAY_URL=$LOADBALANCER_IP:$PORT

echo $GATEWAY_URL

echo curl -o /dev/null -s -w \"%{http_code}\\n\" http://${GATEWAY_URL}/api/v1/products
curl -o /dev/null -s -w "%{http_code}\\n" http://${GATEWAY_URL}/api/v1/products

# end of script

