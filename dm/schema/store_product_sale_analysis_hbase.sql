drop table if exists dm.store_product_sale_analysis_hbase
create EXTERNAL table dm.store_product_sale_analysis_hbase
(
 id                      string         comment 'sku编码+业务类型+门店+支付日期 1488001282420210420'
,pay_date	             string         comment '支付日期'
,store_key  	         string         comment '销售门店编码'
,channel_type	         string         comment '业务渠道'
,channel_type_name	     string         comment '业务渠道'
,sku_key    	         string         comment '物料编码'
,receive_amt             decimal(18,2)  comment '应收金额'
,actual_amt              decimal(18,2)  comment '实收金额'
,return_receive_amt 	 decimal(18,2)  comment '退款应收金额'
,return_actual_amt 	     decimal(18,2)  comment '退款实收金额'
,pay_sku_amt             decimal(18,2)  comment '支付sku数量'
,return_sku_amt          decimal(18,2)  comment '退货sku数量'
,sale_unit  	         string      	comment '销售单位'
)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ("hbase.columns.mapping" = ":key,cf:pay_date,cf:store_key,cf:channel_type,cf:channel_type_name,cf:sku_key,cf:receive_amt,cf:actual_amt,cf:return_receive_amt,cf:return_actual_amt,cf:pay_sku_amt,cf:return_sku_amt,cf:sale_unit")
TBLPROPERTIES("hbase.table.name" = "ns_olap:store_product_sale_analysis");



