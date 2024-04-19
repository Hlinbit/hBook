# Create a topic

```bash
./kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic my_topic
# new version
./kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic topic_csv
```

# List all topics


```bash
./kafka-topics.sh --list --zookeeper localhost:2181
# new version
./kafka-topics.sh --list --bootstrap-server localhost:9092
```

# Delete a topic

```bash
./kafka-topics.sh --zookeeper localhost:2181 --delete --topic my_topic
# new version
./kafka-topics.sh --bootstrap-server localhost:9092 --delete --topic my_topic
```

# Check a topic meta message

```bash
./kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic topic_json2
```


# Produce messages to topic


```bash
./kafka-console-producer.sh --broker-list localhost:9092 --topic my_topic
```


# Consume message from topic

```bash
./kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic my_topic --from-beginning
```

# Delete messages in topic

```bash
kafka-delete-records --bootstrap-server localhost:9092  --offset-json-file delete.json --topic test-topic
```