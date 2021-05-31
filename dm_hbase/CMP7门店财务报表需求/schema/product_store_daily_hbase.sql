
CREATE EXTERNAL TABLE dm.product_store_daily_hbase(
id string COMMENT '主键（sku编码+门店编码+支付日期,反转）',
pay_date string COMMENT '支付日期,格式：yyyyMMdd',
store_code string COMMENT '门店编码',
store_name string COMMENT '门店名称',
store_type string COMMENT '门店类型',
store_level string COMMENT '门店等级',
l2_company_code string COMMENT '门店所属子公司编码',
l2_company_name string COMMENT '门店所属子公司名称',
is_open string COMMENT '门店是否营业（1是 0否）',
sku_code string COMMENT 'sku编码',
sku_name string COMMENT 'sku名称',
sku_xg_sale_level string COMMENT '销量商品等级',
sku_sale_amt_level string COMMENT '销售额商品等级',
sales_amt_no_discount decimal(18,2) COMMENT '应收金额',
sales_amt decimal(18,2) COMMENT '实收金额',
sales_amt_discount decimal(18,2) COMMENT '优惠金额',
sales_amt_no_discount_refund decimal(18,2) COMMENT '退款应收金额',
sales_amt_refund decimal(18,2) COMMENT '退款实收金额',
jc_unit_code string COMMENT '商品基础单位',
jc_sale_sku_qty decimal(18,2) COMMENT '商品基础单位销量',
jc_sale_sku_r_qty decimal(18,2) COMMENT '商品基础单位销量(逆向)',
xs_unit_code string COMMENT '商品销售单位',
xs_sale_sku_qty decimal(18,2) COMMENT '商品销售单位销量',
xs_sale_sku_r_qty decimal(18,2) COMMENT '商品销售单位销量(逆向)',
xg_unit_code string COMMENT '商品箱规单位',
xg_sale_sku_qty decimal(18,2) COMMENT '商品箱规单位销量',
xg_sale_sku_r_qty decimal(18,2) COMMENT '商品箱规单位销量(逆向)',
sales_ord_cnt int COMMENT '订单笔数',
sales_ord_cnt_refund int COMMENT '订单笔数(逆向)',
passenger_flow int COMMENT '客流（取正向订单数量+逆向订单数量，即：正逆向订单数量绝对值相加，均从POS上取数）',
jc_sale_sku_qty_7dyas_lv decimal(18,2) COMMENT '近7日均销量(优先等级1.子公司下门店等级维度 2.子公司维度)'
)
ROW FORMAT SERDE
'org.apache.hadoop.hive.hbase.HBaseSerDe'
STORED BY
'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES (
'hbase.columns.mapping'=':key\r\n,cf:pay_date\r\n,cf:store_code\r\n,cf:store_name\r\n,cf:store_type\r\n,cf:store_level\r\n,cf:l2_company_code\r\n,cf:l2_company_name\r\n,cf:is_open`\r\n,cf:sku_code\r\n,cf:sku_name\r\n,cf:sku_xg_sale_level\r\n,cf:sku_sale_amt_level\r\n,cf:sales_amt_no_discount\r\n,cf:sales_amt\r\n,cf:sales_amt_discount\r\n,cf:sales_amt_no_discount_refund\r\n,cf:sales_amt_refund\r\n,cf:jc_unit_code\r\n,cf:jc_sale_sku_qty\r\n,cf:jc_sale_sku_r_qty\r\n,cf:xs_unit_code\r\n,cf:xs_sale_sku_qty\r\n,cf:xs_sale_sku_r_qty\r\n,cf:xg_unit_code\r\n,cf:xg_sale_sku_qty\r\n,cf:xg_sale_sku_r_qty\r\n,cf:sales_ord_cnt\r\n,cf:sales_ord_cnt_refund\r\n,cf:passenger_flow\r\n,cf:jc_sale_sku_qty_7dyas_lv\r\n',
'serialization.format'='1')
TBLPROPERTIES (
'bucketing_version'='2',
'hbase.table.name'='ns_olap:product_store_daily',
'last_modified_by'='zengjiamin',
'last_modified_time'='1621835045',
'transient_lastDdlTime'='1621835045');


