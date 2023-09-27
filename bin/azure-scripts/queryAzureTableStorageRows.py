#!/usr/bin/env python3

from azure.data.tables import TableServiceClient

connection_string = ""
table_name = ""

table_service_client = TableServiceClient.from_connection_string(connection_string)
table_client = table_service_client.get_table_client(table_name)
unique_partition_keys = set()

query_result = table_client.query_entities("")

for entity in query_result:
    partition_key = entity["PartitionKey"]
    row_key = entity["RowKey"]
    print("Partition Key: {}, Row Key: {}".format(partition_key, row_key))

table_service_client.close()

