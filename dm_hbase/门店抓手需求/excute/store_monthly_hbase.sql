/*
--主题描述：门店抓手——单月
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
--
-- echo "< : $today ----- $todayYMD"
-- echo ">= : $earlier ----- $earlierYMD------$earlierYMD_2"
-- echo "$yesterday"
set tez.queue.name=dw;
set hive.auto.convert.join=false;
set hive.merge.tezfiles=false;
set hive.merge.mapredfiles = true;

drop table  if exists temp.ml_store_gripper_month;
create table temp.ml_store_gripper_month as
select
a.key,
a.store_key,
a.d_month,
a.sale_amt,
a.sale_cnt,
a.mem_sale_amt,
a.area_group_buy_sale_cnt,
a.bg_open_card_cnt,
a.single_reg_num,
a.mem_save_amt,
a.take_out_sale_amt,
a.join_group_sale_amt,
cast(-99 as bigint) as ground_push_cnt,
a.live_broadcast_cnt
from
(
select
reverse(concat(a.store_key,substr(a.date_key,1,6))) as key,
a.store_key,
substr(a.date_key,1,6) as d_month,
sum(sales_amt) as sale_amt,
sum(sales_cnt) as sale_cnt,
sum(sales_amt_mem) as mem_sale_amt,
sum(sales_cnt_area_group_buy) as area_group_buy_sale_cnt,
sum(bg_open_card_cnt) as bg_open_card_cnt,
sum(new_mem_cnt) as single_reg_num,
sum(mem_save_amt) as mem_save_amt,
sum(take_out_sale_amt) as take_out_sale_amt,
sum(join_group_sale_amt)  as join_group_sale_amt,
sum(live_broadcast_cnt) as live_broadcast_cnt
from temp.ml_store_gripper_day a
where
SUBSTR(date_key,1,6)>=date_format(add_months('$todayYMD',-1),'yyyyMM')
group by
reverse(concat(a.store_key,substr(a.date_key,1,6))),
a.store_key,
substr(a.date_key,1,6)
) a
;

insert into dm.store_monthly_hbase
(
key
,store_key
,store_name
,d_month
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
)
select
a.key
,a.store_key
,b.store_name
,a.d_month
,a.sale_amt
,a.sale_cnt
,a.mem_sale_amt
,a.area_group_buy_sale_cnt
,a.bg_open_card_cnt
,a.single_reg_num
,a.mem_save_amt
,a.take_out_sale_amt
,a.join_group_sale_amt
,a.ground_push_cnt
,a.live_broadcast_cnt
from temp.ml_store_gripper_month a left join dw.dim_store b on a.store_key=b.store_key
;