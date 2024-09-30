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
