
create table dm.product_category_analysis
(
 sku_key         		string         comment 'sku编码'
,sku_name        		string         comment 'sku名称'
,sku_status 	 		string         comment '（生命周期）商品状态'
,is_lock_fresh   		string         comment '是否锁鲜装'
,sku_level       		string         comment '商品等级'
,store_inventory  		double         comment '门店可售库存(箱)'
,warehouse_inventory 	double     	   comment '仓库可用库存(箱)'
,on_load_inventory   	double     	   comment '在途库存'
,total_xg_inventory   	double     	   comment '总库存'
,on_load_store_num   	int        	   comment '在途库存门店数'
,sku_store_num          int        	   comment '铺货门店数'
,have_sku_store_num  	int      	   comment '有货门店数'
,zy_spot_rate	 		double         comment '直营门店现货率'
,turnover_days   		double         comment '周转天数（不含在途）'
,on_load_turnover_days  string  	   comment '周转天数（含在途）'
,supplier_VLT  	 		string         comment '供应商VLT'
,etl_updatetime  		timestamp      comment 'etl_更新时间'
) PARTITIONED by (dt string)

