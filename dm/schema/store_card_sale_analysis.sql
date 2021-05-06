drop table if exists dm.store_card_sale_analysis
create table dm.store_card_sale_analysis
(
 sale_type               string         comment '销售类型 伊点卡、悠点卡、电子提货卡'
,pay_datetime	         string         comment '支付日期'
,store_key  	         string         comment '销售门店编码'
,card_number	         string         comment '提货卡券方案号'
,receive_amount          double         comment '应收金额'
,actual_amount           double         comment '实收金额'
,return_receive_amount	 double         comment '退款应收金额'
,return_actual_amount	 double         comment '退款实收金额'
,quanlity                double         comment '数量'
,commission_rate         double         comment '提成率'
,commission_amount       double         comment '提成额'
,commission  	         double      	comment '佣金'
,etl_updatetime          timestamp      comment 'etl_更新时间'
)PARTITIONED by (dt string)

