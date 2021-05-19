drop table if exists dm.store_daily_completerate_hbase;
create EXTERNAL table dm.store_daily_completerate_hbase(
 key                    string          comment '主键门店+支付日期，反转'
,store_key             string          comment '门店编码'
,pay_date              string          comment '支付日期'
,target_sale_amt       decimal(18,4)   comment '目标销售金额'
,sale_amt              decimal(18,4)   comment '实际销售金额'
,order_cnt             bigint          comment '交易笔数'
)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES
(
"hbase.columns.mapping" =
":key
,cf:store_key
,cf:pay_date
,cf:d_month
,cf:target_sale_amt
,cf:sale_amt
,cf:order_cnt
")
TBLPROPERTIES("hbase.table.name" = "ns_olap:store_daily_completerate");