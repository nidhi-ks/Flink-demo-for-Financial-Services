# Workshop Instructions

## 1. Create a free account
Sign up for Confluent Cloud at [Confluent Cloud - Try Free](https://www.confluent.io/confluent-cloud/tryfree/).

---

## 2. Create a new environment
- After logging in, click on **'Add new environment'**.
- Give it a meaningful name (e.g., `<your-name>-environment`).
- Select the **Essentials** package for Stream Governance.

---

## 3. Set up a new cluster
- Click on **'Add cluster'** and select a **Basic Cluster** for the workshop.
- Choose your preferred **cloud provider** and **region**, then click **Launch**.
- Your Confluent Cloud Kafka cluster is now up and running!

---

Alternatively , we have terraform scripts to automate the steps , please refer to `cflt-cloud.tf` for the cloud configuration

---

## 4. Creating a Datagen Connector to Pull Data in Confluent Cloud

### Create a new topic:
- Navigate to the **Topics** tab and click **Create New Topic**.
- Name the topic `trades-data`.

### Create another topic:
- Navigate to the **Topics** tab and click **Create New Topic**.
- Name the topic `users-data`.

---

Alternatively , we have terraform scripts to automate the steps , please refer to `topics.tf` for the creating topics

---


### Add a sample data connector:
- Go to the **Connectors** tab, click **Add Connector**, and search for the **Sample Data** connector.
- Select `trades-data` as the **target topic**.
- Set **Output Message Format** to **Avro**.

### Configure the connector:
- In the **Advanced Configuration** section, choose **Trades** as the dataset.
- Leave the other settings as default and start the connector provisioning.
- Verify data ingestion into the `trades-data` topic.

---

### Add another sample data connector:
- Go to the **Connectors** tab, click **Add Connector**, and search for the **Sample Data** connector.
- Select `users-data` as the target topic and set **Output Message Format** to **Avro**.

### Configure the connector:
- In the **Advanced Configuration** section, choose **Users** as the dataset.
- Start the connector provisioning and verify data ingestion into the `users-data` topic.

---

Alternatively , we have terraform scripts to automate the steps , please refer to `cflt-connectors.tf` for the setting up datagen connectors

---


## 5. Creating a Compute Pool in Flink

### Navigate to the Flink tab:
- Hover over the **Flink** tab and click **Create Compute Pool**.

### Configure the compute pool:
- Ensure the region matches your Kafka cluster's region.
- Choose your preferred **cloud provider** and **region**.
- Leave the **Max CFU** setting as default.
- Provide a meaningful name for your compute pool.
- Your compute pool will be up and running in a few minutes.

---

Alternatively , we have terraform scripts to automate the steps , please refer to `flink.tf` for the spinning up a flink compute pool

---

## 6. Creating Tables in Flink

### 1. View the `trade_data` table:

Run the following command to view the table structure:

```sql
SHOW CREATE TABLE trade_data;
```

Output : 

```sql
CREATE TABLE `trade_data` (
  `key` VARBINARY(2147483647),
  `side` VARCHAR(2147483647) NOT NULL COMMENT 'A simulated trade side (buy or sell or short)',
  `quantity` INT NOT NULL COMMENT 'A simulated random quantity of the trade',
  `symbol` VARCHAR(2147483647) NOT NULL COMMENT 'Simulated stock symbols',
  `price` INT NOT NULL COMMENT 'A simulated random trade price in pennies',
  `account` VARCHAR(2147483647) NOT NULL COMMENT 'Simulated accounts assigned to the trade',
  `userid` VARCHAR(2147483647) NOT NULL COMMENT 'The simulated user who executed the trade'
) DISTRIBUTED BY HASH(`key`) INTO 3 BUCKETS
WITH (
  'changelog.mode' = 'append',
  'connector' = 'confluent',
  'kafka.cleanup-policy' = 'delete',
  'kafka.max-message-size' = '2097164 bytes',
  'kafka.retention.size' = '0 bytes',
  'kafka.retention.time' = '7 d',
  'key.format' = 'raw',
  'scan.bounded.mode' = 'unbounded',
  'scan.startup.mode' = 'earliest-offset',
  'value.format' = 'avro-registry'
);
```

### 2. Adding Data to `trades_topic`

```sql
CREATE TABLE `trades_topic` (
  `key` VARBINARY(2147483647),
  `side` VARCHAR(2147483647) NOT NULL COMMENT 'A simulated trade side (buy or sell or short)',
  `quantity` INT NOT NULL COMMENT 'A simulated random quantity of the trade',
  `symbol` VARCHAR(2147483647) NOT NULL COMMENT 'Simulated stock symbols',
  `price` INT NOT NULL COMMENT 'A simulated random trade price in pennies',
  `account` VARCHAR(2147483647) NOT NULL COMMENT 'Simulated accounts assigned to the trade',
  `userid` VARCHAR(2147483647) NOT NULL COMMENT 'The simulated user who executed the trade'
);
```

```sql
INSERT INTO trades_topic
SELECT * 
FROM trade_data;
```

## Filtering in Flink: Price and Quantity Greater Than 0


### 3. Creating the `filtered_trades` Table

```sql
CREATE TABLE `filtered_trades` (
  `key` VARBINARY(2147483647),
  `side` VARCHAR(2147483647) NOT NULL COMMENT 'A simulated trade side (buy or sell or short)',
  `quantity` INT NOT NULL COMMENT 'A simulated random quantity of the trade',
  `symbol` VARCHAR(2147483647) NOT NULL COMMENT 'Simulated stock symbols',
  `price` INT NOT NULL COMMENT 'A simulated random trade price in pennies',
  `account` VARCHAR(2147483647) NOT NULL COMMENT 'Simulated accounts assigned to the trade',
  `userid` VARCHAR(2147483647) NOT NULL COMMENT 'The simulated user who executed the trade'
);
```

```sql
Copy code
INSERT INTO `filtered_trades`
SELECT * 
FROM trades_topic
WHERE quantity > 0 
  AND price > 0 
  AND (side = 'BUY' OR side = 'SELL');
```

### 4. Joining `trades_topic` and `users_data` Using an Inner Join

```sql
SELECT 
    t.side,
    t.quantity,
    t.symbol,
    t.price,
    t.account,
    t.userid,
    u.registertime,
    u.regionid,
    u.gender
FROM 
    trades_topic t
INNER JOIN 
    users_data u 
ON 
    t.userid = u.userid;
```
### 5. Running Aggregates and Window Functions

```sql
CREATE TABLE broker_trade_volume (
  window_start TIMESTAMP(3),
  window_end TIMESTAMP(3),
  userid STRING,
  total_number_of_shares BIGINT,
  total_amount_traded BIGINT
);
```

```sql
INSERT INTO broker_trade_volume
SELECT 
    window_start, 
    window_end, 
    userid, 
    SUM(quantity) AS `total_number_of_shares`, 
    SUM(price) AS `total_amount_traded`
FROM TABLE (
    TUMBLE(TABLE filtered_trades, DESCRIPTOR($rowtime), INTERVAL '10' MINUTES)
)
GROUP BY 
    userid, 
    window_start, 
    window_end;
```

## 7. Pushing Data into MongoDB via Mongo Atlas Sink Connector

### Setting Up MongoDB Atlas Sink Connector

1. Navigate to the Connectors tab.
2. Select **MongoDB Atlas Sink** Connector.
3. Choose the **broker_trade_volume** topic.
4. Provide authentication details (hostname, username, password, database, collection name).
5. Validate the connection to MongoDB Atlas.
6. Verify data ingestion in MongoDB Atlas.

### MongoDB Atlas Sink Connector Configuration

```sql
{
  "config": {
    "connector.class": "MongoDbAtlasSink",
    "name": "MongoDbAtlasSinkConnector_1",
    "schema.context.name": "default",
    "input.data.format": "AVRO",
    "cdc.handler": "None",
    "value.subject.name.strategy": "TopicNameStrategy",
    "delete.on.null.values": "false",
    "max.batch.size": "0",
    "bulk.write.ordered": "true",
    "rate.limiting.timeout": "0",
    "rate.limiting.every.n": "0",
    "write.strategy": "DefaultWriteModelStrategy",
    "kafka.auth.mode": "KAFKA_API_KEY",
    "kafka.api.key": "MNQKPKTJSJUAX3DH",
    "kafka.api.secret": "****************************************************************",
    "topics": "broker_trade_volume",
    "connection.host": "cflt-test.5afyk.mongodb.net",
    "connection.user": "test-cflt",
    "connection.password": "*********",
    "database": "trade-data",
    "collection": "trade_data_volume",
    "doc.id.strategy": "BsonOidStrategy",
    "doc.id.strategy.overwrite.existing": "false",
    "document.id.strategy.uuid.format": "string",
    "key.projection.type": "none",
    "value.projection.type": "none",
    "namespace.mapper.class": "DefaultNamespaceMapper",
    "server.api.deprecation.errors": "false",
    "server.api.strict": "false",
    "max.num.retries": "3",
    "retries.defer.timeout": "5000",
    "timeseries.timefield.auto.convert": "false",
    "timeseries.timefield.auto.convert.date.format": "yyyy-MM-dd[['T'][ ]][HH:mm:ss[[.][SSSSSS][SSS]][ ]VV[ ]'['VV']'][HH:mm:ss[[.][SSSSSS][SSS]][ ]X][HH:mm:ss[[.][SSSSSS][SSS]]]",
    "timeseries.timefield.auto.convert.locale.language.tag": "en",
    "timeseries.expire.after.seconds": "0",
    "ts.granularity": "None",
    "max.poll.interval.ms": "300000",
    "max.poll.records": "500",
    "tasks.max": "1"
  }
}

```

Please note that the user should have read write access on the database , collection specified in the connector . The data flows from Confluent Cloud to Mongo Atlas trade_data_volume collection . 
Verify the data inside the Mongo Atlas UI . 

## 8. Deploying a Flink statement in Terraform 

Please refer to the below example to run a flink sql statement in terraform 

Example : 

```bash
# Deploy a Flink SQL statement to Confluent Cloud.
resource "confluent_flink_statement" "my_flink_statement" {
  organization {
    id = data.confluent_organization.my_org.id
  }

  environment {
    id = confluent_environment.my_env.id
  }

  compute_pool {
    id = confluent_flink_compute_pool.my_compute_pool.id
  }

  principal {
    id = confluent_service_account.my_service_account.id
  }

  # This SQL reads data from source_topic, filters it, and ingests the filtered data into sink_topic.
  statement = <<EOT
    CREATE TABLE my_sink_topic AS
    SELECT
      window_start,
      window_end,
      SUM(price) AS total_revenue,
      COUNT(*) AS cnt
    FROM
    TABLE(TUMBLE(TABLE `examples`.`marketplace`.`orders`, DESCRIPTOR($rowtime), INTERVAL '1' MINUTE))
    GROUP BY window_start, window_end;
    EOT

  properties = {
    "sql.current-catalog"  = confluent_environment.my_env.display_name
    "sql.current-database" = confluent_kafka_cluster.my_kafka_cluster.display_name
  }

  rest_endpoint = data.confluent_flink_region.my_flink_region.rest_endpoint

  credentials {
    key    = confluent_api_key.my_flink_api_key.id
    secret = confluent_api_key.my_flink_api_key.secret
  }

  depends_on = [
    confluent_api_key.my_flink_api_key,
    confluent_flink_compute_pool.my_compute_pool,
    confluent_kafka_cluster.my_kafka_cluster
  ]
}
```





