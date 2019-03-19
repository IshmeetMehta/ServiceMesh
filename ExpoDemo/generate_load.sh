#!/bin/bash

echo Generate load for bookinfo /productpage, script requires GATEWAY_URL for bookinfo app

sleep 3
echo "Setting up values for GATEWAY_URL"

echo " "

export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

echo "Generating load for bookinfo, please check response HTTP code"
echo " "
echo "Generating 100 hits for /productpage"
echo " "
for i in {1..100}; do curl -o /dev/null -s -w "%{http_code}\n" http://${GATEWAY_URL}/productpage; done
