### Set up script to Install and Configure Istio

The script Installs kubectl, Istio and other related components
ALso, presently it deploys the bookinfo sample application.

# Sample script execution

Script requires you to provide a work directory with the GKE cluster name of choice. Please use correct gke cluster naming format.

Presently GKE clusters are being installed in us-central1-c 

./LabSetUp.sh

#Please check if istio namespace injection is enabled and working

#kubectl get pods -n istio-system
NAME                                     READY   STATUS      RESTARTS   AGE
grafana-7ffdd5fb74-rlgtt                 1/1     Running     0          2m19s
istio-citadel-5bbbc98c6d-m8mbm           1/1     Running     0          2m17s
istio-cleanup-secrets-pqllx              0/1     Completed   0          2m43s
istio-egressgateway-794489bbf4-v5vng     1/1     Running     0          2m20s
istio-galley-744969c89-pczc6             1/1     Running     0          2m20s
istio-grafana-post-install-hh2gx         0/1     Completed   2          2m45s
istio-ingressgateway-58f6795c5c-7g8l8    1/1     Running     0          2m19s
istio-pilot-64b549f75-h44l2              2/2     Running     0          2m18s
istio-policy-7b8f874df6-jtr87            2/2     Running     0          2m18s
istio-security-post-install-wg8v9        0/1     Completed   2          2m41s
istio-sidecar-injector-856b74c95-4dh22   1/1     Running     0          2m16s
istio-telemetry-868d55d686-7hhpq         2/2     Running     0          2m18s
istio-tracing-6445d6dbbf-lf6rd           1/1     Running     0          2m15s
prometheus-65d6f6b6c-6p6pg               1/1     Running     0          2m17s
servicegraph-658fd9f76d-mvt7h            1/1     Running     0          2m16s

# Note : istio sidecars have ben injected in default namespace
#$ kubectl get namespace -L istio-injection
NAME           STATUS   AGE     ISTIO-INJECTION
default        Active   5m2s    enabled
istio-system   Active   3m16s   disabled
kube-public    Active   5m2s    
kube-system    Active   5m2s    



#Please open link $GATEWAY_URL/productpage in your browser to view app

#Post application Install, we need to set up External Ips for Istio Services

Run following script

./Assign_External_Ips_Istio_Services.sh

#Please follow instructions at the end to view the external ips assigned to the services


#To Generate load for Telemetry views, you can run following script.
For loop count can be increase to generate more page hits.

./generate_load.sh
