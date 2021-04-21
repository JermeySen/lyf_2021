drop table if exists dm.store_product_sale_analysis
create table dm.store_product_sale_analysis
(
 sale_type               string         comment '销售类型'
,pay_datetime	         string         comment '支付日期'
,store_key  	         string         comment '销售门店编码'
,channel	             string         comment '业务渠道'
,sku_category	         string         comment '商品类型'
,sku_key    	         string         comment '物料编码'
,receive_amount          double         comment '应收金额'
,actual_amount           double         comment '实收金额'
,return_receive_amount	 double         comment '退款应收金额'
,return_actual_amount	 double         comment '退款实收金额'
,pay_sku_quanlity        double         comment '支付sku数'
,return_sku_quanlity     double         comment '退货sku数'
,sku_unit  	             string      	comment 'sku单位'
,commission_rate         double         comment '提成率'
,commission_amount       double         comment '提成额'
,commission  	         double      	comment '佣金'
,etl_updatetime          timestamp      comment 'etl_更新时间'
)PARTITIONED by (dt string)


