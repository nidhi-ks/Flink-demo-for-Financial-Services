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

Running Terraform scripts:

Before you can run this terraform section you need the following software:
1. User account on Confluent Cloud
2. Local install of Terraform
3. Local install Confluent CLI, install the cli

Create an API Key using confluent cli:

confluent login
confluent api-key create --resource cloud --description "API for terraform"
It may take a couple of minutes for the API key to be ready.
Save the API key and secret. The secret is not retrievable later.

API Key    | <your generated key>                                          
API Secret | <your generated secret>                                      


Unzip the provided terraform-techsummit-2024.zip and perform the following command within the unzipped directory:

cat > terraform.tfvars <<EOF
confluent_cloud_api_key = "{Cloud API Key}"
confluent_cloud_api_secret = "{Cloud API Key Secret}"
use_prefix = "{Your Name}"
EOF



