FROM pingdom/java

# Cassandra Exporter image for OpenShift Origin

LABEL io.k8s.description="Apache Cassandra Prometheus Exporter." \
      io.k8s.display-name="Cassandra Exporter 2.1.0" \
      io.openshift.expose-services="9113:http" \
      io.openshift.tags="cassandra,exporter,prometheus" \
      io.openshift.non-scalable="true" \
      help="For more information visit https://github.com/Worteks/docker-csdexporter" \
      maintainer="Samuel MARTIN MORO <faust64@gmail.com>" \
      version="2.1.0"

ENV CS=https://github.com/criteo/cassandra_exporter/releases/download/ \
    XPVERSION=2.1.0

USER root
COPY config/* /
RUN apt-get update \
    && if test "$DO_UPGRADE"; then \
	apt-get upgrade -y; \
    fi \
    && apt-get install -y --no-install-recommends netcat wget \
    && mkdir -p /etc/cassandra_exporter /opt/cassandra_exporter \
    && wget $CS/$XPVERSION/cassandra_exporter-$XPVERSION-all.jar \
	-O /opt/cassandra_exporter/cassandra_exporter.jar \
    && mv /config.yml /etc/cassandra_exporter/ \
    && apt-get remove -y --purge wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man

USER 1001
ENTRYPOINT ["dumb-init","--","/run-exporter.sh"]
