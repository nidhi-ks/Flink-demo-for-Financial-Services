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

## 4. Creating a Datagen Connector to Pull Data in Confluent Cloud

### Create a new topic:
- Navigate to the **Topics** tab and click **Create New Topic**.
- Name the topic `trades-data`.

### Add a sample data connector:
- Go to the **Connectors** tab, click **Add Connector**, and search for the **Sample Data** connector.
- Select `trades-data` as the **target topic**.
- Set **Output Message Format** to **Avro**.

### Configure the connector:
- In the **Advanced Configuration** section, choose **Trades** as the dataset.
- Leave the other settings as default and start the connector provisioning.
- Verify data ingestion into the `trades-data` topic.

---

### Create another topic:
- Navigate to the **Topics** tab and click **Create New Topic**.
- Name the topic `users-data`.

### Add another sample data connector:
- Go to the **Connectors** tab, click **Add Connector**, and search for the **Sample Data** connector.
- Select `users-data` as the target topic and set **Output Message Format** to **Avro**.

### Configure the connector:
- In the **Advanced Configuration** section, choose **Users** as the dataset.
- Start the connector provisioning and verify data ingestion into the `users-data` topic.

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

## 6. Creating Tables in Flink

### View the `trade_data` table:
Run the following command to view the table structure:

```sql
SHOW CREATE TABLE trade_data;
```

Output : ## 1. Creating the `trade_data` Table

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
CREATE TABLE `Nidhi-workspace`.`flinkdemo-finserv`.`filtered_trades` (
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
INSERT INTO filtered_trades
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

###MongoDB Atlas Sink Connector Configuration

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
    "kafka.api.key": "
```




