
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
	 --num-nodes 5

echo Creating ClusterRoleBinding ...

kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole=cluster-admin \
  --user=$(gcloud config get-value core/account)

echo ***************************************************************
echo Cluster $CLUSTER_NAME created.
echo ***************************************************************

K8S_SCRIPT_DIR=../../bookinfo-perf/src/test/resources/k8s

kubectl create -f $K8S_SCRIPT_DIR/bookinfo-perf-namespace.yml

# Create nfs volume
# Need gcloud command to create volume

echo "Creating nfs volume for reports"

kubectl apply -f $K8S_SCRIPT_DIR/perf-report-nfs-volume.yml

kubectl apply -f $K8S_SCRIPT_DIR/perf-report-volumnclaim.yml

# Create web pod
echo "Creating web server pod"
kubectl apply -f $K8S_SCRIPT_DIR/perf-report-web.yml

echo "Creating web service"
kubectl apply -f $K8S_SCRIPT_DIR/perf-report-web-service.yml

# Run the jobs - edit properties at end of perf-test-job.yml to point to appropriate cluster
# use runPerfTest.sh from bookinfo-perf project

# end of script

