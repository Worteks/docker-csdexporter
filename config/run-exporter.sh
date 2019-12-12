#!/bin/sh

if test "$DEBUG"; then
    set -x
fi
set -e

if test -z "$JVM_OPTS"; then
    JVM_OPTS="-Xmx64m -Xms64m"
fi
export JVM_OPTS

echo "Starting Cassandra exporter"
echo "JVM_OPTS: $JVM_OPTS"

host=$(grep -m1 'host:' /etc/cassandra_exporter/config.yml | cut -d ':' -f2)
port=$(grep -m1 'host:' /etc/cassandra_exporter/config.yml | cut -d ':' -f3)

while ! nc -z $host $port
do
    echo "Waiting for Cassandra JMX to start on $host:$port"
    sleep 1
done

dumb-init /usr/bin/java $JVM_OPTS \
    -jar /opt/cassandra_exporter/cassandra_exporter.jar \
    /etc/cassandra_exporter/config.yml
