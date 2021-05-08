
-- hive  动态映射到hbase
CREATE EXTERNAL TABLE dm.store_group_sale_analysis_hbase(
  key       string comment "hbase rowkey"
,lable_map  map<string, string>

)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ("hbase.columns.mapping" = ":key,cf:#s:b")
TBLPROPERTIES("hbase.table.name" = "ns_olap:store_group_sale_analysis");

-- drop table if exists dm.store_group_sale_analysis
-- create table dm.store_group_sale_analysis
-- (
--  id                      string         comment '反转(支付日期+门店 202104201U70)'
-- ,pay_date	             string         comment '支付日期'
-- ,store_key  	         string         comment '销售门店编码'
-- ,introducer	             string         comment '介绍人员工号'
-- ,order_no                string          comment '订单号'
-- ,receive_amt            decimal(18,2)   comment '应收金额'
-- ,actual_amt             decimal(18,2)   comment '实收金额'
-- ,discount_amt           decimal(18,2)   comment '折扣（海信取）'
-- ,return_receive_amt	    decimal(18,2)   comment '退款应收金额'
-- ,return_actual_amt	    decimal(18,2)   comment '退款实收金额'
-- )PARTITIONED by (dt string)







