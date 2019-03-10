
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

# gcloud beta container --project "e2-chase" clusters create "bookinfo-perf" --zone "us-central1-a" --username "admin" --cluster-version "1.11.7-gke.4" --machine-type "n1-highmem-2" --image-type "COS" --disk-type "pd-standard" --disk-size "100" --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes "3" --enable-cloud-logging --enable-cloud-monitoring --no-enable-ip-alias --network "projects/e2-chase/global/networks/default" --subnetwork "projects/e2-chase/regions/us-central1/subnetworks/default" --enable-autoscaling --min-nodes "1" --max-nodes "5" --addons HorizontalPodAutoscaling,HttpLoadBalancing --enable-autoupgrade --enable-autorepair

# end of script

