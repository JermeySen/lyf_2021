-- 来团购
SELECT a.order_no,a.date_key,a.buyer_key,c.employee_id,c.employee_name_cn,c.mobile,a.trade_status,a.sku_key,b.name as sku_name,a.sales_unit,a.actual_amount,a.sku_quantity
From dw.fact_trade_order_item a
LEFT JOIN dw.dim_sku b on a.sku_key=b.sku_key
LEFT JOIN dw.profile_member c on a.buyer_key=c.buyer_key
where dt>'2020-12-01'
and a.channel_key like '%IF01_154_15'
and a.trade_status in (3,5,8,9,-9999.-6); 