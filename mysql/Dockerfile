#
# A basic MySql docker image that also creates the Curity schema
# - eval $(minikube docker-env --profile example)
# - docker run -it custom_mysql:8.0.22 bash
#

FROM mysql:8.0.22

# Install developer tools
RUN apt-get update
RUN apt-get install curl -y

# Copy in a script to restore SQL data
COPY mysql/idsvr-data-backup.sql /docker-entrypoint-initdb.d/
