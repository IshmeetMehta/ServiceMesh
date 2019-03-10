#!/usr/bin/bash


# functions
function checkStatus {
    STATUS=$(kubectl --namespace bookinfo-perf describe job bookinfo-perf | grep "Pods Statuses")
    #Pods Statuses:  0 Running / 3 Succeeded / 0 Failed
    echo "Job status: $STATUS"
    if [[ "$STATUS" == "Pods Statuses:  0 Running / 3 Succeeded / 0 Failed" ]]
    then
        echo "Job Complete!"
        return 0
    else
        echo "Job running"
        return 1
    fi
}



# Cleanup old job
echo "Cleaning up old perf-test-job"
kubectl delete -f ../perf-test-job.yml

# Run perf test job
echo "Creating new perf-test-job"
kubectl create -f ../perf-test-job.yml

while ! checkStatus ; do
    echo "Waiting..."
    sleep 1
done

# build reports

echo "Building Reports"
echo "Removing old perf-reports-job"
kubectl delete -f ../perf-reports-job.yml

echo "Creating new perf-reports-job"
kubectl create -f ../perf-reports-job.yml

while ! checkStatus ; do
    echo "Waiting..."
    sleep 1
done

