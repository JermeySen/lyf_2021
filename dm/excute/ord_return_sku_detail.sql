/*
--主题描述：门店商品退货明细
--存储策略：每天重刷60天数据，
--调度策略：T+1每天早上五点左右点执行 依赖执行近60天数据 调度任务号：273,209,252,912,1378
--维度    ：sku,天
--业务范围：直营门店，逆向单业务
--作者：zengjiamin
--日期：20210401
 */
with  reverse_order as (
select
a.reverse_order_no
,a.apply_reason
,a.apply_reason_id
,a.creator
,a.create_time
from ods.zt_tc_reverse_order  a
where a.create_time >= date_format(date_add(current_date(),-60),'yyyy-MM-dd')
)

insert overwrite table dm.ord_return_sku_detail PARTITION  (dt)
select
 s.l2_company_code
,s.l2_company_name
,s.region_owner
,s.area_owner
,a.store_key
,s.store_name
,o.creator
,a.order_no
,o.create_time
,a.sku_key
,sku.name
,abs(a.item_out_num)
,a.sales_unit
,abs(a.actual_amount)
,o.apply_reason
,o.apply_reason_id
,null as return_direction
,from_unixtime(unix_timestamp(current_timestamp()) + 28800)
,a.dt
from  dw.fact_trade_order_item a
inner join dw.dim_channel cl on a.channel_key = cl.channel_key
inner join reverse_order o   on a.order_no  = o.reverse_order_no
inner join dw.dim_sku sku    on sku.sku_key = a.sku_key
inner join dw.dim_store_daily_snapshot s on a.store_key = s.store_key and  s.dt = a.dt
where a.dt >=  date_format(date_add(current_date(),-60),'yyyy-MM-dd')
and   a.trade_status='-6' -- 退货
and   cl.channel_source = '01'  -- 直营
;

