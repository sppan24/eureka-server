#!/usr/bin/env bash

JAVA_OPTS="
 -Xms128M
 -Xmx256M
 -XX:+UseG1GC
 -XX:+PrintGCDetails
 -XX:+PrintGCDateStamps
 -XX:+PrintTenuringDistribution
 -Xloggc:./logs/gc.log
 -XX:ErrorFile=./logs/javaerr.log
 -XX:HeapDumpPath=./logs/heapdump.hprof
 -XX:+HeapDumpOnOutOfMemoryError
"

ACTIVE_PROFILE=dev

BASE_DIR=`cd $(dirname $0); pwd -P`
JAR_NAME=${project.build.finalName}.jar
BIN_FILE=${BASE_DIR}/${JAR_NAME}
OUT_LOG_DIR=${BASE_DIR}/logs

RETVAL=0

function start() {
	checkrun
	if [[ ${RETVAL} -eq 0 ]]; then
		cd ${BASE_DIR}
		if [ ! -d ${OUT_LOG_DIR} ];then
      mkdir -p ${OUT_LOG_DIR}
    fi
		nohup java ${JAVA_OPTS} -jar -Dspring.profiles.active=${ACTIVE_PROFILE} ${BIN_FILE} >> ${OUT_LOG_DIR}/out.log 2>&1 &
		echo "--- service start successfully ---"
	else
		echo "--- service already running ---"
	fi
}

function stop() {
	checkrun
	if [[ ${RETVAL} -eq 1 ]]; then
		ps ax | grep ${BIN_FILE} | grep -Ev "grep" | awk '{printf $1 " "}' | xargs kill -9
		echo "--- service stop successfully ---"
	else
		echo "--- service already stopped ---"
	fi
}

function status() {
	checkrun
	if [[ ${RETVAL} -eq 1 ]]; then
		echo "--- service is running ---"
		tail -f ${OUT_LOG_DIR}/out.log
	else
		echo "--- service is stopped ---"
	fi
}

function checkrun(){
        ps ax | grep ${BIN_FILE} | grep -Ev "service.sh|grep"
        RETVAL=$((1-$?))
        return $RETVAL
}


sp=help
if [[ $# -gt 0 ]];then sp=$1; fi
case $sp in
	start) start;;
	stop) stop;;
	restart) stop; start;;
	status) status;;
	*) echo "not support handle";;
esac
