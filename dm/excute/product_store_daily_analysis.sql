--left  join  dw.dim_sku_special_sort st on st.sku_key = oi.sku_key and st.work_type_id = '1'
--inner join dw.dim_sku sku    on sku.sku_key    = oi.sku_key
--社区团：实收对应线上，应收线下
with sale_sku as (
select
         oi.store_key
        ,case when oi.is_community_corps = 1 then '9100'   else  cl.channel_type       end as business_code
        ,case when oi.is_community_corps = 1 then '社团核销'else  cl.channel_type_name  end as business_name
        ,oi.sku_key
        ,oi.sales_unit
        ,oi.jc_unit
        ,oi.is_gift
        ,date_format(oi.payment_time,'yyyyMMdd')                                                  as pay_date
        ,sum(oi.price * oi.sku_quantity)                                                          as sales_amt_no_discount
        ,sum(actual_amount)                                                                       as sales_amt
        ,sum(oi.discount_amout)                                                                   as sales_amt_discount
        ,sum(case when trade_status  = '-6'  then oi.price * oi.sku_quantity end)                 as sales_amt_refund
        ,sum(case when trade_status  = '-6'  then oi.actual_amount end)                           as sales_amt_no_discount_refund
        ,sum( case when trade_status in ('3','5','8','9','-9999')  then oi.jc_sku_quantity end)   as jc_sale_sku_qty
        ,sum( case when trade_status   = '-6'  then oi.jc_sku_quantity end)                       as jc_sale_sku_r_qty
        ,sum( case when trade_status in ('3','5','8','9','-9999')  then oi.sku_quantity end)      as xs_sale_sku_qty
        ,sum( case when trade_status  ='-6' then oi.sku_quantity end)                             as xs_sale_sku_r_qty
        ,count(distinct case when trade_status in ('3','5','8','9','-9999')  then oi.order_store_no end )  as sales_ord_cnt
        ,count(distinct case when trade_status   = '-6'  then oi.order_store_no end )                      as sales_ord_cnt_refund
        ,from_unixtime(unix_timestamp(current_timestamp()) + 28800)                               as etl_updatetime
        ,date_format(oi.payment_time,'yyyy-MM-dd')                                                as dt
from dw.fact_trade_order_item oi
inner join dw.dim_channel cl on oi.channel_key = cl.channel_key
where date_format(oi.payment_time,'yyyy-MM-dd') = date_format(date_add(current_date(),-1),'yyyy-MM-dd')
and   oi.dt >= date_format(date_add(current_date(),-10),'yyyy-MM-dd')
and   trade_status in  ('3','5','8','9','-9999','-6')  -- 扣除退款3，5，8，9 -9999 正向-6逆向
and   cl.channel_source in ('01','04') -- 直营 , 加盟
and   oi.order_business_type in (0,1,2)  -- 排除虚拟单
group by date_format(oi.payment_time,'yyyyMMdd')
        ,oi.store_key
        ,case when oi.is_community_corps = 1 then '9100'   else  cl.channel_type       end
        ,case when oi.is_community_corps = 1 then '社团核销'else  cl.channel_type_name  end
        ,oi.sku_key
        ,oi.sales_unit
        ,oi.jc_unit
        ,oi.is_gift
        ,date_format(oi.payment_time,'yyyy-MM-dd')
union all
select
         oi.store_key
        ,'9200' as business_code
        ,'直播'  as business_name
        ,oi.sku_key
        ,oi.sales_unit
        ,oi.jc_unit
        ,oi.is_gift
        ,date_format(oi.payment_time,'yyyyMMdd')                                                  as pay_date
        ,sum(oi.price * oi.sku_quantity)                                                          as sales_amt_no_discount
        ,sum(actual_amount)                                                                       as sales_amt
        ,sum(oi.discount_amout)                                                                   as sales_amt_discount
        ,sum(case when trade_status  = '-6'  then oi.price * oi.sku_quantity end)                 as sales_amt_refund
        ,sum(case when trade_status  = '-6'  then oi.actual_amount end)                           as sales_amt_no_discount_refund
        ,sum( case when trade_status in ('3','5','8','9','-9999')  then oi.jc_sku_quantity end)   as jc_sale_sku_qty
        ,sum( case when trade_status   = '-6'  then oi.jc_sku_quantity end)                       as jc_sale_sku_r_qty
        ,sum( case when trade_status in ('3','5','8','9','-9999')  then oi.sku_quantity end)      as xs_sale_sku_qty
        ,sum( case when trade_status  ='-6' then oi.sku_quantity end)                             as xs_sale_sku_r_qty
        ,count(distinct case when trade_status in ('3','5','8','9','-9999')  then oi.order_store_no end )  as sales_ord_cnt
        ,count(distinct case when trade_status   = '-6'  then oi.order_store_no end )                      as sales_ord_cnt_refund
        ,from_unixtime(unix_timestamp(current_timestamp()) + 28800)                               as etl_updatetime
        ,date_format(oi.payment_time,'yyyy-MM-dd')                                                as dt
from dw.fact_trade_order_item oi
inner join ods.zt_tc_order_line ol on substr(oi.order_store_no,0,16) = ol.id
                                  and ol.dt >= date_format(date_add(current_date(),-10),'yyyy-MM-dd')
                                  and ol.ext_data like '%room%'
                                  and ol.is_deleted = 0
where date_format(oi.payment_time,'yyyy-MM-dd') = date_format(date_add(current_date(),-1),'yyyy-MM-dd')
and   oi.dt >= date_format(date_add(current_date(),-10),'yyyy-MM-dd')
and   trade_status in  ('3','5','8','9','-9999','-6')  -- 扣除退款3，5，8，9 -9999 正向-6逆向
and   oi.order_business_type in (0,1,2)  -- 排除虚拟单
group by date_format(oi.payment_time,'yyyyMMdd')
        ,oi.store_key
        ,oi.sku_key
        ,oi.sales_unit
        ,oi.jc_unit
        ,oi.is_gift
        ,date_format(oi.payment_time,'yyyy-MM-dd')

)
, sku_status  as (

                select   distinct
                         sku_code as sku_key
                         ,dt
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


insert overwrite table dm.product_store_daily_analysis PARTITION  (dt)
select
       su.sku_key||su.business_code||su.store_key||su.pay_date            as  id
      ,su.store_key
      ,dst.store_name
      ,case when substring(su.store_key,2,1) = 'R' then '加盟' else '直营'    end
      ,cast(case when dst.is_open is null then -1 else dst.is_open end as string)
      ,dst.l2_company_code
      ,dst.l2_company_name
      ,aa.province_code
      ,aa.province_name
      ,aa.city_code
      ,aa.city_name
      ,aa.area_key
      ,aa.area_name
      ,dst.franchisee
      ,dst.franchisee_name
      ,su.business_code
      ,su.business_name
      ,sku.spu_code
      ,sku.spu_type
      ,sku.sku_key
      ,sku.name
      ,sta.sku_status
      ,sku.second_material_code
      ,sku.second_material_name
      ,cast(sku.brand_id as string) as brand_id
      ,sku.brand_name
      ,sl.sku_x_sale_level          as sku_xg_sale_level
      ,sl.sku_sale_amt_level        as sku_sale_amt_level
      ,cast(su.is_gift as string)   as is_gift
      ,sku.category_one_code
      ,sku.category_one_name
      ,sku.category_two_code
      ,sku.category_two_name
      ,sku.category_three_code
      ,sku.category_three_name
      ,sku.category_four_code
      ,sku.category_four_name
      ,su.pay_date
      ,su.sales_amt_no_discount
      ,su.sales_amt
      ,su.sales_amt_discount
      ,su.sales_amt_no_discount_refund
      ,su.sales_amt_refund
      ,su.jc_unit
      ,su.jc_sale_sku_qty
      ,su.jc_sale_sku_r_qty
      ,su.sales_unit
      ,su.xs_sale_sku_qty
      ,su.xs_sale_sku_r_qty
      ,sc.unit_name                    as xg_unit
      ,su.jc_sale_sku_qty   / sc.scale as xg_sale_sku_qty
      ,su.jc_sale_sku_r_qty / sc.scale as xg_sale_sku_r_qty
      ,su.sales_ord_cnt
      ,su.sales_ord_cnt_refund
      ,nvl(su.sales_ord_cnt,0) + nvl(su.sales_ord_cnt_refund,0)  as passenger_flow
      ,su.etl_updatetime
      ,su.dt
from sale_sku su
inner join dw.dim_sku   sku on su.sku_key = sku.sku_key
left  join dw.dim_store_daily_snapshot dst on dst.store_key = su.store_key and dst.dt = date_format(date_add(current_date(),-1),'yyyy-MM-dd')
left  join dw.dim_area aa  on aa.area_key = dst.area_code
left  join sku_status   sta  on su.sku_key  = sta.sku_key
left  join (
             select
                    distinct
                     b.sku_code
                    ,c.name as unit_name
                    ,a.scale
             From ods.zt_ic_sku_unit a
             left join ods.zt_ic_sku b on a.sku_id=b.id
             left join ods.zt_ic_unit c on a.unit_id=c.id
             where a.unit_id = '104' and a.is_deleted = 0  --箱规
            ) sc on su.sku_key = sc.sku_code

left join (
            select
                    dt
                   ,sku_key
                   ,three_level_code
                   ,sku_x_sale_level
                   ,sku_sale_amt_level
            from dm.product_all_channel_kpi
            where dt = date_format(date_add(current_date(),-1),'yyyy-MM-dd') -- and dt <= '2021-04-01'
            and dim_id = 6 -- 门店
          ) sl on su.sku_key = sl.sku_key and sl.dt = su.dt and su.store_key = sl.three_level_code
;