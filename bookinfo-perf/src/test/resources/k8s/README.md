# Kubernetes Scripts and Manifests

The /docker subfolder contains Dockerfiles for the necessary images
the /scripts folder contains scripts for running the tests

Change the JAVA_OPTS in perf-test-job*.yml to point to the bookinfo service endpoint for the cluster you want to test
Change the number of users and repetitions based on the amount of load you wish to generate.
Download gatling-chart-highcharts-bundle from [Gatling Downloads](https://gatling.io/download/)
Update dockerfiles if there's a new version. Current is gatling-charts-highcharts-bundle-3.0.2
You will also need to update the job files to use the new version.

To build images, run docker build command from the bookinfo-perf directory. Change version as necessary.

```
docker build -f src/test/resources/k8s/docker/GatlingshDockerfile -t gcr.io/e2-chase/perf-test:v1 .
docker push gcr.io/e2-chase/perf-test:v1
```
You can run an individual cluster test, or run all of the tests in parallel by running:
```
kubectl create -f src/test/resources/k8s/test-jobs 
``` 