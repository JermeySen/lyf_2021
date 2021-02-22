-- 来团购
SELECT a.order_no,a.date_key,a.buyer_key,c.employee_id,c.employee_name_cn,c.mobile,a.trade_status,a.sku_key,b.name as sku_name,a.sales_unit,a.actual_amount,a.sku_quantity
From dw.fact_trade_order_item a
LEFT JOIN dw.dim_sku b on a.sku_key=b.sku_key
LEFT JOIN dw.profile_member c on a.buyer_key=c.buyer_key
where dt>'2020-12-01'
and a.channel_key like '%IF01_154_15'
and a.trade_status in (3,5,8,9,-9999.-6);

--30家门店单店单天业绩
select
      oi.store_key
     ,sum(case when oi.date_key between '20180101' and '20181231' then actual_amount end)
     /count( distinct case when oi.date_key between '20180101' and '20181231' then oi.date_key end)  as avg_2018 -- 扣除退款
     ,sum(case when oi.date_key between '20190101' and '20191231' then actual_amount end)
     /count( distinct case when oi.date_key between '20190101' and '20191231' then oi.date_key end) as avg_2019 -- 扣除退款
     ,sum(case when oi.date_key between '20200101' and '20201231' then actual_amount end)
     /count( distinct case when oi.date_key between '20200101' and '20201231' then oi.date_key end) as avg_2020 -- 扣除退款
from dw.fact_trade_order_item oi
inner join dw.dim_channel cl on oi.channel_key = cl.channel_key
inner join dw.dim_store  s on s.store_key = oi.store_key
where oi.date_key between '20180101' and '20201231'
and   trade_status in  ('3','5','8','9','-9999','-6')  -- 扣除退款3，5，8，9 -9999 正向-6逆向
and   cl.channel_source in ('01','04') -- 直营  加盟
-- and   substr(oi.channel_key,5,6) <> '_100_7' -- 排除门店自营外卖 ，--102_7 app自营外卖
and oi.store_key in
(
 '2R17'
,'100F'
,'1721'
,'123X'
,'1825'
,'130S'
,'107B'
,'1054'
,'100P'
,'1989'
,'1351'
,'117N'
,'1108'
,'129N'
,'1386'
,'1393'
,'1561'
,'1423'
,'114X'
,'1818'
,'102E'
,'1098'
,'113Y'
,'114X'
,'118R'
,'119E'
,'127Q'
,'1252'
,'1090'

)
group by oi.store_key