
/*
--主题描述：门店营业员业绩提成——正常销售报表
--存储策略：按天分区，
--调度策略：每天重跑近10天数据，任务号1398，依赖执行的调度任务号：209,252,912
--维度    ：sku,天,门店
--业务范围：直营加盟
--作者：zengjiamin
--日期：20210420
 */
--**********************************修改
insert overwrite table dm.store_product_sale_analysis PARTITION  (dt)
select
        '正常销售'                                                                          as sale_type
        ,date_format(oi.payment_time,'yyyy-MM-dd')                                         as  pay_datetime
        ,oi.store_key
        ,case when oi.is_community_corps = 1 then '社团核销' else  cl.channel_type_name end as channel_type_name
        ,case when st.sku_key is not null    then st.category_name else '其他' end          as sku_category
        ,sku.sku_key
        ,sum(oi.price * oi.jc_sku_quantity)                                                 as receive_amount
        ,sum(actual_amount)                                                                 as actual_amount
        ,sum(case when trade_status  = '-6'  then oi.price * oi.jc_sku_quantity end)        as return_receive_amount
        ,sum(case when trade_status  = '-6'  then oi.actual_amount end)       as return_actual_amount
        ,sum(case when trade_status != '-6' then oi.sku_quantity end)         as pay_sku_num
        ,sum(case when trade_status  = '-6' then oi.sku_quantity end)         as return_sku_num
        ,oi.sales_unit
        ,cast(null  as double)
        ,cast(null  as double)
        ,cast(null  as double)
        ,from_unixtime(unix_timestamp(current_timestamp()) + 28800) as etl_updatetime
        ,date_format(oi.payment_time,'yyyy-MM-dd')              as dt
from dw.fact_trade_order_item oi
inner join dw.dim_channel cl on oi.channel_key = cl.channel_key
inner join dw.dim_sku sku    on sku.sku_key    = oi.sku_key
left  join  dw.dim_sku_special_sort st on st.sku_key = oi.sku_key
where date_format(oi.payment_time,'yyyy-MM-dd') >=date_format(date_add(current_date(),-10),'yyyy-MM-dd')
and   oi.dt > date_format(date_add(current_date(),-60),'yyyy-MM-dd')
and   trade_status in  ('3','5','8','9','-9999','-6')  -- 扣除退款3，5，8，9 -9999 正向-6逆向
and   cl.channel_source in ('01','04') -- 直营  加盟
group by date_format(oi.payment_time,'yyyy-MM-dd')
        ,oi.store_key
        ,oi.is_community_corps
        ,cl.channel_type_name
        ,case when st.sku_key is not null    then st.category_name else '其他' end
        ,sku.sku_key
        ,oi.sales_unit
;



----------------------------------
