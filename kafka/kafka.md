# Create a topic

```bash
./kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic my_topic
```

# List all topics


```bash
./kafka-topics.sh --list --zookeeper localhost:2181
```

# Delete a topic

```bash
./kafka-topics.sh --zookeeper localhost:2181 --delete --topic my_topic
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