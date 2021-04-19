/*
--主题描述：门店商品退货明细
--存储策略：每天重刷60天数据，
--调度策略：T+1每天早上五点左右点执行 依赖执行近60天数据 调度任务号：273,209,252,912,1378
--维度    ：sku,天
--业务范围：直营加盟门店，逆向单业务
--作者：zengjiamin
--日期：20210401
--**********************************修改
--日期 20210408  zengjiamin  员工工号换成员工名称
 */
with  reverse_order as (
select
a.reverse_order_no
,a.apply_reason
,a.apply_reason_id
,a.creator
,a.create_time
,a.apply_time
,a.reverse_order_no_out
,b.reverse_destination
from ods.zt_tc_reverse_order  a
inner join ods.zt_tc_reverse_order_line  b on a.id =  b.reverse_order_id
where a.apply_time >= date_format(date_add(current_date(),-60),'yyyy-MM-dd')
)

insert overwrite table dm.ord_return_sku_detail PARTITION  (dt)
select
 s.l2_company_code
,s.l2_company_name
,ro.cn as region_owner
,ao.cn as area_owner
,a.store_key
,s.store_name
,cl.channel_source_name
,o.creator
,a.order_no
,o.reverse_order_no_out
,o.apply_time
,a.sku_key
,sku.name
,abs(a.item_out_num)  as item_out_num
,a.sales_unit
,abs(a.actual_amount) as actual_amount
,o.apply_reason
,o.apply_reason_id
,o.reverse_destination  as return_direction
,from_unixtime(unix_timestamp(current_timestamp()) + 28800) as etl_updatetime
,a.dt
from  dw.fact_trade_order_item a
inner join dw.dim_channel cl on a.channel_key = cl.channel_key
inner join reverse_order o   on a.order_no  = o.reverse_order_no
inner join dw.dim_sku sku    on sku.sku_key = a.sku_key
inner join dw.dim_store_daily_snapshot s on a.store_key = s.store_key and  s.dt = a.dt
left join (select employee_number,cn from ods.zt_uc_user_employee group by employee_number,cn) ro on ro.employee_number = s.region_owner
left join (select employee_number,cn from ods.zt_uc_user_employee group by employee_number,cn) ao on ao.employee_number = s.area_owner
where a.dt >=  date_format(date_add(current_date(),-60),'yyyy-MM-dd')
and   a.trade_status='-6' -- 退货
and   cl.channel_source in ('01' ,'04') -- 直营  加盟
;

