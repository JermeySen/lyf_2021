create table dm.ord_return_store_detail
(
 company_code    	string         comment '公司编码'
,company_name       string         comment '公司名称'
,region_owner       string         comment '片区负责人'
,area_owner   		string         comment '城区负责人'
,store_key      	string         comment '门店编码'
,store_name      	string         comment '门店名称'
,sale_amount    	double         comment '销售额'
,return_amout  		double     	   comment '退货额'
,return_ordernum    int            comment '退货笔数'
,return_days      	int            comment '退货天数'
,return_ordernum_1  int            comment '退货额[200-500)的笔数'
,return_ordernum_2  int            comment '退货额[500-1000)的笔数'
,return_ordernum_3  int            comment '退货额>=1000的笔数'
,return_warehouse   double         comment '退仓（金额）'
,return_store       double         comment '退格斗（金额)'
,etl_updatetime  	timestamp      comment 'etl_更新时间'
) PARTITIONED by (dt string)