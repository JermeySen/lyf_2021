--  set hive.auto.convert.join=false
-- 10043  状态未知 10058
/*
--主题描述：商品品类报表
--存储策略：按天分区，
--调度策略：T+1每天早上五点左右点执行 ，任务号1394，依赖执行的调度任务号：209,252,1378
--维度    ：sku,天
--业务范围：直营正常营业门店sku,
--作者：zengjiamin
--日期：20210416
 */
--**********************************修改
with inventory as (
     select
           iso.dt                                                                                           as date_key
          ,iso.sku_key
          ,sum(case when   substring(st.store_key,2,1)  <> 'R' and st.store_key is not null
                    then  nvl(jc_real_qty,0) - nvl(jc_lock_qty,0) end)                                      as store_jc_inventory
          ,sum(case when   substring_index(wh.real_warehouse_key,'-',-1) in ('C001','C008','A008','C003')
                    then   nvl(jc_real_qty,0) - nvl(jc_lock_qty,0)  end)                                    as warehouse_jc_inventory
          ,sum(case when  substring(st.store_key,2,1)  <> 'R' and st.store_key is not null
                    then  nvl(iso.jc_onroad_qty,0) end)                                                      as onload_jc_inventory

          ,sum(case when  substring(st.store_key,2,1)  <> 'R' and st.store_key is not null
                    then  nvl(xg_real_qty,0) - nvl(xg_lock_qty,0) end)                                      as store_xg_inventory
          ,sum(case when   substring_index(wh.real_warehouse_key,'-',-1) in ('C001','C008','A008','C003')
                    then   nvl(xg_real_qty,0) - nvl(xg_lock_qty,0)  end)                                    as warehouse_xg_inventory
          ,sum(case when  substring(st.store_key,2,1)  <> 'R' and st.store_key is not null
                    then  nvl(iso.xg_onroad_qty,0) end)                                                      as onload_xg_inventory
          ,count(distinct case when iso.xg_onroad_qty > 0  and substring(wh.shop_code,2,1)  <> 'R'
                                                           and st.store_key is not null  then wh.shop_code end )                      as on_load_store_num
          ,count(distinct case when nvl(xg_real_qty,0) - nvl(xg_lock_qty,0) > 0  and substring(wh.shop_code,2,1)  <> 'R'
                                                                                 and st.store_key is not null then wh.shop_code end ) as have_sku_store_num
     from dw.fact_inventory_stock_onhand  iso
     inner join dw.dim_warehouse wh on wh.real_warehouse_key = iso.real_warehouse_key
     left join dw.dim_store_daily_snapshot st on st.store_key = wh.shop_code and st.dt = date_format(date_add(current_date(),-1),'yyyy-MM-dd')
                                               and st.is_open = 1 -- 正常营业门店
     where iso.dt =  date_format(date_add(current_date(),-1),'yyyy-MM-dd')
     and   iso.is_available = 1
     and ((substring(st.store_key,2,1)  <> 'R' and st.store_key is not null) or substring_index(wh.real_warehouse_key,'-',-1) in ('C001','C008','A008','C003'))
     group by iso.dt, iso.sku_key
)

,  turnover_days as (
      select
             ivt.sku_key
            ,(nvl(ivt.store_jc_inventory,0.0) + nvl(ivt.warehouse_jc_inventory,0.0)) / qty.sale_28qty                            as sku_turnover_days
            ,(nvl(ivt.store_jc_inventory,0.0) + nvl(ivt.warehouse_jc_inventory,0.0) + nvl(ivt.onload_jc_inventory,0.0)) / qty.sale_28qty  as sku_onload_turnover_days
      from inventory ivt
      left join (
                    select
                           oi.sku_key
                          ,sum(oi.jc_sku_quantity) / 28    as  sale_28qty
                    from dw.fact_trade_order_item oi
                    inner join dw.dim_store_daily_snapshot st on st.store_key = oi.store_key and st.dt = date_format(date_add(current_date(),-1),'yyyy-MM-dd')
                    inner join dw.dim_channel cl on oi.channel_key = cl.channel_key
                    where oi.date_key >=  date_format(date_add(current_date(),-28),'yyyyMMdd')     -- 支付时间
                    and   oi.dt > date_format(date_add(current_date(),-60),'yyyy-MM-dd')
                    and   oi.trade_status in  (3,5,8,9,-9999,-6)
                    and   cl.channel_source = '01'  -- 直营
                    and   st.is_open = 1  --正常营业门店
                    and   substring(oi.store_key,2,1) <> 'R'
                    group by oi.sku_key
                ) qty on ivt.sku_key = qty.sku_key
)

,  spot_rate as (
               select
                     kpi.dt                                                    as date_day
                    ,kpi.sku_key                                               as sku_key
                    ,sum(out_stock)  / count(distinct kpi.node_id,kpi.sku_key) as sku_spot_rate
               from dm.warehouse_inventory_all_kpi kpi
               inner join dw.dim_store_daily_snapshot st on st.store_key = kpi.node_id and st.dt = date_format(date_add(current_date(),-1),'yyyy-MM-dd')
               where kpi.dt =  date_format(date_add(current_date(),-1),'yyyy-MM-dd')
                and substring(kpi.node_id,2,1) <> 'R' -- 排除加盟
                and kpi.node_type = 'store'
                and st.is_open = 1
                group by  kpi.dt ,kpi.sku_key
)

, sku_status  as (

                select   distinct
                         sku_code as sku_key
                        ,case status when 'TOSUBMIT'    then '待提交'
                               when 'POTENTIAL'   then '潜在'
                               when 'INTENTIONAL' then '意向品'
                               when 'OFFICIAL'    then '正式商品'
                               when 'NEW'         then '新品(已上市)'
                               when 'NORMAL'      then '正常'
                               when 'PRECLOSE'    then '预下市'
                               when 'CLOSED'      then '已下市'
                               when 'PAUSE'       then '暂停销售'
                               else '未知'        end   as  sku_status
                 from ods.kp_scm_sku_mgr
                 where dt = date_format(date_add(current_date(),-1),'yyyy-MM-dd')
)

,  vlt as (
  select
       sku_code              as sku_key
      ,avg(param_value) / 24 as supplier_VLT
 from ods.kp_scm_notes_sku_property
 where param_code = 'P0001' and is_deleted = 0
 and start_node_type = 4  -- 供应商
 and end_node_type = 3 -- cdc 仓库
 group by sku_code
)
insert overwrite table dm.product_category_analysis PARTITION  (dt)
select
     sku.sku_key
    ,sku.name
    ,status.sku_status
    ,case when sku.category_four_code = '10103413' then '是' else '否' end      as is_lock_fresh
    ,nvl(sku_x_sale_level,'D')                                                  as sku_level
    ,iy.store_xg_inventory
    ,iy.warehouse_xg_inventory
    ,iy.onload_xg_inventory
    ,nvl(iy.store_xg_inventory,0) + nvl(iy.warehouse_xg_inventory,0) + nvl(iy.onload_xg_inventory,0) as total_xg_inventory
    ,iy.on_load_store_num
    ,kp_sku.sku_store_num
    ,iy.have_sku_store_num
    ,sr.sku_spot_rate
    ,td.sku_turnover_days
    ,td.sku_onload_turnover_days
    ,vlt.supplier_VLT
    ,from_unixtime(unix_timestamp(current_timestamp()) + 28800)                  as etl_updatetime
    ,date_format(date_add(current_date(),-1),'yyyy-MM-dd')                       as dt
from (
      select
           sku.sku_code                     as sku_key
          ,count(distinct sku.store_code)   as sku_store_num
      from  ods.kp_scm_store_sku sku
      inner join dw.dim_store_daily_snapshot st on st.store_key = sku.store_code and st.dt = date_format(date_add(current_date(),-1),'yyyy-MM-dd')
      where sku.is_available = 1
      and   sku.is_delete = 0
      and   substring(sku.store_code,2,1) <> 'R'
      and   st.is_open = 1
      group by sku.sku_code
     ) kp_sku
inner join dw.dim_sku sku    on kp_sku.sku_key = sku.sku_key
left  join sku_status status on kp_sku.sku_key = status.sku_key
left  join inventory  iy     on kp_sku.sku_key = iy.sku_key
left  join spot_rate  sr     on kp_sku.sku_key = sr.sku_key
left  join turnover_days td  on kp_sku.sku_key = td.sku_key
left  join vlt               on kp_sku.sku_key = vlt.sku_key
left  join (
                select
                      sku_key
                     ,sku_x_sale_level
                from  temp.ml_sku_x_28days_abcd_level
                where dim_id = 3  -- 渠道分类
                and   three_level_code = '01'
            ) sl   on kp_sku.sku_key = sl.sku_key