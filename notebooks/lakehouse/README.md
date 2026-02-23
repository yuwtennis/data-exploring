## Querying BigLake Iceberg tables in BigQuery using Apache Spark

1. Set up creds

```shell
gcloud init
gcloud auth application-default login
```

2. Export metadata

https://docs.cloud.google.com/biglake/docs/biglake-iceberg-tables-in-bigquery#export-from-iceberg-tables

3. Read using spark

https://docs.cloud.google.com/biglake/docs/biglake-iceberg-tables-in-bigquery#read-iceberg-tables-from-spark

e.g Reading `bq-biglake-iceberg-table` exported from bigquery

Assuming metadata is exported in below directory  

`gs://bq-biglake-iceberg-table/sample-lh/metadata/`

```shell
spark-sql \
  --conf spark.sql.catalog.samples=org.apache.iceberg.spark.SparkCatalog \
  --conf spark.sql.catalog.samples.type=hadoop \
  --conf spark.sql.catalog.samples.warehouse='gs://bq-biglake-iceberg-table/'
```

```sql
SELECT * FROM samples.`sample-lh`
```