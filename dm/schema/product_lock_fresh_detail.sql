
create table dm.product_lock_fresh_detail
(
 date_key      	 string         comment '日期yyyy-MM-dd'
,store_code		 string         comment '门店编码'
,sku_key         string         comment 'sku编码'
,sku_name        string         comment 'sku名称'
,category_id	 bigint         comment '品类id'
,category_name   string         comment '品类名称'
,package_type    string         comment '包装单位'
,replishment  	 double      	comment '补货数量'
,etl_updatetime  timestamp      comment 'etl_更新时间'
)


