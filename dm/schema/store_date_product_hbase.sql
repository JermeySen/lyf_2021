

CREATE EXTERNAL TABLE dm.store_date_product_hbase(
  key       string                comment 'rowkey,门店+日期'
 ,sku_code  string                comment 'value:sku编码'
)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ("hbase.columns.mapping" = ":key,cf:sku_code")
TBLPROPERTIES("hbase.table.name" = "ns_olap:store_date_product");


-- hive  动态映射到hbase
-- CREATE EXTERNAL TABLE dm.store_date_product_hbase(
--   key       string                comment 'rowkey,门店+日期'
--  ,lable_map  map<string, string>  comment 'value:sku编码'
-- )
-- STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
-- WITH SERDEPROPERTIES ("hbase.columns.mapping" = ":key,cf:#s:b")
-- TBLPROPERTIES("hbase.table.name" = "ns_olap:store_date_product");


