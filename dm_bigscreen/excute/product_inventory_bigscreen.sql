/**
--主题描述：大屏—商品库存
--数据探查：保留近30天，每天203条左右
--调度策略：T+1每天早上八点执行 依赖执行前一天数据 调度任务号：1295  同步任务号号：1296
--作者：zengjiamin
--日期：20210113
--备注：统计全渠道销售额过滤线下的门店自营外卖substr(channel_key,5,6) <> _100_7
        统计全渠道销量过滤线上的app自营外卖 substr(channel_key,5,6)  <> _102_7
        销售订单的全渠道:channl source:01 直营,02 app,03 电商-ToC,04 加盟,77 ToB-销售易-团购,88 ToB-销售易-经销商

修改日志: 20210222 zengjiamin  现货率近7天改成近30天。
**/

-- ****************************************总额板块
-- 保留近30天数据
delete from  dm.product_inventory_bigscreen
where dt <= cast(date_format(date_add(current_date(),-30),'yyyyMMdd') as int);
-- 删除中间临时表
drop table if exists temp.end_result;
-- 创建查询结果表临时
create table temp.end_result as
with  inventory as (
select
       date_key
      ,total_inventory_amount
      ,shop_inventory_amount
      ,warehouse_inventory_amount
      ,shop_inventory_amount / total_inventory_amount        as  shop_inventory_rate
      ,warehouse_inventory_amount / total_inventory_amount   as  warehouse_inventory_rate
from (
     select
            cast(date_format(date_add(current_date(),-1),'yyyyMMdd') as int)                as date_key
           ,sum(ssg.gross_price * (iso.jc_real_qty - iso.jc_lock_qty))         as total_inventory_amount
           ,sum(case when wh.shop_code is not null
                     then ssg.gross_price * (iso.jc_real_qty - iso.jc_lock_qty)
                     end )                                                     as shop_inventory_amount
           ,sum(case when wh.shop_code is null
                     then ssg.gross_price * (iso.jc_real_qty - iso.jc_lock_qty)
                     end )                                                     as warehouse_inventory_amount
     from dw.fact_inventory_stock_onhand  iso
     inner join dw.dim_store_sku_grossprice_1  ssg on  iso.sku_key = ssg.sku_code
                                                   and ssg.dt =  date_format(date_add(current_date(),-1),'yyyyMMdd')
                                                   and ssg.store_code = 'X001'        --取总仓成本价
     inner join dw.dim_warehouse wh on wh.real_warehouse_key = iso.real_warehouse_key
     where iso.dt =  date_format(date_add(current_date(),-1),'yyyy-MM-dd')
     and   iso.is_available = 1
     and   wh.real_warehouse_type <> 15     --虚拟仓
     and   wh.real_warehouse_key not in ('Z003-C001','Z003-C002','X003-A009','X005-A003','X005-A009','X005-A007',
'X007-A009','X008-A009','X001-A009','X001-A010','X001-A011','X001-A012','X001-C007','X998-C001','X998-C002',
'Z008-C001','Z008-C002','Z005-C001','Z005-C002','X001-C011','X051-AG02','F002-W005','H301-A001','Z013-A001',
'X001-A001','X001-A006','X001-A013','X001-C012','X001-C010')
    ) result
)
,online_sku_counts as  (  --全渠道在售sku
select
       cast(date_format(date_add(current_date(),-1),'yyyyMMdd') as int)  as date_key
      ,count(sku.sku_code)                                               as online_sku_counts
from (
     select a.sku_code from  ods.kp_scm_store_sku a
     where a.is_available = 1 and  a.is_delete = 0
     union
     select b.sku_code from  ods.kp_scm_channel_sku b
     where b.is_available = 1 and  b.is_delete = 0
     ) sku
)

,total_amount_module as (
select
      ity.date_key
     ,ity.total_inventory_amount
     ,ity.shop_inventory_amount
     ,ity.warehouse_inventory_amount
     ,ity.shop_inventory_rate
     ,ity.warehouse_inventory_rate
     ,sc.online_sku_counts
from inventory  ity
inner join online_sku_counts sc  on ity.date_key = sc.date_key
)

-- *************************************************商品角色分析
, sku_role as (
select
       sr.date_key
      ,sr.sku_role
      ,sr.online_sku_role_counts
      ,sr.online_sku_role_counts / sc.online_sku_counts           as sku_role_rate
from (
      select
             cast(date_format(date_add(current_date(),-1),'yyyyMMdd') as int)  as date_key
            ,st.category_role                                     as sku_role
            ,count(distinct st.sku_key)                           as online_sku_role_counts
       from ml.sku_role_tag_score_result st
      group by st.category_role
    ) sr inner join online_sku_counts sc on sr.date_key = sc.date_key
)
-- *************************************************各等级商品分布及销售额贡献各等级商品分布及销售额贡献
, sku_level_sale as (
select cast(date_format(date_add(current_date(),-1),'yyyyMMdd') as int)  as date_key
      ,result.sku_level
      ,sum(result.sale_amount)                                           as sku_level_sale_amounts
      ,count(distinct result.sku_key)                                    as sku_level_sale_counts
from (
    select
          amount.sku_key
         ,amount.sale_amount
         ,nvl(sl.sku_x_sale_level,'D')   as  sku_level   -- 无箱规等级默认是D
    from (
          select
                  oi.sku_key
                , sum( actual_amount ) as sale_amount -- 扣除退款
          from dw.fact_trade_order_item oi
          inner join dw.dim_channel cl on oi.channel_key = cl.channel_key
          where oi.date_key = date_format(date_add(current_date(),-1),'yyyyMMdd')   -- 支付时间
          and   trade_status in  (3,5,8,9,-9999,-6)  -- 扣除退款3，5，8，9 -9999 正向-6逆向
          and   cl.channel_source in ('01','02','03','04','77','78') -- 全渠道
          and   substr(oi.channel_key,5,6) <> '_100_7' -- 排除门店自营外卖 ，--102_7 app自营外卖
          group by oi.sku_key
          ) amount
    left join (
                select
                      sku_key
                     ,sku_x_sale_level
                from  temp.ml_sku_x_28days_abcd_level
                where dim_id = 1  -- 全渠道
              ) sl   on amount.sku_key = sl.sku_key
      ) as result
group by  result.sku_level
)

--****************************************************各品类销售贡献
, thd_category_saleamount as (
select
       cast(date_format(date_add(current_date(),-1),'yyyyMMdd') as int)  as date_key
     , sku.category_three_name    as sec_categroy
     , sum( actual_amount )       as sec_categroy_sale_amounts -- 扣除退款
from dw.fact_trade_order_item oi
inner join dw.dim_channel cl on oi.channel_key = cl.channel_key
inner join dw.dim_sku  sku on oi.sku_key = sku.sku_key
where oi.date_key =  date_format(date_add(current_date(),-1),'yyyyMMdd')     -- 支付时间
and   trade_status in  (3,5,8,9,-9999,-6)    --扣除退款3，5，8，9 -9999 正向-6逆向
and   cl.channel_source in ('01','02','03','04','77','78') -- 全渠道
and   substr(oi.channel_key,5,6) <> '_100_7' -- 排除门店自营外卖 ，--102_7 app自营外卖
group by sku.category_three_name
)

--***************************************************新品引进
, new_sku as (
select
      cast(date_format(date_add(current_date(),-1),'yyyyMMdd') as int)  as date_key
     ,date_format(mgr.actual_up_time,'yyyyMM')                          as date_month
     ,count(distinct mgr.sku_code)                                      as new_sku_counts
from  ods.kp_scm_sku_mgr mgr
where date_format(mgr.actual_up_time,'yyyyMM') >= date_format(add_months(date_add(current_date(),-1),-11),'yyyyMM')
and  mgr.big_class= '食品'
and  mgr.is_available = 1
and  mgr.is_delete = 0
group by date_format(mgr.actual_up_time,'yyyyMM')
)

--*************************************************** 直营门店现货率/加盟现货率
,spot_rate as (
--***********************直营
select
        cast(date_format(date_add(current_date(),-1),'yyyyMMdd') as int)  as date_key
       ,date_format(kpi.dt, 'yyyyMMdd')                           as date_day
       ,kpi.level                                                 as sku_level
       ,sum(out_stock)  / count(distinct kpi.node_id,kpi.sku_key) as sku_level_spot_rate
from dm.warehouse_inventory_all_kpi kpi
where date_format(kpi.dt, 'yyyyMMdd') = date_format(date_add(current_date(),-30),'yyyyMMdd')
and kpi.ctg_t_code <> '10103413'  -- 锁鲜装
and substring(kpi.node_id,2,1) <> 'R' -- 排除加盟
and kpi.node_type = 'store'
group by date_format(kpi.dt, 'yyyyMMdd') ,kpi.level
union all
--************************加盟
select
     cast(date_format(date_add(current_date(),-1),'yyyyMMdd') as int)  as date_key
    ,date_format(do.out_create_time,'yyyyMMdd')                        as date_day
    ,'加盟'                                                            as sku_level
    , sum(case when do.is_presell_order = 0  -- 现货箱数
               then dol.sku_qty / sc.scale else 0 end)
    / sum(  dol.sku_qty / sc.scale )    as sku_level_spot_rate
from ods.kp_scm_do_order do
inner join ods.kp_scm_do_detail dol on do.record_code = dol.record_code
inner  join (
             select
                    distinct a.sku_id
                    ,b.sku_code
                    ,c.code as unit_code
                    ,c.name as unit_name
                    ,a.scale
             From ods.zt_ic_sku_unit a
             left join ods.zt_ic_sku b on a.sku_id=b.id
             left join ods.zt_ic_unit c on a.unit_id=c.id
             where a.unit_id = '104' and a.is_deleted = 0
            ) sc on sc.sku_code = dol.sku_code
where do.shop_type = 3   -- 加盟
and   do.record_status = 15 -- 完成
and   do.is_deleted = 0
and   do.is_available = 1
and   date_format(do.out_create_time,'yyyyMMdd') >= date_format(date_add(current_date(),-30),'yyyyMMdd')
and   date_format(do.out_create_time,'yyyyMMdd') <=  date_format(date_add(current_date(),-1),'yyyyMMdd')
group by  date_format(do.out_create_time,'yyyyMMdd')
)

--******************************各等级商品平均周转天数
,avg_turnover_days as (
select cast(date_format(date_add(current_date(),-1),'yyyyMMdd') as int) as date_key
      ,result.sku_level
      ,avg( result.sku_turnover_days)  as sku_level_avg_turnover_days
from (
        select
             ivt.sku_key
            ,nvl(sl.sku_x_sale_level,'D')                            as sku_level
            ,case when nvl(qty.sale_28qty, 0) = 0 then 0
                  else nvl(ivt.inventory,  0) / qty.sale_28qty end    as sku_turnover_days
        from (
             select
                  iso.sku_key
                 ,sum(iso.jc_real_qty-iso.jc_lock_qty)   inventory
             from  dw.fact_inventory_stock_onhand iso  --*********************过滤条件同 1
             inner join dw.dim_warehouse wh on wh.real_warehouse_key = iso.real_warehouse_key
             where iso.dt = date_format(date_add(current_date(),-1),'yyyy-MM-dd')
             and   iso.is_available = 1
             and   wh.real_warehouse_type <> 15     --虚拟仓
             and   wh.real_warehouse_key not in ('Z003-C001','Z003-C002','X003-A009','X005-A003','X005-A009','X005-A007',
'X007-A009','X008-A009','X001-A009','X001-A010','X001-A011','X001-A012','X001-C007','X998-C001','X998-C002',
'Z008-C001','Z008-C002','Z005-C001','Z005-C002','X001-C011','X051-AG02','F002-W005','H301-A001','Z013-A001',
'X001-A001','X001-A006','X001-A013','X001-C012','X001-C010')
             group by iso.sku_key
             )  ivt
        left join (
                    select
                           oi.sku_key
                          ,sum(oi.jc_sku_quantity) / 28    as  sale_28qty  --是否除28 还是消售天数
                    from dw.fact_trade_order_item oi
                    inner join dw.dim_channel cl on oi.channel_key = cl.channel_key
                    where oi.date_key >=  date_format(date_add(current_date(),-28),'yyyyMMdd')     -- 支付时间
                    and   oi.trade_status in  (3,5,8,9,-9999,-6)
                    and   cl.channel_source in ('01','02','03','04','77','78') -- 全渠道  销售额过滤channel_key = 100_7，销量过滤channel_key = 102_7
                    and   substr(oi.channel_key,5,6) <> '_100_7' -- 排除门店自营外卖 ，--102_7 app自营外卖  统计销售额过滤线下的外卖channel_key = 100_7，销量过滤线上的外卖 channel_key = 102_7
                    group by oi.sku_key
                  ) qty on ivt.sku_key = qty.sku_key
        left join (
                    select
                          sku_key
                         ,sku_x_sale_level
                    from  temp.ml_sku_x_28days_abcd_level
                    where dim_id = 1  -- 全渠道
                   ) sl   on ivt.sku_key = sl.sku_key
      ) result
group by result.sku_level
)
--************************************************A等级商品销售额词云
, sku_a_level_sale as (
select
       cast(date_format(date_add(current_date(),-1),'yyyyMMdd') as int) as date_key
      ,sku.name                                             as sku_name
      ,sum( actual_amount )                                 as sku_sale_amount -- 扣除退款
from dw.fact_trade_order_item oi
inner join (select
                  sku_key
                 ,sku_x_sale_level
            from  temp.ml_sku_x_28days_abcd_level
            where dim_id = 1 and sku_x_sale_level = 'A' -- A等级全渠道
           ) sl on oi.sku_key = sl.sku_key
inner join dw.dim_sku sku on sku.sku_key = oi.sku_key
inner join dw.dim_channel cl on oi.channel_key = cl.channel_key
where oi.date_key = date_format(date_add(current_date(),-1),'yyyyMMdd')   -- 支付时间
and   trade_status in  (3,5,8,9,-9999,-6)  -- 扣除退款3，5，8，9 -9999 正向-6逆向
and   cl.channel_source in ('01','02','03','04','77','78') -- 全渠道
and   substr(oi.channel_key,5,6) <> '_100_7' -- 排除门店自营外卖 ，--102_7 app自营外卖  统计销售额过滤线下的外卖channel_key = 100_7，销量过滤线上的外卖 channel_key = 102_7
group by oi.sku_key ,sku.name
)

select  date_key
       ,total_inventory_amount
       ,shop_inventory_amount
       ,warehouse_inventory_amount
       ,online_sku_counts
       ,shop_inventory_rate
       ,warehouse_inventory_rate
       ,null,null,null,null,null,null,null
       ,null,null,null,null,null,null,null,null
       ,1 as  module_tag
       ,date_key as dt
from  total_amount_module
union all --商品角色分析
select  date_key
       ,null,null,null,null,null,null
       ,sku_role
       ,online_sku_role_counts
       ,sku_role_rate
       ,null,null,null,null,null,null
       ,null,null,null,null,null,null
       ,2 as  module_tag
       ,date_key as dt
from  sku_role
union all --各等级商品分布及销售额贡献
select  date_key
       ,null,null,null,null
       ,null,null,null,null,null
       ,sku_level
       ,sku_level_sale_amounts
       ,sku_level_sale_counts
       ,null,null,null,null
       ,null,null,null,null,null
       ,3 as  module_tag
       ,date_key as dt
from  sku_level_sale
union all --各品类销售贡献
select  date_key
       ,null,null,null,null,null,null
       ,null,null,null,null,null,null
       ,sec_categroy
       ,sec_categroy_sale_amounts
       ,null,null,null,null,null,null,null
       ,4 as  module_tag
       ,date_key as dt
from  thd_category_saleamount
union all --新品引进
select  date_key
       ,null,null,null,null,null,null,null
       ,null,null,null,null,null,null,null
       ,date_month
       ,new_sku_counts
       ,null,null,null,null,null
       ,5 as  module_tag
       ,date_key as dt
from  new_sku
union all --直营门店现货率/加盟现货率
select  date_key
       ,null,null,null,null
       ,null,null,null,null,null
       ,sku_level
       ,null,null,null,null,null,null
       ,date_day
       ,sku_level_spot_rate
       ,null,null,null
       ,6 as  module_tag
       ,date_key as dt
from   spot_rate
union all --各等级商品平均周转天数
select  date_key
       ,null,null,null,null
       ,null,null,null,null,null
       ,sku_level
       ,null,null,null,null
       ,null,null,null,null
       ,sku_level_avg_turnover_days
       ,null,null
       ,7 as  module_tag
       ,date_key as dt
from   avg_turnover_days
union all --A等级商品销售额词云
select  date_key
       ,null,null,null,null,null,null
       ,null,null,null,null,null,null
       ,null,null,null,null,null,null
       ,null
       ,sku_name
       ,sku_sale_amount
       ,8 as  module_tag
       ,date_key as dt
from   sku_a_level_sale

;
--set tez.queue.name=dw;
insert overwrite table dm.product_inventory_bigscreen
select * from temp.end_result;


truncate table temp.product_inventory_bigscreen;
insert overwrite table temp.product_inventory_bigscreen
select
date_key,
nvl(total_inventory_amount,0),
nvl(shop_inventory_amount,0),
nvl(warehouse_inventory_amount,0),
nvl(online_sku_counts,0),
nvl(shop_inventory_rate,0),
nvl(warehouse_inventory_rate,0),
nvl(sku_role,' '),
nvl(online_sku_role_counts,0),
nvl(sku_role_rate,0),
nvl(sku_level,' '),
nvl(sku_level_sale_amounts,0),
nvl(sku_level_sale_counts,0),
nvl(sec_categroy,' '),
nvl(sec_categroy_sale_amounts,0),
nvl(date_month,' '),
nvl(new_sku_counts,0),
nvl(date_day,' '),
nvl(sku_level_spot_rate,0),
nvl(sku_level_avg_turnover_days,0),
nvl(sku_name,' '),
nvl(sku_sale_amount,0),
module_tag
from dm.product_inventory_bigscreen where dt = date_format(date_add(current_date(),-1),'yyyyMMdd');



