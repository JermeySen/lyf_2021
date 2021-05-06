
/*
--主题描述：门店营业员业绩提成——正常销售报表
--存储策略：按天分区，
--调度策略：每天重跑近10天数据，任务号1398，依赖执行的调度任务号：1408
--维度    ：sku,天,门店
--业务范围：直营加盟
--作者：zengjiamin
--日期：20210420
 */
--**********************************修改
insert into  dm.store_product_sale_analysis_hbase
select
    reverse(sda.sku_code||sda.business_code||sda.store_code||sda.pay_date) as row_key
   ,sda.pay_date
   ,sda.store_code
   ,sda.business_code
   ,sda.business_name
   ,sda.sku_code
   ,sda.sales_amt_no_discount
   ,sda.sales_amt
   ,sda.sales_amt_no_discount_refund
   ,sda.sales_amt_refund
   ,sda.xs_sale_sku_qty
   ,sda.xs_sale_sku_r_qty
   ,sda.xs_unit_code
from dm.product_store_daily_analysis sda
where sda.dt = date_format(date_add(current_date(),-1),'yyyy-MM-dd')  ;




----------------------------------
