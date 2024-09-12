# Flink-demo-for-Financial-Services

Shift-Left Pattern with Flink SQL and Confluent Cloud Workshop

This self-paced workshop demonstrates how to implement a shift-left pattern for improved data quality and governance in a brokerage scenario using Apache Flink SQL and Confluent Cloud.

Workshop Objectives

- Understand the shift-left pattern and its benefits in data processing
- Learn to use Apache Flink SQL for real-time data processing
- Implement data quality checks and governance policies early in the data pipeline
- Perform stateless and stateful operations on streaming data
- Integrate with Confluent Cloud and MongoDB

Prerequisites

- Basic knowledge of SQL
- Familiarity with stream processing concepts
- A Confluent Cloud account

Workshop Structure
1. Introduction to the shift-left pattern and use case
2. Setting up the environment
3. Generating sample data
4. Filtering and cleaning data
5. Performing aggregations
6. Implementing joins
7. Sinking processed data

Happy learning!

Introduction to Shift-Left Pattern and Use Case
The shift-left pattern in data processing involves moving data quality checks and governance policies earlier in the data pipeline. This approach helps to:

1. Identify and address data quality issues early
2. Reduce costs associated with downstream data cleanup
3. Improve overall data reliability and trustworthiness

In our brokerage use case, we'll implement this pattern to process trade data more efficiently and accurately. We'll use Apache Flink SQL with Confluent Cloud to:

1. Generate and ingest trade data
2. Apply data quality filters
3. Perform real-time aggregations
4. Join streaming data with static data
5. Sink processed data for further analysis

By the end of this workshop, you'll have a practical understanding of how to implement the shift-left pattern using Flink SQL and Confluent Cloud.

Creating a datagen connector to pull data in Confluent Cloud : 

Configuration : 

{
  "config": {
    "connector.class": "DatagenSource",
    "name": "DatagenSourceConnector_1",
    "kafka.auth.mode": "KAFKA_API_KEY",
    "kafka.api.key": "MNQKPKTJSJUAX3DH",
    "kafka.api.secret": "****************************************************************",
    "kafka.topic": "trade_data",
    "schema.context.name": "default",
    "output.data.format": "AVRO",
    "json.output.decimal.format": "BASE64",
    "quickstart": "STOCK_TRADES",
    "max.interval": "1000",
    "tasks.max": "1"
  }
}

The data will be ingested to the trade_data topic 

Creating tables in Flink : 

1. To review the trade_data table created by flink run SHOW CREATE TABLE trade_data;

Output : CREATE TABLE `Nidhi-workspace`.`flinkdemo-finserv`.`trade_data` (
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

2. Let's add all the data from trade_data table to trades_topic , please run the below command 

CREATE TABLE `Nidhi-workspace`.`flinkdemo-finserv`.`trades_topic` (
  `key` VARBINARY(2147483647),
  `side` VARCHAR(2147483647) NOT NULL COMMENT 'A simulated trade side (buy or sell or short)',
  `quantity` INT NOT NULL COMMENT 'A simulated random quantity of the trade',
  `symbol` VARCHAR(2147483647) NOT NULL COMMENT 'Simulated stock symbols',
  `price` INT NOT NULL COMMENT 'A simulated random trade price in pennies',
  `account` VARCHAR(2147483647) NOT NULL COMMENT 'Simulated accounts assigned to the trade',
  `userid` VARCHAR(2147483647) NOT NULL COMMENT 'The simulated user who executed the trade'
) ;

insert into trades_topic select * from trade_data;

Filtering in Flink : 

Filtering the trade data which has price and quantity greater than 0 .

Create a table filtered_trades

CREATE TABLE `Nidhi-workspace`.`flinkdemo-finserv`.`filtered_trades` (
  `key` VARBINARY(2147483647),
  `side` VARCHAR(2147483647) NOT NULL COMMENT 'A simulated trade side (buy or sell or short)',
  `quantity` INT NOT NULL COMMENT 'A simulated random quantity of the trade',
  `symbol` VARCHAR(2147483647) NOT NULL COMMENT 'Simulated stock symbols',
  `price` INT NOT NULL COMMENT 'A simulated random trade price in pennies',
  `account` VARCHAR(2147483647) NOT NULL COMMENT 'Simulated accounts assigned to the trade',
  `userid` VARCHAR(2147483647) NOT NULL COMMENT 'The simulated user who executed the trade'
) ;

Insert the data by filtering 

INSERT INTO filtered_trades
SELECT *
FROM trades_topic
WHERE quantity > 0
  AND price > 0
  AND (side = 'BUY' OR side = 'SELL');

Running Aggregates and Window functions 

We will run a tumbling window function which calaculates the total volume of the shares traded and sum of the price of each user for every 10 minutes 

Creating the table broker_trade_volume 

CREATE TABLE broker_trade_volume (
     window_start TIMESTAMP(3),
    window_end TIMESTAMP(3),
  userid STRING,
    total_number_of_shares BIGINT,
  total_amount_traded bigint
  
);

Running aggregate with windowing 

Insert into broker_trade_volume
SELECT window_start, window_end, userid , SUM(quantity) as `total_number_of_shares`, sum(price) as total_amount_traded
  FROM TABLE(
    TUMBLE(TABLE filtered_trades, DESCRIPTOR($rowtime), INTERVAL '10' minutes))
  GROUP BY userid , window_start, window_end;

The output of the above query is inserted into broker_trade_volume topic . I want to push the data into MongoDB for storing . 

Creating Mongo Atlas Sink connector : 

Configuration : 
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

Please note that the user should have read write access on the database , collection specified in the connector . The data flows from Confluent Cloud to Mongo Atlas trade_data_volume collection . 
Verify the data inside the Mongo Atlas UI . 
