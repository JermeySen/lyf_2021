/*
--主题描述：门店抓手——单天
--调度策略：每天跑近70天数据，任务号1384
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
-- earlier=`date +%Y%m%d -d '-71 days'`
-- earlierYMD=`date +%Y-%m-%d -d '-71 days'`
-- earlierYMD_2=`date +%Y-%m-%d -d '-101 days'`
-- ##补数据
-- ##earlier=`date +%Y%m%d -d '-462 days'`
-- ##earlierYMD=`date +%Y-%m-%d -d '-462 days'`
-- ##earlierYMD_2=`date +%Y-%m-%d -d '-492 days'`
-- else
-- yesterday=`date -d "$1 +0 day" +%Y%m%d`
-- yesterdayYMD=`date -d "$1 +0 day" +%Y-%m-%d`
-- today=`date -d "$yesterday +1 day" +%Y%m%d`
-- todayYMD=`date -d "$yesterday +1 day" +%Y-%m-%d`
-- earlier=`date -d "$1 -70 day" +%Y%m%d`
-- earlierYMD=`date -d "$1 -70 day" +%Y-%m-%d`
-- earlierYMD_2=`date +%Y-%m-%d -d '-100 days'`
-- ##补数据
-- ##earlier=`date +%Y%m%d -d '-461 days'`
-- ##earlierYMD=`date +%Y-%m-%d -d '-461 days'`
-- ##earlierYMD_2=`date +%Y-%m-%d -d '-491 days'`
-- fi
-- echo "< : $today ----- $todayYMD"
-- echo ">= : $earlier ----- $earlierYMD------$earlierYMD_2"
-- echo "$yesterday"

set tez.queue.name=dw;
set hive.auto.convert.join=false;
set hive.merge.tezfiles=false;
set hive.merge.mapredfiles = true;

drop table  if exists temp.ml_store_gripper_day;
create table temp.ml_store_gripper_day as

select
a.id as key
,a.store_code as store_key
,a.store_name

,a.store_type
,a.store_status
,a.close_date
,a.demolition_date
,a.l2_company_code
,a.l2_company_name
,a.franchisee_code
,a.franchisee_name
,a.big_area_manager_code
,a.big_area_manager_name
,a.area_manager_code
,a.area_manager_name
,a.pay_date as date_key

,a.sales_amt_no_discount
,a.sales_amt
,a.sales_amt_tgt
,a.sales_amt_subsi
,a.sales_amt_discount
,a.sales_amt_pay
,a.sales_amt_refund
,a.sales_cnt_refund
,a.sales_cnt
,a.passenger_flow
,a.sales_amt_no_discount_mem
,a.sales_amt_mem
,a.sales_amt_mem_percent_tgt
,a.sales_amt_subsi_mem
,a.sales_person_cnt_mem
,a.sales_amt_discount_mem
,a.sales_amt_pay_mem
,a.sales_amt_refund_mem
,a.sales_cnt_refund_mem
,a.sales_cnt_mem
,a.bg_open_card_cnt
,a.mem_save_amt
,a.mem_save_amt_tgt
,a.new_mem_cnt
,a.new_mem_cnt_tgt
,a.store_reg_mem_cnt
,a.app_reg_mem_cnt
,a.applets_reg_mem_cnt
,a.active_dev_cnt
,a.group_cnt
,a.fans_cnt
,a.fans_cnt_tgt
,a.new_groups_cnt
,a.new_fans_cnt
,a.live_broadcast_cnt
,a.sales_amt_area_group_buy
,a.sales_cnt_area_group_buy
,a.sales_amt_no_discount_y
,a.sales_amt_y
,a.buy_cnt_y
,a.sales_amt_no_discount_refund_y
,a.sales_amt_refund_y
,a.sales_amt_no_discount_u
,a.sales_amt_u
,a.sales_amt_no_discount_refund_u
,a.sales_amt_refund_u
,a.saved_cnt_u
,cast(-99 as bigint) as ground_push_cnt
,coalesce(b.take_out_sale_amt,0) as take_out_sale_amt
,coalesce(c.join_group_sale_amt,0) as join_group_sale_amt
from
dm.store_daily_analysis a
left join
(
select store_code,pay_date,sum(sales_amt) as take_out_sale_amt  from dm.store_daily_business_analysis
where business_code in ('102','101','103','121','122') and dt>= '$earlierYMD' and dt < '$todayYMD'
group by store_code,pay_date
)b on a.store_code=b.store_code and a.pay_date=b.pay_date
left join
(
select store_code,pay_date,sales_amt as join_group_sale_amt  from dm.store_daily_business_analysis
where business_code='9100' and dt>= '$earlierYMD' and dt < '$todayYMD'
)c on a.store_code=c.store_code and a.pay_date=c.pay_date
where
a.dt>= '$earlierYMD' and a.dt < '$todayYMD'
;


insert into  dm.store_daily_hbase
(
key
,store_key
,store_name
,store_type
,store_status
,close_date
,demolition_date
,l2_company_code
,l2_company_name
,franchisee_code
,franchisee_name
,big_area_manager_code
,big_area_manager_name
,area_manager_code
,area_manager_name
,date_key
,sale_amt
,sale_cnt
,mem_sale_amt
,area_group_buy_sale_cnt
,bg_open_card_cnt
,single_reg_num
,mem_save_amt
,take_out_sale_amt
,join_group_sale_amt
,ground_push_cnt
,live_broadcast_cnt
,no_discount_sales_amt
,subsi_sales_amt
,discount_sales_amt
,pay_sales_amt
,refund_sales_amt
,refund_sales_cnt
,passenger_flow_cnt
,no_discount_mem_sales_amt
,subsi_mem_sales_amt
,mem_sales_person_cnt
,discount_mem_sales_amt
,pay_mem_sales_amt
,refund_mem_sales_amt
,refund_mem_sales_cnt
,mem_sales_cnt
,mem_store_reg_cnt
,mem_app_reg_cnt
,mem_applets_reg_cnt
,active_dev_cnt
,group_cnt
,fans_cnt
,new_groups_cnt
,new_fans_cnt
,area_group_buy_sales_amt
,no_discount_y_sales_amt
,y_sales_amt
,y_buy_cnt
,no_discount_refund_y_sales_amt
,refund_y_sales_amt
,no_discount_u_sales_amt
,u_sales_amt
,no_discount_refund_u_sales_amt
,refund_u_sales_amt
,u_saved_cnt
,period_6_sale_amt
,period_7_sale_amt
,period_8_sale_amt
,period_9_sale_amt
,period_10_sale_amt
,period_11_sale_amt
,period_12_sale_amt
,period_13_sale_amt
,period_14_sale_amt
,period_15_sale_amt
,period_16_sale_amt
,period_17_sale_amt
,period_18_sale_amt
,period_19_sale_amt
,period_20_sale_amt
,period_21_sale_amt
,period_22_sale_amt
,period_23_sale_amt
)
select
a.key
,a.store_key
,a.store_name
,a.store_type
,a.store_status
,a.close_date
,a.demolition_date
,a.l2_company_code
,a.l2_company_name
,a.franchisee_code
,a.franchisee_name
,a.big_area_manager_code
,a.big_area_manager_name
,a.area_manager_code
,a.area_manager_name
,a.date_key
,a.sales_amt
,a.sales_cnt
,a.sales_amt_mem
,a.sales_cnt_area_group_buy
,a.bg_open_card_cnt
,a.new_mem_cnt
,a.mem_save_amt
,a.take_out_sale_amt
,a.join_group_sale_amt
,a.ground_push_cnt
,a.live_broadcast_cnt
,a.sales_amt_no_discount
,a.sales_amt_subsi
,a.sales_amt_discount
,a.sales_amt_pay
,a.sales_amt_refund
,a.sales_cnt_refund
,a.passenger_flow
,a.sales_amt_no_discount_mem
,a.sales_amt_subsi_mem
,a.sales_person_cnt_mem
,a.sales_amt_discount_mem
,a.sales_amt_pay_mem
,a.sales_amt_refund_mem
,a.sales_cnt_refund_mem
,a.sales_cnt_mem
,a.store_reg_mem_cnt
,a.app_reg_mem_cnt
,a.applets_reg_mem_cnt
,a.active_dev_cnt
,a.group_cnt
,a.fans_cnt
,a.new_groups_cnt
,a.new_fans_cnt
,a.sales_amt_area_group_buy
,a.sales_amt_no_discount_y
,a.sales_amt_y
,a.buy_cnt_y
,a.sales_amt_no_discount_refund_y
,a.sales_amt_refund_y
,a.sales_amt_no_discount_u
,a.sales_amt_u
,a.sales_amt_no_discount_refund_u
,a.sales_amt_refund_u
,a.saved_cnt_u
,coalesce(b.period_6_sale_amt,0) as period_6_sale_amt
,coalesce(b.period_7_sale_amt,0) as period_7_sale_amt
,coalesce(b.period_8_sale_amt,0) as period_8_sale_amt
,coalesce(b.period_9_sale_amt,0) as period_9_sale_amt
,coalesce(b.period_10_sale_amt,0) as period_10_sale_amt
,coalesce(b.period_11_sale_amt,0) as period_11_sale_amt
,coalesce(b.period_12_sale_amt,0) as period_12_sale_amt
,coalesce(b.period_13_sale_amt,0) as period_13_sale_amt
,coalesce(b.period_14_sale_amt,0) as period_14_sale_amt
,coalesce(b.period_15_sale_amt,0) as period_15_sale_amt
,coalesce(b.period_16_sale_amt,0) as period_16_sale_amt
,coalesce(b.period_17_sale_amt,0) as period_17_sale_amt
,coalesce(b.period_18_sale_amt,0) as period_18_sale_amt
,coalesce(b.period_19_sale_amt,0) as period_19_sale_amt
,coalesce(b.period_20_sale_amt,0) as period_20_sale_amt
,coalesce(b.period_21_sale_amt,0) as period_21_sale_amt
,coalesce(b.period_22_sale_amt,0) as period_22_sale_amt
,coalesce(b.period_23_sale_amt,0) as period_23_sale_amt

from temp.ml_store_gripper_day a left join
(
select
a.store_key,
a.date_key,
sum(case when substr(payment_time,12,2)='06' then  a.actual_amount else 0.00 end) as period_6_sale_amt,--实收金额
sum(case when substr(payment_time,12,2)='07' then  a.actual_amount else 0.00 end) as period_7_sale_amt,--实收金额
sum(case when substr(payment_time,12,2)='08' then  a.actual_amount else 0.00 end) as period_8_sale_amt,--实收金额
sum(case when substr(payment_time,12,2)='09' then  a.actual_amount else 0.00 end) as period_9_sale_amt,--实收金额
sum(case when substr(payment_time,12,2)='10' then  a.actual_amount else 0.00 end) as period_10_sale_amt,--实收金额
sum(case when substr(payment_time,12,2)='11' then  a.actual_amount else 0.00 end) as period_11_sale_amt,--实收金额
sum(case when substr(payment_time,12,2)='12' then  a.actual_amount else 0.00 end) as period_12_sale_amt,--实收金额
sum(case when substr(payment_time,12,2)='13' then  a.actual_amount else 0.00 end) as period_13_sale_amt,--实收金额
sum(case when substr(payment_time,12,2)='14' then  a.actual_amount else 0.00 end) as period_14_sale_amt,--实收金额
sum(case when substr(payment_time,12,2)='15' then  a.actual_amount else 0.00 end) as period_15_sale_amt,--实收金额
sum(case when substr(payment_time,12,2)='16' then  a.actual_amount else 0.00 end) as period_16_sale_amt,--实收金额
sum(case when substr(payment_time,12,2)='17' then  a.actual_amount else 0.00 end) as period_17_sale_amt,--实收金额
sum(case when substr(payment_time,12,2)='18' then  a.actual_amount else 0.00 end) as period_18_sale_amt,--实收金额
sum(case when substr(payment_time,12,2)='19' then  a.actual_amount else 0.00 end) as period_19_sale_amt,--实收金额
sum(case when substr(payment_time,12,2)='20' then  a.actual_amount else 0.00 end) as period_20_sale_amt,--实收金额
sum(case when substr(payment_time,12,2)='21' then  a.actual_amount else 0.00 end) as period_21_sale_amt,--实收金额
sum(case when substr(payment_time,12,2)='22' then  a.actual_amount else 0.00 end) as period_22_sale_amt,--实收金额
sum(case when substr(payment_time,12,2)='23' then  a.actual_amount else 0.00 end) as period_23_sale_amt--实收金额
from dw.fact_trade_order a
left join dw.dim_channel b on a.channel_key=b.channel_key
where
b.channel_source in('01','04')
and a.dt>='$earlierYMD_2'
and a.order_business_type IN (0,1,2)
and a.date_key >= '$earlier' and a.date_key < '$today'
and a.trade_status in ('3','5','8','-9999','9','-6')
group by a.store_key,a.date_key
)b on a.store_key=b.store_key and a.date_key=b.date_key
;


