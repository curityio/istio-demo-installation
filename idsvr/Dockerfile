FROM curity.azurecr.io/curity/idsvr:8.0.0
COPY idsvr/license.json /opt/idsvr/etc/init/license/

# Host the HAAPI web code example in the root web folder of runtime nodes
COPY haapi-web-example/* /opt/idsvr/usr/share/webroot/
