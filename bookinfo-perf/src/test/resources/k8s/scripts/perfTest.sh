#!/usr/bin/env bash
# Script to run performance tests inside the container

echo "Node Name: ${MY_NODE_NAME} Pod Name: ${MY_POD_NAME}"
echo "JAVA_OPTS: ${JAVA_OPTS}"

GATLING_HOME=/gatling/gatling-charts-highcharts-bundle-3.0.2
GATLING_SIMULATIONS_DIR=/gatling/simulations
GATLING_RUNNER=${GATLING_HOME}/bin/gatling.sh

GATLING_REPORT_DIR=/gatling/reports/runs/${MY_POD_NAME}

if [[ -d "${GATLING_REPORT_DIR}" ]]; then
    echo "Report Directory ${GATLING_REPORT_DIR} already exists"
else
    echo "Creating report directory ${GATLING_REPORT_DIR}"
    mkdir -p ${GATLING_REPORTS_DIR}
fi

SIMULATION_NAME='net.gomesh.test.bookinfogatlingtest.BasicSimulation'
# run the simulation
echo "running $GATLING_RUNNER -nr -s $SIMULATION_NAME"
${GATLING_RUNNER} -nr -s ${SIMULATION_NAME} -rf ${GATLING_REPORT_DIR} -sf ${GATLING_SIMULATIONS_DIR}