FROM curity.azurecr.io/curity/idsvr:7.3.1

# Copy the license to load at startup
COPY idsvr/license.json /opt/idsvr/etc/init/license/

# Copy in a log file with a root logger of INFO level - or increase to DEBUG when required
COPY idsvr/log4j2.xml /opt/idsvr/etc/

# Copy the HAAPI web sample to the root web folder of runtime nodes
COPY haapi-web-example/* /opt/idsvr/usr/share/webroot/
