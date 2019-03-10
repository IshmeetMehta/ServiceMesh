

# ************************************************************************************************
# Purpose of the script: 
# 	- Create "ratings-v2-mysql" service which connects to external mysql database (in GCloud)
#
# Prerequisite(s):
#	- A cluster with Istio components and bookinfo application is already setup
#	- Update the DB configuration in scripts/bookinfo/bookinfo-ratings-v2-mysql.yaml
#
# Note:
#	- The DB credentials are intentionally left out of the script to avoid exposing secrets.
# *************************************************************************************************

echo Are you sure that the required DB configuration changes done [Y/n]?
read MY_SQL_DB_CONFIG

if [ "$MY_SQL_DB_CONFIG" != "Y" ]; then
	echo Pls. configure the database parameters and retry.
	exit 0
fi

# Initialize environment variables
export MYSQL_DB_HOST=104.154.40.165
export MYSQL_DB_PORT=3306
ISTIO_VERSION=1.0.5
NAME="istio-$ISTIO_VERSION"

echo Apply the version of the ratings microservice, v2-mysql, that will use database.  
kubectl apply -f ~/ServiceMesh/scripts/bookinfo/bookinfo-ratings-v2-mysql.yaml

echo Apply default Destination rules
kubectl apply -f /$NAME/samples/bookinfo/networking/destination-rule-all.yaml

echo Create virtual services to route traffic to rewviews to v3 and ratings to v2-mysql
kubectl apply -f ~/$NAME/samples/bookinfo/networking/virtual-service-ratings-mysql.yaml

echo Create Mesh-external service entry for an external MySQL instance

echo Define a TCP mesh-external service entry:

cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: mysql-external
spec:
  hosts:
  - $MYSQL_DB_HOST
  addresses:
  - $MYSQL_DB_HOST/32
  ports:
  - name: tcp
    number: $MYSQL_DB_PORT
    protocol: tcp
  location: MESH_EXTERNAL
EOF


echo Review the service entry you just created and check that it contains the correct values
kubectl get serviceentry mysql-external -o yaml

