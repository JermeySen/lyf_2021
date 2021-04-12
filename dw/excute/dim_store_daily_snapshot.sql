/*
--主题描述：门店日快照
--存储策略：每月存最后一天月累计数据
--调度策略：T+1每天早上八点执行 依赖执行前一天数据 调度任务号：1378
--维度    ：日，门店
--业务范围：
--作者：zengjiamin
--日期：20210408
---------------------------------------------------指标定义
*/
delete from  dw.dim_store_daily_snapshot where dt = date_format(date_add(current_date(),-1),'yyyy-MM-dd');
insert  into dw.dim_store_daily_snapshot
select
  store_key
 ,store_name
 ,store_properties
 ,store_type
 ,province
 ,city
 ,area
 ,trade_area_name
 ,trade_area_quality
 ,sale_area
 ,business_area
 ,area_owner
 ,region_owner
 ,company_code
 ,company_name
 ,store_level
 ,longitude
 ,latitude
 ,franchisee
 ,store_life
 ,expect_open_date
 ,actual_open_date
 ,close_date
 ,franchisee_name
 ,l2_company_code
 ,l2_company_name
 ,store_owner
 ,province_code
 ,city_code
 ,area_code
 ,date_format(date_add(current_date(),-1),'yyyy-MM-dd')
from dw.dim_store;