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

with  is_open  as
(
select order_store.store_key
from (
    select
           distinct oi.store_key
    from dw.fact_trade_order oi
    inner join dw.dim_channel cl on oi.channel_key = cl.channel_key
    inner join dw.dim_store  s on s.store_key = oi.store_key
    where oi.dt = date_format(date_add(current_date(),-1),'yyyy-MM-dd')
    and   trade_status in  ('3','5','8','9','-9999','-6')
    and   cl.channel_source in ('01','04')
    ) order_store
inner join ods.zt_bdc_store  store on order_store.store_key = store.code
where trim(store.`desc`) = ''
)
insert into dw.dim_store_daily_snapshot
select
  s.store_key
 ,s.store_name
 ,s.store_properties
 ,s.store_type
 ,s.province
 ,s.city
 ,s.area
 ,s.trade_area_name
 ,s.trade_area_quality
 ,s.sale_area
 ,s.business_area
 ,s.area_owner
 ,s.region_owner
 ,s.company_code
 ,s.company_name
 ,s.store_level
 ,s.longitude
 ,s.latitude
 ,s.franchisee
 ,s.store_life
 ,s.expect_open_date
 ,s.actual_open_date
 ,s.close_date
 ,s.franchisee_name
 ,s.l2_company_code
 ,s.l2_company_name
 ,s.store_owner
 ,s.province_code
 ,s.city_code
 ,s.area_code
 ,date_format(date_add(current_date(),-1),'yyyy-MM-dd')
 ,case when o.store_key is not null then  1 else 0 end  as is_open
from dw.dim_store s
left join is_open o on s.store_key = o.store_key
;