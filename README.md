# Shift-Left Pattern with Flink SQL and Confluent Cloud Workshop

This self-paced workshop demonstrates how to implement a shift-left pattern for improved data quality and governance in a brokerage scenario using **Apache Flink SQL** and **Confluent Cloud**.

## Workshop Objectives
- Understand the shift-left pattern and its benefits in data processing
- Learn to use Apache Flink SQL for real-time data processing
- Implement data quality checks and governance policies early in the data pipeline
- Perform stateless and stateful operations on streaming data
- Integrate with **Confluent Cloud** and **MongoDB**

## Prerequisites
- Basic knowledge of SQL
- Familiarity with stream processing concepts
- A **Confluent Cloud** account

## Workshop Structure
1. Introduction to the shift-left pattern and use case
2. Setting up the environment
3. Generating sample data
4. Filtering and cleaning data
5. Performing aggregations
6. Implementing joins
7. Sinking processed data

**Happy learning!**

## Introduction to Shift-Left Pattern and Use Case

The shift-left pattern in data processing involves moving data quality checks and governance policies earlier in the data pipeline. This approach helps to:
- Identify and address data quality issues early
- Reduce costs associated with downstream data cleanup
- Improve overall data reliability and trustworthiness

In our brokerage use case, we'll implement this pattern to process trade data more efficiently and accurately. We'll use **Apache Flink SQL** with **Confluent Cloud** to:
- Generate and ingest trade data
- Apply data quality filters
- Perform real-time aggregations
- Join streaming data with static data
- Sink processed data for further analysis

By the end of this workshop, you'll have a practical understanding of how to implement the shift-left pattern using **Flink SQL** and **Confluent Cloud**.

## Running Terraform Scripts

Before you can run this Terraform section, ensure you have the following software:
- A user account on **Confluent Cloud**
- Local install of **Terraform**
- Local install of the **Confluent CLI**

### Create an API Key using Confluent CLI:
```bash
confluent login
```
```bash
confluent api-key create --resource cloud --description "API for terraform"
```

It may take a couple of minutes for the API key to be ready.
Save the API key and secret. The secret is not retrievable later.

```bash
API Key    | <yourkey>                                          
API Secret | <yoursecret>                                      
```

```bash
cat > terraform.tfvars <<EOF
confluent_cloud_api_key = "{Cloud API Key}"
confluent_cloud_api_secret = "{Cloud API Key Secret}"
use_prefix = "{Your Name}"
EOF
```

Run the following commands to provision the environment

```bash
terraform init
terraform plan
terraform apply
```

After completing the tasks, please remove your environment to avoid costs. You can recreate it anytime, using the steps above

```bash
terraform destroy
```




