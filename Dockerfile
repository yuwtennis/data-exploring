# syntax=docker/dockerfile:1
FROM jupyter/pyspark-notebook:x86_64-python-3.11

USER root

ENV GCS_CONNECTOR_JAR=gcs-connector-hadoop3-latest.jar
ENV ICEBERG_SPARK_RUNTIME_VER=iceberg-spark-runtime-3.5_2.12
ENV ICEBERG_VER=1.10.1

RUN curl -s -XGET -L -O https://storage.googleapis.com/hadoop-lib/gcs/${GCS_CONNECTOR_JAR}
RUN curl -s -XGET -L -O https://search.maven.org/remotecontent?filepath=org/apache/iceberg/${ICEBERG_SPARK_RUNTIME_VER}/${ICEBERG_VER}/${ICEBERG_SPARK_RUNTIME_VER}-${ICEBERG_VER}.jar
RUN curl -s -XGET -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz

RUN mv \
    ${GCS_CONNECTOR_JAR} \
    ${ICEBERG_SPARK_RUNTIME_VER}-${ICEBERG_VER}.jar \
    /usr/local/spark/jars

USER jovyan

RUN tar xf google-cloud-cli-linux-x86_64.tar.gz \
    && ./google-cloud-sdk/install.sh -q --rc-path ~/.bashrc \
    && rm -f *.tar.gz