/*
--主题描述：CMP7日达成率
--调度策略：每天跑近3天数据，任务号1466
--数据量：
--业务范围：直营加盟
--作者：zengjiamin
--日期：20210518
-- 目前数据有:0501至今
download[hdfs://nn01.bi.lyf.intl:8020/hera/hdfs-upload-dir/dw_fact_trade/20201102/product_store_daily_hbase0526.sql product_store_daily_hbase.sql]
hive -f product_store_daily_hbase.sql
 */
set tez.queue.name=dw;
drop table if exists temp.wf_product_store_daily_hbase;
create table  temp.wf_product_store_daily_hbase as
select
a.key
,a.pay_date
,a.store_code
,a.store_name
,a.store_type
,b.store_level
,c.l2_company_code
,c.l2_company_name
,a.is_open
,a.sku_code
,a.sku_name
,a.sku_xg_sale_level
,a.sku_sale_amt_level
,a.sales_amt_no_discount
,a.sales_amt
,a.sales_amt_discount
,a.sales_amt_no_discount_refund
,a.sales_amt_refund
,a.jc_unit_code
,a.jc_sale_sku_qty
,a.jc_sale_sku_r_qty
,sc.unit_code as xs_unit_code
,case when sc.scale is null then 0.00 else round(a.jc_sale_sku_qty / sc.scale,6) end as xs_sale_sku_qty
,case when sc.scale is null then 0.00 else round(a.jc_sale_sku_r_qty / sc.scale,6) end as xs_sale_sku_r_qty
,a.xg_unit_code
,a.xg_sale_sku_qty
,a.xg_sale_sku_r_qty
,a.sales_ord_cnt
,a.sales_ord_cnt_refund
,a.passenger_flow
,from_unixtime( unix_timestamp(a.pay_date,'yyyyMMdd'),'yyyy-MM-dd') as dt
from (
select
reverse(a.sku_code||a.store_code||a.pay_date)  as key
,a.pay_date
,a.store_code
,a.store_name
,a.store_type
,a.is_open
,a.sku_code
,a.sku_name
,min(nvl(a.sku_xg_sale_level,'D')) as sku_xg_sale_level
,min(nvl(a.sku_sale_amt_level,'D')) as sku_sale_amt_level
,sum(nvl(sales_amt_no_discount,0)) as sales_amt_no_discount
,sum(nvl(sales_amt,0)) as sales_amt
,sum(nvl(sales_amt_discount,0)) as sales_amt_discount
,sum(nvl(sales_amt_no_discount_refund,0)) as sales_amt_no_discount_refund
,sum(nvl(sales_amt_refund,0)) as sales_amt_refund
,min(jc_unit_code) as jc_unit_code
,sum(nvl(jc_sale_sku_qty,0) - nvl(jc_sale_sku_r_qty,0)) as jc_sale_sku_qty
,sum(nvl(jc_sale_sku_r_qty,0)) as jc_sale_sku_r_qty
,min(xg_unit_code) as xg_unit_code
,sum(nvl(xg_sale_sku_qty,0) - nvl(xg_sale_sku_r_qty,0)) as xg_sale_sku_qty
,sum(nvl(xg_sale_sku_r_qty,0)) as xg_sale_sku_r_qty
,sum(nvl(sales_ord_cnt,0) - nvl(sales_ord_cnt_refund,0)) as sales_ord_cnt
,sum(nvl(sales_ord_cnt_refund,0)) as sales_ord_cnt_refund
,sum(passenger_flow) as passenger_flow
from dm.product_store_daily_analysis a
where dt>='2021-05-01'
and a.business_code != '9200'   --剔除直播
group by a.sku_code,a.sku_name,a.store_code,a.store_name,a.store_type,a.is_open,a.pay_date
) a left join
(select distinct a.sku_id
,b.sku_code
,c.code as unit_code
,c.name as unit_name
,a.scale
From ods.zt_ic_sku_unit a
left join ods.zt_ic_sku b on a.sku_id=b.id
left join ods.zt_ic_unit c on a.unit_id=c.id
inner join (select sku_id,max(create_time) as create_time from ods.zt_ic_sku_unit a where a.type = 2 and a.is_deleted = 0 group by sku_id) d on a.sku_id=d.sku_id and a.create_time=d.create_time
where  a.type = 2 and a.is_deleted = 0      --销售单位数量
) sc on sc.sku_code = a.sku_code
left join ods.dim_store_temp b on a.store_code=b.store_code
left join dw.dim_store c on a.store_code=c.store_key;

------日期发散取近7日数据映射
drop table temp.wf_0525_tab1;
create table temp.wf_0525_tab1
as
select a.date_id,date_add(date_id,b.days) as date_key From (
select date_id,1 as types From dw.dim_date a where a.date_id >= '2021-05-01' and a.date_id <= date_add(current_date(),-1)) a
left join (
select 0 as days,1 as types
union all
select -1 as days,1 as types
union all
select -2 as days,1 as types
union all
select -3 as days,1 as types
union all
select -4 as days,1 as types
union all
select -5 as days,1 as types
union all
select -6 as days,1 as types
) b on a.types=b.types;

-------------- 计算子公司级商品近7日均商品销量
drop table temp.wf_0525_tab2;
create table temp.wf_0525_tab2
as
select b.date_id,a.l2_company_code,a.l2_company_name,a.sku_code,avg(jc_sale_sku_qty) as jc_sku_qty_7days_lv
from temp.wf_product_store_daily_hbase a
left join temp.wf_0525_tab1 b on a.dt=b.date_key
group by b.date_id,a.l2_company_code,a.l2_company_name,a.sku_code;

--------计算子公司+门店等级近7日均商品销量
drop table temp.wf_0525_tab3;
create table temp.wf_0525_tab3
as
select b.date_id,a.l2_company_code,a.l2_company_name,a.store_level,a.sku_code,avg(jc_sale_sku_qty) as jc_sku_qty_7days_lv
from temp.wf_product_store_daily_hbase a
left join temp.wf_0525_tab1 b on a.dt=b.date_key
where a.store_level is not null and a.store_level !='-'
group by b.date_id,a.l2_company_code,a.l2_company_name,a.store_level,a.sku_code;

------------- 汇总写入数据集
set tez.queue.name=dw;

insert into table dm.product_store_daily_hbase
select a.key
,from_unixtime( unix_timestamp(a.pay_date,'yyyyMMdd'),'yyyy-MM-dd') as pay_date
,a.store_code
,a.store_name
,a.store_type
,a.store_level
,a.l2_company_code
,a.l2_company_name
,a.is_open
,a.sku_code
,a.sku_name
,a.sku_xg_sale_level
,a.sku_sale_amt_level
,a.sales_amt_no_discount
,a.sales_amt
,a.sales_amt_discount
,a.sales_amt_no_discount_refund
,a.sales_amt_refund
,a.jc_unit_code
,a.jc_sale_sku_qty
,a.jc_sale_sku_r_qty
,a.xs_unit_code
,a.xs_sale_sku_qty
,a.xs_sale_sku_r_qty
,a.xg_unit_code
,a.xg_sale_sku_qty
,a.xg_sale_sku_r_qty
,a.sales_ord_cnt
,a.sales_ord_cnt_refund
,a.passenger_flow
,case when a.store_level is null or a.store_level = '-' then b.jc_sku_qty_7days_lv else c.jc_sku_qty_7days_lv end as jc_sale_sku_qty_7dyas_lv
from  temp.wf_product_store_daily_hbase a
left join temp.wf_0525_tab2 b on a.dt=b.date_id and a.l2_company_code=b.l2_company_code and a.sku_code=b.sku_code
left join temp.wf_0525_tab3 c on a.dt=c.date_id and a.l2_company_code=c.l2_company_code and a.store_level=c.store_level and a.sku_code=c.sku_code
where a.dt>='2021-05-01';
