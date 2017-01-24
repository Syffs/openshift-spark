FROM centos:latest

MAINTAINER Matthew Farrellee <matt@cs.wisc.edu>

ENV SPARK_VERSION 1.6.3
ENV HADOOP_BRANCH 2.6

USER root
RUN yum install -y epel-release tar java && \
    yum clean all

RUN cd /opt && \
    curl https://dist.apache.org/repos/dist/release/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_BRANCH}.tgz | \
        tar -zx && \
    ln -s spark-${SPARK_VERSION}-bin-hadoop${HADOOP_BRANCH} spark

# when the containers are not run w/ uid 0, the uid may not map in
# /etc/passwd and it may not be possible to modify things like
# /etc/hosts. nss_wrapper provides an LD_PRELOAD way to modify passwd
# and hosts.
RUN yum install -y nss_wrapper numpy && yum clean all

ENV PATH=$PATH:/opt/spark/bin
ENV SPARK_HOME=/opt/spark

# Add scripts used to configure the image
COPY scripts /tmp/scripts

# Custom scripts
RUN [ "bash", "-x", "/tmp/scripts/spark/install" ]

# Cleanup the scripts directory
RUN rm -rf /tmp/scripts

# Switch to the user 185 for OpenShift usage
USER 185

# Start the main process
CMD ["/opt/spark/bin/launch.sh"]
