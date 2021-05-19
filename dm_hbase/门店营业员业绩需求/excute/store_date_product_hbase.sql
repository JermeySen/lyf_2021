/*
--主题描述：门店营业员业绩提成——正常报表，二级索引
--存储策略：hive映射到hbase,  rowkey='反转(支付日期+门店)'
--调度策略：每天跑近1天数据，任务号1414，依赖执行的调度任务号：1408

--业务范围：直营加盟
--作者：zengjiamin
--日期：20210508
 */
--**********************************修改
insert into dm.store_date_product_hbase
select
 reverse(store_code||pay_date) id
,concat_ws(',',collect_set(sku_code))  sku_code
from dm.product_store_daily_analysis
where dt >= date_format(date_add(current_date(),-1),'yyyy-MM-dd')
group by store_code,pay_date;