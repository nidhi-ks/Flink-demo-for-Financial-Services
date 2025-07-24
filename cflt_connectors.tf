# --------------------------------------------------------
# Service Accounts (Connectors)
# --------------------------------------------------------
resource "confluent_service_account" "connectors" {
  display_name = "connectors-${random_id.id.hex}"
  description  = local.description
  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Access Control List (ACL)
# --------------------------------------------------------

# Cluster permissions for connectors
resource "confluent_kafka_acl" "connectors_source_describe_cluster" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  host          = "*"
  # Removed deprecated rest_endpoint and credentials
  lifecycle {
    prevent_destroy = false
  }
}

# Add ACL for DESCRIBE on all topics (often needed by connectors)
resource "confluent_kafka_acl" "connectors_source_describe_topics" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "" # An empty string with PREFIXED matches all topics
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  host          = "*"
  lifecycle {
    prevent_destroy = false
  }
}


# Demo topics for trade
# Renamed resources for uniqueness
resource "confluent_kafka_acl" "connectors_source_create_topic_trade" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "trade_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "CREATE"
  permission    = "ALLOW"
  host          = "*"
  # Removed deprecated rest_endpoint and credentials
  lifecycle {
    prevent_destroy = false
  }
}
resource "confluent_kafka_acl" "connectors_source_write_topic_trade" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "trade_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "WRITE"
  permission    = "ALLOW"
  host          = "*"
  # Removed deprecated rest_endpoint and credentials
  lifecycle {
    prevent_destroy = false
  }
}
resource "confluent_kafka_acl" "connectors_source_read_topic_trade" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "trade_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "READ"
  permission    = "ALLOW"
  host          = "*"
  # Removed deprecated rest_endpoint and credentials
  lifecycle {
    prevent_destroy = false
  }
}

# Demo topics for users
# Renamed resources for uniqueness
resource "confluent_kafka_acl" "connectors_source_create_topic_users" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "users_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "CREATE"
  permission    = "ALLOW"
  host          = "*"
  # Removed deprecated rest_endpoint and credentials
  lifecycle {
    prevent_destroy = false
  }
}
resource "confluent_kafka_acl" "connectors_source_write_topic_users" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "users_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "WRITE"
  permission    = "ALLOW"
  host          = "*"
  # Removed deprecated rest_endpoint and credentials
  lifecycle {
    prevent_destroy = false
  }
}
resource "confluent_kafka_acl" "connectors_source_read_topic_users" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "users_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "READ"
  permission    = "ALLOW"
  host          = "*"
  # Removed deprecated rest_endpoint and credentials
  lifecycle {
    prevent_destroy = false
  }
}

# Demo topics for transaction
# Renamed resources for uniqueness
resource "confluent_kafka_acl" "connectors_source_create_topic_transaction" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "transaction_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "CREATE"
  permission    = "ALLOW"
  host          = "*"
  # Removed deprecated rest_endpoint and credentials
  lifecycle {
    prevent_destroy = false
  }
}
resource "confluent_kafka_acl" "connectors_source_write_topic_transaction" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "transaction_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "WRITE"
  permission  = "ALLOW"
  host          = "*"
  # Removed deprecated rest_endpoint and credentials
  lifecycle {
    prevent_destroy = false
  }
}
resource "confluent_kafka_acl" "connectors_source_read_topic_transaction" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "transaction_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "READ"
  permission    = "ALLOW"
  host          = "*"
  # Removed deprecated rest_endpoint and credentials
  lifecycle {
    prevent_destroy = false
  }
}

# DLQ topics (for the connectors)
# Renamed resources for uniqueness
resource "confluent_kafka_acl" "connectors_source_create_topic_dlq" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "dlq-"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "CREATE"
  permission    = "ALLOW"
  host          = "*"
  # Removed deprecated rest_endpoint and credentials
  lifecycle {
    prevent_destroy = false
  }
}
resource "confluent_kafka_acl" "connectors_source_write_topic_dlq" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "dlq-"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "WRITE"
  permission    = "ALLOW"
  host          = "*"
  # Removed deprecated rest_endpoint and credentials
  lifecycle {
    prevent_destroy = false
  }
}
resource "confluent_kafka_acl" "connectors_source_read_topic_dlq" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "dlq-"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "READ"
  permission    = "ALLOW"
  host          = "*"
  # Removed deprecated rest_endpoint and credentials
  lifecycle {
    prevent_destroy = false
  }
}

# Consumer group
resource "confluent_kafka_acl" "connectors_source_consumer_group" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  resource_type = "GROUP"
  resource_name = "connect"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "READ"
  permission    = "ALLOW"
  host          = "*"
  # Removed deprecated rest_endpoint and credentials
  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Credentials / API Keys
# --------------------------------------------------------
resource "confluent_api_key" "connector_key" {
  display_name = "connector-${var.cc_cluster_name}-key-${random_id.id.hex}"
  description  = local.description
  owner {
    id          = confluent_service_account.connectors.id
    api_version = confluent_service_account.connectors.api_version
    kind        = confluent_service_account.connectors.kind
  }
  managed_resource {
    id          = confluent_kafka_cluster.cc_kafka_cluster.id
    api_version = confluent_kafka_cluster.cc_kafka_cluster.api_version
    kind        = confluent_kafka_cluster.cc_kafka_cluster.kind
    environment {
      id = confluent_environment.cc_handson_env.id
    }
  }
  # Removed unnecessary depends_on
  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Connectors
# --------------------------------------------------------

# datagen_users
resource "confluent_connector" "datagen_users" { # Renamed from datagen_products
  environment {
    id = confluent_environment.cc_handson_env.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  config_sensitive = {}
  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "${var.use_prefix}-users-connector" # Renamed connector name for uniqueness and clarity
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.connectors.id
    "kafka.topic"              = "users_data"
    "output.data.format"       = "AVRO"
    "quickstart"               = "USERS"
    "tasks.max"                = "1"
    "max.interval"             = "500"
  }
  depends_on = [
    confluent_kafka_acl.connectors_source_create_topic_users, # Corrected ACL dependency
    confluent_kafka_acl.connectors_source_write_topic_users,  # Corrected ACL dependency
    confluent_kafka_acl.connectors_source_read_topic_users,   # Corrected ACL dependency (though read not strictly needed for source)
    confluent_kafka_acl.connectors_source_create_topic_dlq,
    confluent_kafka_acl.connectors_source_write_topic_dlq,
    confluent_kafka_acl.connectors_source_read_topic_dlq,
    confluent_kafka_acl.connectors_source_consumer_group,
    confluent_kafka_acl.connectors_source_describe_topics, # Added dependency on new describe ACL
  ]
  lifecycle {
    prevent_destroy = false
  }
}

# datagen_trades
resource "confluent_connector" "datagen_trades" { # Renamed from datagen_customers for clarity
  environment {
    id = confluent_environment.cc_handson_env.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  config_sensitive = {}
  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "${var.use_prefix}-trades-connector" # Renamed connector name for uniqueness and clarity
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.connectors.id
    "kafka.topic"              = "trade_data"
    "output.data.format"       = "AVRO"
    "quickstart"               = "STOCK_TRADES"
    "tasks.max"                = "1"
    "max.interval"             = "500"
  }
  depends_on = [
    confluent_kafka_acl.connectors_source_create_topic_trade, # Corrected ACL dependency
    confluent_kafka_acl.connectors_source_write_topic_trade,  # Corrected ACL dependency
    confluent_kafka_acl.connectors_source_read_topic_trade,   # Corrected ACL dependency (though read not strictly needed for source)
    confluent_kafka_acl.connectors_source_create_topic_dlq,
    confluent_kafka_acl.connectors_source_write_topic_dlq,
    confluent_kafka_acl.connectors_source_read_topic_dlq,
    confluent_kafka_acl.connectors_source_consumer_group,
    confluent_kafka_acl.connectors_source_describe_topics, # Added dependency on new describe ACL
  ]
  lifecycle {
    prevent_destroy = false
  }
}

# datagen_transactions
resource "confluent_connector" "datagen_transactions" { # Renamed from datagen_customers for clarity
  environment {
    id = confluent_environment.cc_handson_env.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  config_sensitive = {}
  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "${var.use_prefix}-transactions-connector" # Renamed connector name for uniqueness and clarity
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.connectors.id
    "kafka.topic"              = "transaction_data"
    "output.data.format"       = "AVRO"
    "quickstart"               = "TRANSACTION"
    "tasks.max"                = "1"
    "max.interval"             = "500"
  }
  depends_on = [
    confluent_kafka_acl.connectors_source_create_topic_transaction, # Corrected ACL dependency
    confluent_kafka_acl.connectors_source_write_topic_transaction,  # Corrected ACL dependency
    confluent_kafka_acl.connectors_source_read_topic_transaction,   # Corrected ACL dependency (though read not strictly needed for source)
    confluent_kafka_acl.connectors_source_create_topic_dlq,
    confluent_kafka_acl.connectors_source_write_topic_dlq,
    confluent_kafka_acl.connectors_source_read_topic_dlq,
    confluent_kafka_acl.connectors_source_consumer_group,
    confluent_kafka_acl.connectors_source_describe_topics, # Added dependency on new describe ACL
  ]
  lifecycle {
    prevent_destroy = false
  }
}
