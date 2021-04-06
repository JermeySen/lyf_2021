/*
--主题描述：门店退货明细
--存储策略：每天重刷60天数据，
--调度策略：T+1每天早上五点左右点执行 依赖执行近60天数据 调度任务号：209,252,1378
--维度    ：门店,天
--业务范围：直营门店
--作者：zengjiamin
--日期：20210406
 */

insert overwrite table dm.ord_return_store_detail PARTITION  (dt)
select
 s.l2_company_code
,s.l2_company_name
,s.region_owner
,s.area_owner
,a.store_key
,s.store_name
,sum(a.actual_amount) + sum(nvl(a.third_party_amount,0))                           as  sale_amount
,sum(case when a.trade_status = '-6' then abs(a.actual_amount) end )               as return_amount 
,count(distinct case when a.trade_status = '-6' then a.order_no||a.store_key end ) as  return_ordernum  
,count(distinct case when a.trade_status = '-6' then a.dt  end )                   as  return_days      	
,count(distinct case when a.trade_status = '-6' and abs(a.actual_amount) >= 200 and abs(a.actual_amount) < 500  then a.order_no||a.store_key end ) as return_ordernum_1  
,count(distinct case when a.trade_status = '-6' and abs(a.actual_amount) >= 500 and abs(a.actual_amount) < 1000 then a.order_no||a.store_key end ) as return_ordernum_2  
,count(distinct case when a.trade_status = '-6' and abs(a.actual_amount) >= 1000 then a.order_no||a.store_key end )                                as return_ordernum_3  
,null as return_warehouse   
,null as return_store       
,from_unixtime(unix_timestamp(current_timestamp()) + 28800)                        as etl_updatetime
,dt
from  dw.fact_trade_order a
inner join dw.dim_channel cl on a.channel_key = cl.channel_key
inner join dw.dim_store_daily_snapshot s on a.store_key = s.store_key and  s.dt = a.dt
where a.dt >=  date_format(date_add(current_date(),-60),'yyyy-MM-dd')
and   a.trade_status in  ('3','5','8','9','-9999','-6') -- 扣除退款3，5，8，9 -9999 正向-6逆向
and   cl.channel_source = '01'  -- 直营
group by  s.l2_company_code
         ,s.l2_company_name
         ,s.region_owner
         ,s.area_owner 
         ,a.store_key 
         ,s.store_name
         ,a.dt