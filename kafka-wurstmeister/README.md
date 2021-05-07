# Use wurstmeister's image

https://hub.docker.com/r/wurstmeister/kafka

## Version

`scala-version`-`kafka-version`

https://github.com/wurstmeister/kafka-docker


## How to use

```console
# Single broker
$ docker-compose up -d

# 3 node broker
$ docker-compose up -d --scale kafka=3
Starting kafka-single_zookeeper_1 ... done
Starting kafka-single_kafka_1     ... done
Starting kafka-single_kafka_2     ... done
Starting kafka-single_kafka_3     ... done

# Kafka tool
$ docker-compose exec kafka ls /opt/kafka/bin/
connect-distributed.sh               kafka-reassign-partitions.sh
connect-standalone.sh                kafka-replica-verification.sh
kafka-acls.sh                        kafka-run-class.sh
kafka-broker-api-versions.sh         kafka-server-start.sh
kafka-configs.sh                     kafka-server-stop.sh
kafka-console-consumer.sh            kafka-streams-application-reset.sh
kafka-console-producer.sh            kafka-topics.sh
kafka-consumer-groups.sh             kafka-verifiable-consumer.sh
kafka-consumer-perf-test.sh          kafka-verifiable-producer.sh
kafka-delegation-tokens.sh           trogdor.sh
kafka-delete-records.sh              windows
kafka-dump-log.sh                    zookeeper-security-migration.sh
kafka-log-dirs.sh                    zookeeper-server-start.sh
kafka-mirror-maker.sh                zookeeper-server-stop.sh
kafka-preferred-replica-election.sh  zookeeper-shell.sh
kafka-producer-perf-test.sh

# Broker list
$ docker-compose exec kafka /opt/kafka/bin/zookeeper-shell.sh zookeeper:2181 ls /brokers/ids
Connecting to zookeeper:2181

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
[1004, 1001, 1005]


# Broker configuration

$ docker-compose exec kafka /opt/kafka/bin/zookeeper-shell.sh zookeeper:2181 get /brokers/ids/1001
Connecting to zookeeper:2181

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
{"listener_security_protocol_map":{"PLAINTEXT":"PLAINTEXT"},"endpoints":["PLAINTEXT://xxx.com:32771"],"jmx_port":-1,"host":"xxx.com","timestamp":"1579590224851","port":32771,"version":4}
cZxid = 0x4a6
ctime = Tue Jan 21 07:03:45 GMT 2020
mZxid = 0x4a6
mtime = Tue Jan 21 07:03:45 GMT 2020
pZxid = 0x4a6
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x10001eb9fde0003
dataLength = 226
numChildren = 0


# Create topic
$ docker-compose exec kafka /opt/kafka/bin/kafka-topics.sh --create --zookeeper zookeeper:2181 --replication-factor 1 --partitions 1 --topic test
Created topic "test".
$ docker-compose exec kafka /opt/kafka/bin/kafka-topics.sh --create --zookeeper zookeeper:2181 --replication-factor 3 --partitions 3 --topic first-test
Created topic "first-test".
$ docker-compose exec kafka /opt/kafka/bin/kafka-topics.sh --create --zookeeper zookeeper:2181 --replication-factor 2 --partitions 3 --topic second-test
Created topic "second-test".

# List topic
$ docker-compose exec kafka /opt/kafka/bin/kafka-topics.sh --list --zookeeper zookeeper:2181
first-test
second-test
test

# Describe topic
$ docker-compose exec kafka /opt/kafka/bin/kafka-topics.sh --describe --topic test --zookeeper zookeeper:2181
Topic:test      PartitionCount:1        ReplicationFactor:1     Configs:
        Topic: test     Partition: 0    Leader: 1001    Replicas: 1001  Isr: 1001

$ docker-compose exec kafka /opt/kafka/bin/kafka-topics.sh --describe --topic first-test --zookeeper zookeeper:2181
Topic:first-test        PartitionCount:3        ReplicationFactor:3     Configs:
        Topic: first-test       Partition: 0    Leader: 1001    Replicas: 1001,1004,1005        Isr: 1001,1004,1005
        Topic: first-test       Partition: 1    Leader: 1004    Replicas: 1004,1005,1001        Isr: 1004,1005,1001
        Topic: first-test       Partition: 2    Leader: 1005    Replicas: 1005,1001,1004        Isr: 1005,1001,1004

$ docker-compose exec kafka /opt/kafka/bin/kafka-topics.sh --describe --topic second-test --zookeeper zookeeper:2181
Topic:second-test       PartitionCount:3        ReplicationFactor:2     Configs:
        Topic: second-test      Partition: 0    Leader: 1005    Replicas: 1005,1004     Isr: 1005,1004
        Topic: second-test      Partition: 1    Leader: 1001    Replicas: 1001,1005     Isr: 1001,1005
        Topic: second-test      Partition: 2    Leader: 1004    Replicas: 1004,1001     Isr: 1004,1001


# Change number of partition for topic
$ docker-compose exec kafka /opt/kafka/bin/kafka-topics.sh --alter --topic aaaaaaaaaa --zookeeper zookeeper:2181 --partitions 3
WARNING: If partitions are increased for a topic that has a key, the partition logic or ordering of the messages will be affected
Adding partitions succeeded!

$ docker-compose exec kafka /opt/kafka/bin/kafka-topics.sh --describe --topic aaaaaaaaaa --zookeeper zookeeper:2181
Topic:aaaaaaaaaa        PartitionCount:3        ReplicationFactor:2     Configs:
        Topic: aaaaaaaaaa       Partition: 0    Leader: 1001    Replicas: 1001,1002     Isr: 1001,1002
        Topic: aaaaaaaaaa       Partition: 1    Leader: 1002    Replicas: 1002,1003     Isr: 1002,1003
        Topic: aaaaaaaaaa       Partition: 2    Leader: 1003    Replicas: 1003,1001     Isr: 1003,1001


# Cannot change RF by kafka-topics.sh
$ docker-compose exec kafka /opt/kafka/bin/kafka-topics.sh --alter --topic aaaaaaaaaa --zookeeper zookeeper:2181 --replication-factor 3
Option "[replication-factor]" can't be used with option "[alter]"

--replication-factor <Integer:           The replication factor for each
  replication factor>                      partition in the topic being created.


# Change RF by kafka-reassign-partitions.sh
## Before
$ docker-compose exec kafka /opt/kafka/bin/kafka-topics.sh --describe --topic foo --zookeeper zookeeper:2181

Topic:foo       PartitionCount:3        ReplicationFactor:2     Configs:
        Topic: foo      Partition: 0    Leader: 1003    Replicas: 1003,1001     Isr: 1003,1001
        Topic: foo      Partition: 1    Leader: 1001    Replicas: 1001,1002     Isr: 1001,1002
        Topic: foo      Partition: 2    Leader: 1002    Replicas: 1002,1003     Isr: 1002,1003

## RF 2 -> 3 
$ docker-compose exec kafka cat /increase-replication-factor.json
{
  "version":1,
  "partitions":[
     {"topic":"foo","partition":0,"replicas":[1001,1002,1003]},
     {"topic":"foo","partition":1,"replicas":[1001,1002,1003]},
     {"topic":"foo","partition":2,"replicas":[1001,1002,1003]}
  ]
}

## Change
$ docker-compose exec kafka /opt/kafka/bin/kafka-reassign-partitions.sh --reassignment-json-file /increase-replication-factor.json --execute --zookeeper zookeeper:2181
Current partition replica assignment

{"version":1,"partitions":[{"topic":"foo","partition":2,"replicas":[1002,1003],"log_dirs":["any","any"]},{"topic":"foo","partition":1,"replicas":[1001,1002],"log_dirs":["any","any"]},{"topic":"foo","partition":0,"replicas":[1003,1001],"log_dirs":["any","any"]}]}

Save this to use as the --reassignment-json-file option during rollback
Successfully started reassignment of partitions.

## After
$ docker-compose exec kafka /opt/kafka/bin/kafka-topics.sh --describe --topic foo --zookeeper zookeeper:2181
Topic:foo       PartitionCount:3        ReplicationFactor:3     Configs:
        Topic: foo      Partition: 0    Leader: 1003    Replicas: 1001,1002,1003        Isr: 1003,1001,1002
        Topic: foo      Partition: 1    Leader: 1001    Replicas: 1001,1002,1003        Isr: 1001,1002,1003
        Topic: foo      Partition: 2    Leader: 1002    Replicas: 1001,1002,1003        Isr: 1002,1003,1001
```

Messaging

```console
# Producer
$ docker-compose exec kafka /opt/kafka/bin/kafka-console-producer.sh --broker-list kafka:9092 --topic test
>Hello
>Hello world
>


# Consumer
$ docker-compose exec kafka /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic test --from-beginning

Hello
Hello world
```

Log into container

```console
$ docker-compose exec kafka bash

bash-4.4# env
**KAFKA_HOME****=****/opt/****kafka**
LANG=C.UTF-8
KAFKA_ADVERTISED_HOST_NAME=localhost
HOSTNAME=xxxx
JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk/jre
**JAVA_VERSION****=****8u212**
PWD=/
HOME=/root
GLIBC_VERSION=2.29-r0
TERM=xterm
**KAFKA_VERSION****=****1.1****.****1**
SHLVL=1
KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181
**SCALA_VERSION****=****2.11**
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin:/opt/kafka/bin
JAVA_ALPINE_VERSION=8.212.04-r0
_=/usr/bin/env

bash-4.4# java -version
openjdk version "1.8.0_212"
OpenJDK Runtime Environment (IcedTea 3.12.0) (Alpine 8.212.04-r0)
OpenJDK 64-Bit Server VM (build 25.212-b04, mixed mode)
```