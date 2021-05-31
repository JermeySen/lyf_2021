/*
只要营业的门店
商品额：商品的售价
应收额：商品额-优惠额
实收额：商品额-优惠额-退款额
销售额：商品额-优惠额-退款额+补贴额
 */
-- 新增  支付金额（GMV），成本cost_sale_amt，毛利gross_profit_sales_amt，客单价
drop table dm.store_daily_business_firstchannel;
CREATE TABLE `dm.store_daily_business_firstchannel`(
`id`               string COMMENT '主键（渠道编码+业务类型编码+门店编码+支付日期,如：1488001107U20210415）',
`date_key`         string COMMENT '支付日期,格式：yyyyMMdd',
`store_key`        string COMMENT '门店编码',
`store_name`       string COMMENT '门店名称',
`store_daily_tag`  string COMMENT 'datekey+storecode:用来算店天',
`l2_company_code`  string COMMENT '二级子公司编码',
`l2_company_name`  string COMMENT '二级子公司名称',
`company_code`  string COMMENT '子公司编码',
`company_name`  string COMMENT '子公司名称',
`franchisee_code`  string COMMENT '加盟商编码',
`franchisee_name`  string COMMENT '加盟商名称',
`province_code`    string COMMENT '门店省份编码',
`province_name`    string COMMENT '门店省份名称',
`city_code`        string COMMENT '门店城市编码',
`city_name`        string COMMENT '门店城市名称',
`area_code`        string COMMENT '门店区域编码',
`area_name`        string COMMENT '门店区域名称',
`big_area_manager_code` string COMMENT '大区负责人工号',
`big_area_manager_name` string COMMENT '大区负责人姓名',
`area_manager_code` string COMMENT '区域负责人工号',
`area_manager_name` string COMMENT '区域负责人姓名',
`channel_source`          string COMMENT '一级渠道编码：直营，加盟，云商，app,经销中心',
`channel_source_name`     string COMMENT '一级渠道名称：直营，加盟，云商，app,经销中心',
`channel_type`          string COMMENT '业务子类型编码',
`channel_type_name`     string COMMENT '业务子类型名称',
`sales_amt_no_discount` decimal(18,4) COMMENT '商品额：商品原售价金额',
`sales_amt_receive`     decimal(18,4) COMMENT '应收额：商品额-优惠额',
`sales_amt`             decimal(18,4) COMMENT '实收额:应收金额-退款',
`sales_amt_achi`        decimal(18,4) COMMENT '销售额:应收金额-退款+补贴',
`purchase_amt_franchisee` decimal(18,4) COMMENT '进货额',
`cost_amt_franchisee`     decimal(18,4) COMMENT '加盟商成本',
`gross_profit_franchisee` decimal(18,4) COMMENT '加盟商毛利',
`purchase_ord_cnt_franchisee` int COMMENT '加盟商进货笔数' ,
`GMV`                   decimal(18,4) COMMENT 'GMV(云商,app):商品额-优惠额,与应收额规则一样，业务范围不同',
`sales_amt_discount`    decimal(18,4) COMMENT '优惠金额',
`sales_amt_refund`      decimal(18,4) COMMENT '退款金额',
`sales_amt_subsidy`     decimal(18,4) COMMENT '补贴金额(门店+app才有)',
`cost_amt_tax`          decimal(18,4) COMMENT '成本(含税)',
`cost_amt_no_tax`       decimal(18,4) COMMENT '成本(不含税)',
`gross_profit_tax`      decimal(18,4) COMMENT '毛利(含税)',
`gross_profit_no_tax`   decimal(18,4) COMMENT '毛利(不含税)',
`deal_ord_cnt`          int COMMENT '成交笔数（客流:正逆向订单数量绝对值相加，均从POS上取数）',
`jc_sale_sku_qty`    	decimal(18,2) COMMENT '商品基础单位销量',
`jc_sale_sku_r_qty`  	decimal(18,2) COMMENT '商品基础单位销量(逆向)',
`etl_updatetime`        timestamp     COMMENT 'etl时间'
)
PARTITIONED BY (
`dt` string COMMENT '按支付日期，每天一个分区，格式：yyyy-MM-dd')
;

