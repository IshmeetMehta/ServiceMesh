

# ************************************************************************************************
# Purpose of the script: 
# 	- Create "ratings-v2-mysql" service which connects to external mysql database (in GCloud)
#
# Supported platforms:
#	- Vanilla Kubernetes, Linkerd, Consul
#
# Prerequisite(s):
#	- A cluster and bookinfo application is already setup
#	- Update the DB configuration in scripts/bookinfo/bookinfo-ratings-v2-mysql.yaml
#
# Note:
#	- The DB parameters are intentionally left out of the script to avoid exposing secrets.
#	- The script deletes the existing bookinfo app and recreates only required services (mini)
# *************************************************************************************************

echo Are you sure that the required DB configuration changes done [Y/n]?
read MY_SQL_DB_CONFIG

if [ "$MY_SQL_DB_CONFIG" != "Y" ]; then
	echo Pls. configure the database parameters and retry.
	exit 0
fi

echo Deleting bookinfo application and recreating with only required services...
kubectl delete -f ~/ServiceMesh/scripts/bookinfo/bookinfo.yaml

sleep 30

kubectl apply -f ~/ServiceMesh/scripts/bookinfo/bookinfo_mini.yaml

echo Apply the version of the ratings microservice, v2-mysql, that will use database.  
kubectl apply -f ~/ServiceMesh/scripts/bookinfo/bookinfo-ratings-v2-mysql.yaml

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

