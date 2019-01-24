
# ****************************************************************************
# Purpose of the script: 
#	- Install Bookinfo application
#	- Setup LoadBalancer IP for external access
#
# Supported platforms:
#	- Vanilla Kubernetes, Linkerd, Consul.
#
# Prerequisite(s):
#	- Cluster setup done and you are connected to it.
#	
# ****************************************************************************

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

