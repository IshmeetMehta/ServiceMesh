#!/bin/bash


echo "Setting up values for GATEWAY_URL"

export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
echo "$GATEWAY_URL has been set. Proceeding to assigning external Ip' to services runing in Istio namespace"
echo " "
echo "Following services are running Istio namespace:"
kubectl get svc -n istio-system

sleep 2 
echo "Now exposing External IP addresses for the istio enabled services"

kubectl patch svc tracing -p '{"spec":{"type":"LoadBalancer"}}' -n istio-system


sleep 2 

kubectl patch svc servicegraph -p '{"spec":{"type":"LoadBalancer"}}' -n istio-system

sleep 2 

kubectl patch svc prometheus -p '{"spec":{"type":"LoadBalancer"}}' -n istio-system

sleep 2 


kubectl patch svc grafana -p '{"spec":{"type":"LoadBalancer"}}' -n istio-system
echo " "

sleep 5 

echo "Note the External Ip for each of ISTIO services"
echo " "
kubectl get svc -n istio-system | awk  '{print $1 " " $4 " " $5}' | grep -v none

echo " "
echo "Open following browser links to access services"
echo " "
echo "Prometheus:external IP:9090/graph "
echo "Grafana: External IP:3000"
echo "Jaegar: External IP:16686"
echo "ServiceGraph: External IP:8088/force/forcegraph.html"

