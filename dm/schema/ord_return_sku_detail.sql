create table dm.ord_return_sku_detail
(
 company_code    	string         comment '公司编码'
,company_name       string         comment '公司名称'
,region_owner       string         comment '片区负责人'
,area_owner   		string         comment '城区负责人'
,store_key      	string         comment '门店编码'
,store_name      	string         comment '门店名称'
,creator    		string         comment '操作营业员工号'
,order_no  			string     	   comment '退货流水号'
,return_time        timestamp      comment '退货日期（日时分秒）'
,sku_key      		string         comment '退货商品SKU编码'
,sku_name  		 	string         comment '退货商品名称'
,return_num      	double         comment '数量'
,sales_unit      	string         comment '数量单位'
,return_amount    	double         comment '退货额'
,apply_reason  		string         comment '退货原因'
,apply_reason_id    int            comment '退货原因id'
,return_direction   string         comment '退货去向'
,etl_updatetime  	timestamp      comment 'etl_更新时间'
) PARTITIONED by (dt string)