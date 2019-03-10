#!/usr/bin/env bash

# create reports directory
REPORT_DATE=`date +%Y%m%d`
echo "Date is ${REPORT_DATE}"
REPORT_DIR=/gatling/reports/report-${REPORT_DATE}
if [[ -d "${REPORT_DIR}" ]]; then
    echo "Report Directory ${REPORT_DIR} already exists"
else
    echo "Creating directory ${REPORT_DIR}"
    mkdir ${REPORT_DIR}
fi

for dir in /gatling/reports/runs/*
do
    dir_stripped=${dir%*/}
    run_name=${dir_stripped##*/}
    echo "Run name is ${run_name}"
    ls ${dir}/basicsimulation-*
    echo "Moving simulation log for ${dir} into report folder"
    mv ${dir}/basicsimulation-*/simulation.log ${REPORT_DIR}/simulation-${run_name}.log
    echo "Deleting run directory ${dir}"
    rm -rf ${dir}
done

echo "Generating Gatling report"
GATLING_HOME=/gatling/gatling-charts-highcharts-bundle-3.0.2
GATLING_SIMULATIONS_DIR=/gatling/simulations
GATLING_RUNNER=${GATLING_HOME}/bin/gatling.sh

${GATLING_RUNNER} -ro ${REPORT_DIR} -rf ${REPORT_DIR}