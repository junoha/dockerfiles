# Use Confluence's image

- https://docs.confluent.io/current/quickstart/ce-docker-quickstart.html
- https://github.com/confluentinc/examples/tree/5.3.1-post/cp-all-in-one

Version mapping
https://docs.confluent.io/current/installation/versions-interoperability.html#cp-and-apache-ak-compatibility
- 4.1.x ===> 1.1.x
- 5.1.x ===> 2.1.x

## Web UI

http://localhost:8000/

- https://kazuhira-r.hatenablog.com/entry/20180108/1515413171
- https://docs.confluent.io/4.0.0/installation/docker/docs/quickstart.html

## How to use

```console
# Create topic
$ docker-compose exec kafka kafka-topics --create --zookeeper zookeeper:2181 --replication-factor 1 --partitions 1 --topic test
```