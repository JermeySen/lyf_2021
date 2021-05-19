/*
--主题描述：单店单天分业务模型
--调度策略：每天跑近60天数据，任务号1417

--业务范围：直营加盟
--作者：zengjiamin
--日期：20210518
 */
-- #!/bin/sh
-- if [ "$1" = "" ]; then
-- today=`date +%Y%m%d`
-- todayYMD=`date +%Y-%m-%d`
-- yesterday=`date +%Y%m%d -d '-1 days'`
-- yesterdayYMD=`date +%Y%-m-%d -d '-1 days'`
-- earlier=`date +%Y%m%d -d '-61 days'`
-- earlierYMD=`date +%Y-%m-%d -d '-61 days'`
-- earlierYMD2=`date +%Y-%m-%d -d '-181 days'`
-- earlierYMD_2=`date +%Y-%m-%d -d '-91 days'`
-- earlierYMD2_2=`date +%Y-%m-%d -d '-211 days'`
-- ##补数据
-- ##earlier=`date +%Y%m%d -d '-799 days'`
-- ##earlierYMD=`date +%Y-%m-%d -d '-799 days'`
--
-- else
-- yesterday=`date -d "$1 +0 day" +%Y%m%d`
-- yesterdayYMD=`date -d "$1 +0 day" +%Y-%m-%d`
-- today=`date -d "$yesterday +1 day" +%Y%m%d`
-- todayYMD=`date -d "$yesterday +1 day" +%Y-%m-%d`
-- earlier=`date -d "$1 -60 day" +%Y%m%d`
-- earlierYMD=`date +%Y-%m-%d -d '-60 days'`
-- earlierYMD2=`date +%Y-%m-%d -d '-180 days'`
-- earlierYMD_2=`date +%Y-%m-%d -d '-90 days'`
-- earlierYMD2_2=`date +%Y-%m-%d -d '-210 days'`
-- ##补数据
-- ##earlier=`date -d "$1 -798 day" +%Y%m%d`
-- ##earlierYMD=`date -d "$1 -698 day" +%Y-%m-%d`
--
-- fi
--
-- echo "< : $today ----- $todayYMD"
-- echo ">= : $earlier ----- $earlierYMD"
-- echo "$yesterday"
-- echo "$order_dt"


set tez.queue.name=dw;
set hive.exec.reducers.bytes.per.reducer=2342177280;
set hive.auto.convert.join=false;
set hive.merge.tezfiles=false;
set hive.merge.mapredfiles = true;
SET hive.exec.dynamic.partition=true;
SET hive.exec.max.dynamic.partitions=10000;
SET hive.exec.max.dynamic.partitions.pernode=1000;
----------------------------------------------------------------------------------------
--1.构造门店主表
drop table  if exists temp.ml_day_store_b_base_pre;
create table temp.ml_day_store_b_base_pre as
select
a.store_key,
a.store_name,
a.store_type,
a.date_key,
a.l2_company_code,
a.l2_company_name,
b.demolition_date,
b.close_date,
case when a.franchisee='-9999' or trim(a.franchisee)='' then null else  a.franchisee end as franchisee_code,
case when a.franchisee_name='-9999' or trim(a.franchisee_name)='' or a.franchisee_name='其它' then null else  a.franchisee_name end as franchisee_name,
a.region_owner as big_area_manager_code,
REPLACE(t6.cn,' ','')  as big_area_manager_name,
a.area_owner as area_manager_code,
REPLACE(t5.cn,' ','')  as area_manager_name
from
(
select
store_key,store_name,
case when substr(a.store_key,2,1) = 'R' then '加盟' else '直营' end  as store_type,
replace(dt,'-','') as date_key,
is_open,
l2_company_code,
l2_company_name,
franchisee,
franchisee_name,
region_owner,
area_owner
from dw.dim_store_daily_snapshot a
where
dt >= '$earlierYMD'
and dt < '$todayYMD'
and store_properties  in ('1','2','3','4')
)a
left join
(
select
code,name,
date_format(demolition_date,'yyyy-MM-dd') as demolition_date,
date_format(close_date,'yyyy-MM-dd') as close_date,
desc
from ods.zt_bdc_store
where is_deleted=0 and type='A'
and substr(code,1,1)!='I'
)b on a.store_key=b.code
left join (select employee_number,cn from ods.zt_uc_user_employee group by employee_number,cn) t5 on t5.employee_number = a.area_owner
left join (select employee_number,cn from ods.zt_uc_user_employee group by employee_number,cn) t6 on t6.employee_number = a.region_owner
where b.desc='' or a.is_open=1
;

drop table  if exists temp.ml_day_store_b_base;
create table temp.ml_day_store_b_base as

select
a.*,b.business_code,b.business_name
from temp.ml_day_store_b_base_pre a
join
(
select
b.channel_type as business_code,b.channel_type_name as business_name
from dw.fact_trade_order a
left join dw.dim_channel b on a.channel_key=b.channel_key
where
b.channel_source in('01','04')
and a.dt>='$earlierYMD2_2'
and a.order_business_type IN (0,1,2)
and a.date_key >='$earlierYMD2'
and a.trade_status in ('3','5','8','-9999','9','-6')
group by b.channel_type,b.channel_type_name

union all
select '9100' as business_code ,'社团核销'  as business_name
union all
select '9200' as business_code ,'直播'      as business_name
)b on 1=1
;





--2.构造基础指标数据

--订单基础数据
drop table  if exists temp.ml_day_store_order_busi;
create table temp.ml_day_store_order_busi as

select
a.store_key,
a.date_key,
b.channel_type as business_code,--业务类型编码
b.channel_type_name as business_name,--业务类型名称

sum(a.orgin_amount) as sales_amt_no_discount, --应收金额
sum(a.actual_amount)as sales_amt,--实收金额
sum(coalesce(a.actual_amount,0.00)+coalesce(a.third_party_amount,0.00)) as sales_amt_subsi,--销售额（含补贴）
sum(case when a.trade_status ='-6' then 0.00 else a.actual_amount end) as sales_amt_pay,--支付金额
sum(a.discount_amount) as sales_amt_discount,--优惠金额
sum(case when a.trade_status <> '-6' then 0.00 else (-1)*a.actual_amount end) as sales_amt_refund,--退款金额
count(distinct(case when a.trade_status <> '-6' then null else a.order_no end ))  as sales_cnt_refund,--退款订单笔数
count(distinct(case when a.trade_status = '-6' then null else a.order_no end ))as sales_cnt,--订单笔数(正向)
count( distinct order_out_no) as passenger_flow--客流
from dw.fact_trade_order a
left join dw.dim_channel b on a.channel_key=b.channel_key
where
b.channel_source='02'
and b.channel_type='102'--app外卖，取线上数据
and a.dt>='$earlierYMD_2'
and a.order_business_type IN (0,1,2)
and a.date_key >= '$earlier' and a.date_key < '$today'
and a.trade_status in ('3','5','8','-9999','9','-6')
group by a.store_key,a.date_key,b.channel_type,b.channel_type_name

union all
select
a.store_key,
a.date_key,
b.channel_type as business_code,--业务类型编码
b.channel_type_name as business_name,--业务类型名称

sum(a.orgin_amount) as sales_amt_no_discount, --应收金额
sum(a.actual_amount)as sales_amt,--实收金额
sum(coalesce(a.actual_amount,0.00)+coalesce(a.third_party_amount,0.00)) as sales_amt_subsi,--销售额（含补贴）
sum(case when a.trade_status ='-6' then 0.00 else a.actual_amount end) as sales_amt_pay,--支付金额
sum(a.discount_amount) as sales_amt_discount,--优惠金额
sum(case when a.trade_status <> '-6' then 0.00 else (-1)*a.actual_amount end) as sales_amt_refund,--退款金额
count(distinct(case when a.trade_status <> '-6' then null else a.order_no end ))  as sales_cnt_refund,--退款订单笔数
count(distinct(case when a.trade_status = '-6' then null else a.order_no end ))as sales_cnt,--订单笔数(正向)
count( distinct order_out_no) as passenger_flow--客流
from dw.fact_trade_order a
left join dw.dim_channel b on a.channel_key=b.channel_key
where
b.channel_source in('01','04')
and b.channel_type<>'102'
and a.dt>='$earlierYMD_2'
and a.order_business_type IN (0,1,2)
and a.date_key >= '$earlier' and a.date_key < '$today'
and a.trade_status in ('3','5','8','-9999','9','-6')
group by a.store_key,a.date_key,b.channel_type,b.channel_type_name

union all
select
a.store_key,
a.date_key,
'9200' as business_code,--业务类型编码
'直播' as business_name,--业务类型名称

sum(a.orgin_amount) as sales_amt_no_discount, --应收金额
sum(a.actual_amount)as sales_amt,--实收金额

sum(coalesce(a.actual_amount,0.00)+coalesce(a.third_party_amount,0.00)) as sales_amt_subsi,--销售额（含补贴）
sum(case when a.trade_status ='-6' then 0.00 else a.actual_amount end) as sales_amt_pay,--支付金额
sum(a.discount_amount) as sales_amt_discount,--优惠金额
sum(case when a.trade_status <> '-6' then 0.00 else (-1)*a.actual_amount end) as sales_amt_refund,--退款金额
count(distinct(case when a.trade_status <> '-6' then null else a.order_no end ))  as sales_cnt_refund,--退款订单笔数
count(distinct(case when a.trade_status = '-6' then null else a.order_no end ))as sales_cnt,--订单笔数(正向)

count( distinct order_out_no) as passenger_flow--客流
from dw.fact_trade_order a
left join ods.zt_tc_order_line b
on substr(a.order_store_no,0,16) = b.id
where
b.dt >='$earlierYMD_2'
and b.ext_data like '%room%'
and b.is_deleted = 0

and a.dt>='$earlierYMD_2'
and a.order_business_type IN (0,1,2)
and a.date_key >= '$earlier' and a.date_key < '$today'
and a.trade_status in ('3','5','8','-9999','9','-6')
group by a.store_key,a.date_key

union all
select
a.store_key,
a.date_key,
'9100' as business_code,--业务类型编码
'社团核销' as business_name,--业务类型名称

sum(a.orgin_amount) as sales_amt_no_discount, --应收金额
sum(a.actual_amount)as sales_amt,--实收金额

sum(coalesce(a.actual_amount,0.00)+coalesce(a.third_party_amount,0.00)) as sales_amt_subsi,--销售额（含补贴）
sum(case when a.trade_status ='-6' then 0.00 else a.actual_amount end) as sales_amt_pay,--支付金额
sum(a.discount_amount) as sales_amt_discount,--优惠金额
sum(case when a.trade_status <> '-6' then 0.00 else (-1)*a.actual_amount end) as sales_amt_refund,--退款金额
count(distinct(case when a.trade_status <> '-6' then null else a.order_no end ))  as sales_cnt_refund,--退款订单笔数
count(distinct(case when a.trade_status = '-6' then null else a.order_no end ))as sales_cnt,--订单笔数(正向)

count( distinct order_out_no) as passenger_flow--客流
from dw.fact_trade_order a
left join dw.dim_channel b on a.channel_key=b.channel_key
where
b.channel_source in('01','04')
and a.is_community_corps = '1'
and a.dt>='$earlierYMD_2'
and a.order_business_type IN (0,1,2)
and a.date_key >= '$earlier' and a.date_key < '$today'
and a.trade_status in ('3','5','8','-9999','9','-6')
group by a.store_key,a.date_key
;


--3.插入数据
insert overwrite table dm.store_daily_business_analysis partition(dt)

select
reverse(concat(a.store_key,a.date_key,a.business_code)) as id,
a.store_key as store_code,
a.store_name,
a.store_type,
case
when a.close_date is not null and a.close_date<to_date(concat(substr(a.date_key,1,4),'-',substr(a.date_key,5,2),'-',substr(a.date_key,7,2))) and coalesce(b.sales_amt_pay,0)=0 and coalesce(b.sales_cnt,0)=0
then '当日关店'
else '营业门店' end as store_status,
a.close_date,
a.demolition_date,
a.l2_company_code,
a.l2_company_name,
a.franchisee_code,
a.franchisee_name,
a.big_area_manager_code,
a.big_area_manager_name,
a.area_manager_code,
a.area_manager_name,
a.date_key as pay_date,
a.business_code,--业务类型编码
a.business_name,--业务类型名称

coalesce(b.sales_amt_no_discount,0) as  sales_amt_no_discount,--应收金额
coalesce(b.sales_amt,0) as sales_amt,--实收金额
coalesce(b.sales_amt_subsi,0) as  sales_amt_subsi,--销售额（含补贴）

coalesce(b.sales_amt_pay,0) as  sales_amt_pay,--支付金额
coalesce(b.sales_amt_discount,0) as  sales_amt_discount,--优惠金额
coalesce(b.sales_amt_refund,0) as  sales_amt_refund,--退款金额
coalesce(b.sales_cnt_refund,0) as sales_cnt_refund,--退款订单笔数
coalesce(b.sales_cnt,0) as  sales_cnt,--订单笔数(正向)
coalesce(b.passenger_flow,0) as passenger_flow,--客流
concat(substr(a.date_key,1,4),'-',substr(a.date_key,5,2),'-',substr(a.date_key,7,2)) as dt
from temp.ml_day_store_b_base a
left join temp.ml_day_store_order_busi b on a.store_key=b.store_key and a.date_key=b.date_key and a.business_code=b.business_code
;

