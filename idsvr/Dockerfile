#
# A development custom docker image for experimenting
#
# After building, files in the image can be viewed via the below commands:
# - eval $(minikube docker-env --profile example)
# - docker run -it custom_idsvr:6.2.2 bash
#

# Get the base image
FROM curity.azurecr.io/curity/idsvr:6.2.2

# Copy the license to load at startup
COPY idsvr/license.json /opt/idsvr/etc/init/license/

# The MYSQL driver, extracted from the platform independent tar file: https://dev.mysql.com/downloads/connector/j
COPY idsvr/mysql-connector-java-8.0.22.jar /opt/idsvr/lib/plugins/data.access.jdbc

# Copy in a log file with a root logger of INFO level
COPY idsvr/log4j2.xml /opt/idsvr/etc/

# Copy the HAAPI web sample to the server, for test purposes
COPY haapi-web/* /opt/idsvr/usr/share/webroot/

# Install developer tools in order to troubleshoot connections
USER root
RUN apt-get update
RUN apt-get install curl -y
RUN apt-get install mysql-client -y
USER idsvr