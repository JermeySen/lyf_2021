/*
商品额：商品的售价
应收额：商品额-优惠额
实收额：商品额-优惠额-退款额
销售额：商品额-优惠额-退款额+补贴额

app外卖  金额取线上 ，数量， 单位取线下。

 */
drop table dm.product_store_daily_analysis;
CREATE TABLE `dm.product_store_daily_analysis`(
`id`             string COMMENT '主键（sku编码+业务类型编码+门店编码+支付日期,如：1488001107U20210415）',
`store_code`     string COMMENT '门店编码',
`store_name`     string COMMENT '门店名称',
`store_type`     string COMMENT '门店类型：直营，加盟',
`is_open`        string COMMENT '门店是否营业（1是 0否）',
`l2_company_code`  string COMMENT '二级子公司编码',
`l2_company_name`  string COMMENT '二级子公司名称',
`province_code`    string COMMENT '门店省份编码',
`province_name`    string COMMENT '门店省份名称',
`city_code`        string COMMENT '门店城市编码',
`city_name`        string COMMENT '门店城市名称',
`area_code`        string COMMENT '门店区域编码',
`area_name`        string COMMENT '门店区域名称',
`franchisee_code`  string COMMENT '加盟商编码',
`franchisee_name`  string COMMENT '加盟商名称',
`business_code`  string COMMENT '业务类型编码',
`business_name`  string COMMENT '业务类型名称',
`spu_code`       string COMMENT 'spu编码',
`spu_type`       string COMMENT 'spu类型',
`sku_code`       string COMMENT 'sku编码',
`sku_name`       string COMMENT 'sku名称',
`sku_status`     string COMMENT 'sku状态',
`second_material_code`  string COMMENT '二级物料编码',
`second_material_name`  string COMMENT '二级物料名称',
`brand_id`       string COMMENT '品牌id',
`brand_name`     string COMMENT '品牌名称',
`sku_xg_sale_level`       string COMMENT '销量商品等级',
`sku_sale_amt_level`      string COMMENT '销售额商品等级',
`is_gift`               string COMMENT '是否赠品',
`category_one_code`     string COMMENT '一级类目code',
`category_one_name`     string COMMENT '一级类目name',
`category_two_code`     string COMMENT '二级类目code',
`category_two_name`     string COMMENT '二级类目name',
`category_three_code`   string COMMENT '三级类目code',
`category_three_name`   string COMMENT '三级类目name',
`category_four_code`    string COMMENT '四级类目code',
`category_four_name`    string COMMENT '四级类目name',
`pay_date`              string COMMENT '支付日期,格式：yyyyMMdd',
`sales_amt_no_discount` decimal(18,4) COMMENT '商品额——>商品额:商品原售价金额',
`sales_amt`             decimal(18,4) COMMENT '实收金额——>商品额-优惠额-退款。补贴金额:（sku编码QT0001）补贴金额',
`sales_amt_discount`    decimal(18,4) COMMENT '优惠金额',
`sales_amt_no_discount_refund`      decimal(18,4) COMMENT '退款应收金额',
`sales_amt_refund`                  decimal(18,4) COMMENT '退款实收金额',
`jc_unit_code`          string        COMMENT '商品基础单位',
`jc_sale_sku_qty`    	decimal(18,2) COMMENT '商品基础单位销量(正向)',
`jc_sale_sku_r_qty`  	decimal(18,2) COMMENT '商品基础单位销量(逆向)',
`xs_unit_code`          string        COMMENT '商品销售单位',
`xs_sale_sku_qty`    	decimal(18,2) COMMENT '商品销售单位销量(正向)',
`xs_sale_sku_r_qty`  	decimal(18,2) COMMENT '商品销售单位销量(逆向)',
`xg_unit_code`          string        COMMENT '商品箱规单位',
`xg_sale_sku_qty`    	decimal(18,2) COMMENT '商品箱规单位销量(正向)',
`xg_sale_sku_r_qty`  	decimal(18,2) COMMENT '商品箱规单位销量(逆向)',
`sales_ord_cnt`         int COMMENT '订单笔数(正向)',
`sales_ord_cnt_refund`  int COMMENT '订单笔数(逆向)',
`passenger_flow`        int COMMENT '成交笔数（客流:正逆向订单数量绝对值相加，均从POS上取数）',  -- 备注修改
-- *********************************************新增
`company_code`         string COMMENT '子公司编码',
`company_name`         string COMMENT '子公司名称',
`channel_source`       string COMMENT '渠道编码',
`channel_source_name`  string COMMENT '渠道编码名称',
`sales_amt_receive`     decimal(18,4) COMMENT '应收额——>商品额-优惠额',


`etl_updatetime`        timestamp  COMMENT 'etl时间'
)
PARTITIONED BY (
`dt` string COMMENT '按支付日期，每天一个分区，格式：yyyy-MM-dd')
;

