with  a as (
select
 DT--日期
,three_level_code--门店编码
,sku_key--商品编码
,sku_name--商品名称
,qm_inventory--期末库存
,sku_ys_28_days--周转天数（近28天）
,sku_28_lv--平均销量（近28天）
from  dm.product_all_channel_kpi 
where dt>='2021-03-01' AND DT<='2021-04-01'
and dim_id=14
and three_level_code='107U'  AND SKU_KEY IN 
(
 '20890'
,'20843'
,'20826'
,'20828'
,'13519'
,'10129'
,'10125'
,'14428'
,'14429'
,'19793'
)
)

, b as (
select
dt,--日期
three_level_code,--门店编码
sku_key,--商品编码
sku_x_sale_level,--箱规销量排名
sku_sale_amt_level--销售额排名
from
dm.product_all_channel_kpi
where dt>='2021-03-01' AND DT<='2021-04-01' and dim_id=6
and three_level_code='107U'  AND SKU_KEY IN
 (
 '20890'
,'20843'
,'20826'
,'20828'
,'13519'
,'10129'
,'10125'
,'14428'
,'14429'
,'19793'
 )
)

, b1 as (
select
dt,--日期
three_level_code,--渠道编码，直营
sku_key,--商品编码
sku_x_sale_level,--箱规销量排名
sku_sale_amt_level--销售额排名
from
dm.product_all_channel_kpi
where dt>='2021-03-01' AND DT<='2021-04-01' and dim_id=3
and three_level_code='01'  --直营渠道
AND SKU_KEY IN
(
 '20890'
,'20843'
,'20826'
,'20828'
,'13519'
,'10129'
,'10125'
,'14428'
,'14429'
,'19793'
)
)
,c as (
select
dt,
node_id as three_level_code ,--门店编码
sku_key,
out_stock--是否缺货：0表示缺货 1表示不缺货
from dw.cpfr_spot
where dt>='2021-03-01' AND DT<='2021-04-01'
and node_id='107U'  AND SKU_KEY IN 
(
 '20890'
,'20843'
,'20826'
,'20828'
,'13519'
,'10129'
,'10125'
,'14428'
,'14429'
,'19793'
))

,d as(
select
dt,
sku_key,
node_id as three_level_code,--门店编码
null,--上线
null--下线
from dw.cpfr_inventory
where dt>='2021-03-01' AND DT<='2021-04-01'
and node_id='107U'  AND SKU_KEY IN 
(
 '20890'
,'20843'
,'20826'
,'20828'
,'13519'
,'10129'
,'10125'
,'14428'
,'14429'
,'19793'
)
)

--| ss         | 安全库存                        |
--| demand_nrt | nrt需求                       |
--| demand_vlt | vlt需求                       |
--| demand_bp1 | bp1需求                       |
--| demand_bp2 | bp2需求                       |
--| demand_bp3 | bp3需求                       |


,e as (
select distinct
sku_code as sku_key
,param_value --最小陈列量
from ods.kp_scm_sku_property
where is_available=1 AND is_deleted=0
AND param_code='P0014'
)

,f as (
select
      date_format(oi.payment_time,'yyyy-MM-dd') as dt
     ,oi.sku_key
     ,sku.name
     , sum( oi.jc_sku_quantity )  as mendian_count

from dw.fact_trade_order_item oi
inner join dw.dim_channel cl on oi.channel_key = cl.channel_key
inner join dw.dim_sku  sku on oi.sku_key = sku.sku_key
where oi.payment_time between '2021-03-01' and '2021-04-01'   -- 支付时间
and oi.dt > '2021-03-01'
and  oi.store_key ='107U'
and   trade_status in  (3,5,8,9,-9999,-6)    --扣除退款3，5，8，9 -9999 正向-6逆向
and  oi.sku_key in (  '20890'
                     ,'20843'
                     ,'20826'
                     ,'20828'
                     ,'13519'
                     ,'10129'
                     ,'10125'
                     ,'14428'
                     ,'14429'
                     ,'19793')
and   substr(oi.channel_key,5,6) <> '_100_7' -- 排除门店自营外卖 ，--102_7 app自营外卖
group by date_format(oi.payment_time,'yyyy-MM-dd'),oi.sku_key,sku.name
)
, g as
(
select
 dt
,sku_key
,real_warehouse_key  as  three_level_code
,jc_onroad_qty
from dw.fact_inventory_stock_onhand
where dt >='2021-03-01' and dt<='2021-04-01'
and real_warehouse_key ='107U'
and sku_key in (
 '20890'
,'20843'
,'20826'
,'20828'
,'13519'
,'10129'
,'10125'
,'14428'
,'14429'
,'19793'
)
)

,h as
(
SELECT
 from_unixtime(unix_timestamp(date_key,'yyyymmdd'),'yyyy-mm-dd') as dt
,store_key
,sku_key
,sum(case when advise_quantity is null then 0.00 else advise_quantity end) as advise_quantity -- 建议叫货量
,sum(case when sku_quantity is null then 0.00 else sku_quantity end ) sku_quantity -- 实际叫货量
From dw.fact_trade_store_po a
where dt>'2021-01-01' and date_key>='20210301' and date_key<='20210331'
and store_key='107U' and sku_key in ('20890','20843','20826','20828','13519','10129','10125','14428','14429','19793')
group by from_unixtime(unix_timestamp(date_key,'yyyymmdd'),'yyyy-mm-dd'),store_key,sku_key
)
,i as
(
select date_format(a.allot_time,'yyyy-MM-dd') as dt
 ,a.shop_code
 ,b.sku_code as sku_key
 ,sum(case when b.allot_qty is null then 0.00 else  b.allot_qty end) as allot_qty -- 寻源量
From ods.kp_scm_do_order a left join ods.kp_scm_do_detail b on a.record_code=b.record_code
where a.shop_code='107U'
and a.allot_time>='2021-03-01' and a.allot_time<'2021-04-01'
and b.sku_code in ('20890','20843','20826','20828','13519','10129','10125','14428','14429','19793')
and a.is_available=1 and a.is_deleted=0
group by date_format(a.allot_time,'yyyy-MM-dd'),a.shop_code,b.sku_code
)
,j as (
select date_format(a.actual_arrive_time,'yyyy-MM-dd') as dt
,a.shop_code
,b.sku_code as sku_key
,sum(case when b.real_in_qty is null then 0.00 else b.real_in_qty end) as real_in_qty
From ods.kp_scm_do_order a left join ods.kp_scm_do_detail b on a.record_code=b.record_code
where a.shop_code='107U'
and a.actual_arrive_time>='2021-03-01' and a.actual_arrive_time<'2021-04-01'
and b.sku_code in ('20890','20843','20826','20828','13519','10129','10125','14428','14429','19793')
and a.is_available=1 and a.is_deleted=0
group by date_format(a.actual_arrive_time,'yyyy-MM-dd'),a.shop_code,b.sku_code

)
select
 a.sku_key
,a.sku_name
,a.dt
,b.sku_sale_amt_level  zhiying_amt_rank
,b.sku_x_sale_level      zhiying_count_rank
,b1.sku_sale_amt_level  mendian_amt_rank
,b1.sku_x_sale_level     mendian_count_rank
,f.mendian_count   -- 销售量-基础单位
,c.out_stock
,h.advise_quantity --预测补货的建议量
,null -- 预测补货-库存上限
,null --预测补货-库存下限
,g.jc_onroad_qty -- 发货在途
,h. sku_quantity -- 叫货量
,a.sku_ys_28_days --
,a.sku_28_lv
,e.param_value  --最小陈列量
,i.allot_qty   -- 寻源满足量（寻源寻到的量）
,j.real_in_qty -- 仓库发往该门店的发货量
,a.qm_inventory --
from a
left join b on a.DT = b.DT    and a.sku_key = b.sku_key
left join b1 on a.DT = b1.DT  and a.sku_key = b1.sku_key
left join c on a.DT = c.DT and a.three_level_code = c.three_level_code and a.sku_key = c.sku_key
left join d on a.DT = d.DT and a.three_level_code = d.three_level_code and a.sku_key = d.sku_key
left join e on a.sku_key = e.sku_key
left join f on a.sku_key = f.sku_key and a.DT = f.dt
left join g on a.DT = g.DT  and a.three_level_code = g.three_level_code and a.sku_key = g.sku_key
left join h on a.DT = h.DT    and a.sku_key = h.sku_key
left join i on a.DT = i.DT    and a.sku_key = i.sku_key
left join j on a.DT = j.DT    and a.sku_key = j.sku_key








