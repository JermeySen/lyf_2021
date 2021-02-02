drop table dm.product_inventory_bigscreen;
create table dm.product_inventory_bigscreen (
 date_key                    int            comment '日期yyyyMMdd'
,total_inventory_amount      decimal(20,6)  comment '库存总金额'
,shop_inventory_amount       decimal(20,6)  comment '门店库存总金额'
,warehouse_inventory_amount  decimal(20,6)  comment '仓库库存总金额'
,online_sku_counts           int            comment '在售商品数量'
,shop_inventory_rate         decimal(6,4)   comment '门店库存金额占比'
,warehouse_inventory_rate    decimal(6,4)   comment '仓库库存金额占比'
,sku_role                    string         comment '商品角色'
,online_sku_role_counts      decimal(20,6)  comment '在售角色商品数量'
,sku_role_rate               decimal(6,4)   comment '角色商品数量在总量中占比'
,sku_level                   string         comment '商品等级'
,sku_level_sale_amounts      decimal(20,6)  comment '各商品等级销售额'
,sku_level_sale_counts       decimal(20,6)  comment '各商品等级销售sku数量'
,sec_categroy                string         comment '二级品类名称(对应sku三级类目)'
,sec_categroy_sale_amounts   decimal(20,6)  comment '各个品类销售额'
,date_month                  string         comment '月份yyyyMM'
,new_sku_counts              int            comment '新品引进数量'
,date_day                    string         comment '日期yyyyMMdd'
,sku_level_spot_rate         decimal(6,4)   comment '商品等级现货率'
,sku_level_avg_turnover_days decimal(6,2)   comment '商品等级平均周转天数'
,sku_name                    string         comment '商品名称'
,sku_sale_amount             decimal(20,6)  comment '商品销售额'
,module_tag                  int            comment '模块标识'   --1总额 2商品角色分析 3各等级商品分布及销售额贡献 4 各品类销售贡献 5新品引进  6直营门店现货率/加盟现货率   7各等级商品平均周转天数 8A等级商品销售额词云
) PARTITIONED BY(dt int)
row format delimited fields terminated by '\u0001'
stored as TEXTFILE
;