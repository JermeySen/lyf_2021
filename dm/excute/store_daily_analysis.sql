/*
--主题描述：单店单天模型
--调度策略：每天跑近60天数据，任务号1416

--业务范围：直营加盟
--作者：zengjiamin
--日期：20210518
 */
--**********************************修改
-- #!/bin/sh
-- if [ "$1" = "" ]; then
-- today=`date +%Y%m%d`
-- todayYMD=`date +%Y-%m-%d`
-- yesterday=`date +%Y%m%d -d '-1 days'`
-- yesterdayYMD=`date +%Y%-m-%d -d '-1 days'`
-- earlier=`date +%Y%m%d -d '-61 days'`
-- earlier_2=`date +%Y%m%d -d '-71 days'`
-- earlierYMD=`date +%Y-%m-%d -d '-61 days'`
-- earlierYMD_2=`date +%Y-%m-%d -d '-91 days'`
-- ##补数据
-- ##earlier=`date +%Y%m%d -d '-799 days'`
-- ##earlierYMD=`date +%Y-%m-%d -d '-799 days'`
-- else
-- yesterday=`date -d "$1 +0 day" +%Y%m%d`
-- yesterdayYMD=`date -d "$1 +0 day" +%Y-%m-%d`
-- today=`date -d "$yesterday +1 day" +%Y%m%d`
-- todayYMD=`date -d "$yesterday +1 day" +%Y-%m-%d`
-- earlier=`date -d "$1 -60 day" +%Y%m%d`
-- earlier_2=`date +%Y%m%d -d '-70 days'`
-- earlierYMD=`date -d "$1 -60 day" +%Y-%m-%d`
-- earlierYMD_2=`date +%Y-%m-%d -d '-90 days'`
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
drop table  if exists temp.ml_day_store_base;
create table temp.ml_day_store_base as
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
where is_deleted=0 and type='A' --and  (desc='' or desc='暂闭店' or desc='拆店' or desc='预闭店')
and substr(code,1,1)!='I'
)b on a.store_key=b.code
left join (select employee_number,cn from ods.zt_uc_user_employee group by employee_number,cn) t5 on t5.employee_number = a.area_owner
left join (select employee_number,cn from ods.zt_uc_user_employee group by employee_number,cn) t6 on t6.employee_number = a.region_owner
where b.desc='' or a.is_open=1
;


--2.构造基础指标数据

--订单基础数据
drop table  if exists temp.ml_day_store_order;
create table temp.ml_day_store_order as
select
a.store_key,
a.date_key,
sum(a.orgin_amount) as sales_amt_no_discount, --应收金额
sum(a.actual_amount)as sales_amt,--实收金额
sum(coalesce(a.actual_amount,0.00)+coalesce(a.third_party_amount,0.00)) as sales_amt_subsi,--销售额（含补贴）
sum(a.discount_amount) as sales_amt_discount,--优惠金额
sum(case when a.trade_status ='-6' then 0.00 else a.actual_amount end) as sales_amt_pay,--支付金额
sum(case when a.trade_status <> '-6' then 0.00 else (-1)*a.actual_amount end) as sales_amt_refund,--退款金额
count(distinct(case when a.trade_status <> '-6' then null else a.order_no end ))  as sales_cnt_refund,--退款订单笔数
count(distinct(case when a.trade_status = '-6' then null else a.order_no end ))as sales_cnt,--订单笔数(正向)
count( distinct order_out_no) as passenger_flow,--客流
sum(case when a.buyer_key = '-9999' then 0.00 else  a.orgin_amount end ) as sales_amt_no_discount_mem, --会员应收金额
sum(case when a.buyer_key = '-9999' then 0.00 else  a.actual_amount end) as sales_amt_mem,--会员实收金额
sum(coalesce(case when a.buyer_key = '-9999' then 0.00 else  a.actual_amount end,0.00)+coalesce(case when buyer_key = '-9999' then 0.00 else a.third_party_amount end,0.00)) as sales_amt_subsi_mem, --会员销售额含补贴
count(distinct case when a.trade_status = '-6' or a.buyer_key = '-9999' then null else a.buyer_key end ) as sales_person_cnt_mem,--消费会员数（不算逆向）
sum(case when a.buyer_key = '-9999' then 0.00 else a.discount_amount end ) as sales_amt_discount_mem,--会员优惠金额
sum(case when a.trade_status ='-6' or a.buyer_key = '-9999' then 0.00 else a.actual_amount end) as sales_amt_pay_mem,--会员支付金额
sum(case when a.trade_status <> '-6' or a.buyer_key = '-9999' then 0.00 else (-1)*a.actual_amount end) as sales_amt_refund_mem,--会员退款金额
count( distinct case when a.trade_status <> '-6' or a.buyer_key = '-9999' then null else a.order_no end ) as sales_cnt_refund_mem,--会员退款订单笔数
count( distinct case when a.trade_status = '-6' or a.buyer_key = '-9999' then null else a.order_no end ) as sales_cnt_mem--会员订单笔数
from dw.fact_trade_order a
left join dw.dim_channel b on a.channel_key=b.channel_key
where
b.channel_source in('01','04')
and a.dt>='$earlierYMD_2'
--and a.dt>='2021-01-01'
and a.order_business_type IN (0,1,2)
and a.date_key >= '$earlier' and a.date_key < '$today'
--and a.date_key='20210505' and a.store_key in ('107U','1018')
and a.trade_status in ('3','5','8','-9999','9','-6')
group by a.store_key,a.date_key
;

--当日黑金开卡量，按门店对buyer_key去重
drop table  if exists temp.ml_day_store_black_gold;
create table temp.ml_day_store_black_gold as
select
a.used_date_key as date_key,
a.store_key,
count(distinct buyer_key) as bg_open_card_cnt--黑金开卡量
from dw.fact_trade_coupon a
join
(
select
distinct tcc.coupon_batch
from
ods.qt_pm_t_card_coupon_activity tcca
left join ods.qt_pm_t_card_coupon tcc
on tcca.id=tcc.activity_id
where tcca.rights_key='cardGift'
)b on a.lot_key=b.coupon_batch
where
a.dt>='$earlierYMD_2'
and a.used_date_key >= '$earlier' and a.used_date_key < '$today'
and a.buyer_key <>'-9999'
group by
a.used_date_key,
a.store_key
;


--卡销售相关
drop table  if exists temp.ml_day_store_card_sales;
create table temp.ml_day_store_card_sales as
select
store_key,
replace(jzdate,'-','')  as date_key,
sum(ystotal) as sales_amt_no_discount_y,--伊点卡应收金额
sum(sstotal) as sales_amt_y,--伊点卡实收金额
sum(ssnum) as buy_cnt_y,--伊点卡购买张数
sum(case when billtype='0' then 0.00 else (-1)*ystotal end ) as sales_amt_no_discount_refund_y,--伊点卡退款应收金额
sum(case when billtype='0' then 0.00 else (-1)*sstotal end ) as sales_amt_refund_y--伊点卡退款实收金额
from
dw.fact_user_card_trade_item
where
jzdate >= '$earlierYMD' and jzdate < '$todayYMD'
and cardtypeclasscode='03'--01悠点卡，03伊点卡
--and billtype='1'--0-购卡 1-退卡
and datastatus='9'
group by
store_key
,replace(jzdate,'-','')
;
--卡充值相关
drop table  if exists temp.ml_day_store_mem_recharge;
create table temp.ml_day_store_mem_recharge as
select
store_key,
replace(jzdate,'-','')  as date_key,
sum(ystotal) as mem_save_amt,--悠点卡充值金额，也就是会员充值业绩额(亦是到账金额)
sum(ystotal) as sales_amt_no_discount_u,--悠点卡应收金额
sum(sstotal) as sales_amt_u,--悠点卡实收金额
sum(ssnum) as saved_cnt_u,--悠点卡充值次数
sum(case when billtype='0' then 0.00 else (-1)*ystotal end ) as sales_amt_no_discount_refund_u,--悠点卡退款应收金额
sum(case when billtype='0' then 0.00 else (-1)*sstotal end ) as sales_amt_refund_u--悠点卡退款实收金额
from dw.fact_user_card_deposit_item
where
jzdate >= '$earlierYMD' and jzdate < '$todayYMD'
and cardtypeclasscode='01'--01悠点卡，03伊点卡
and datastatus='9'
group by
store_key
,replace(jzdate,'-','')
;
--当日会员拉新(依赖任务916)
drop table  if exists temp.ml_day_store_new_mem;
create table temp.ml_day_store_new_mem as
SELECT
replace(substr(a.register_date,1,10),'-','') as date_key,
a.yard_store as store_key,
count(distinct(a.user_id)) as new_mem_cnt--拉新人数
from temp.wf_member_user_info a
where
substr(a.register_date,1,10) >= '$earlierYMD' and substr(a.register_date,1,10) < '$todayYMD'
and (a.is_reg_store_token=1 or a.is_reg_store_applet=1)
group by replace(substr(a.register_date,1,10),'-',''),a.yard_store
;

--依赖任务916
drop table  if exists temp.ml_day_store_store_reg;
create table temp.ml_day_store_store_reg as
SELECT
replace(substr(a.register_date,1,10),'-','') as date_key,
count(distinct(a.user_id)) as store_reg_mem_cnt,--门店注册会员数
a.yard_store as store_key
from temp.wf_member_user_info a
where
substr(a.register_date,1,10) >= '$earlierYMD' and substr(a.register_date,1,10) < '$todayYMD'
and a.yard_store not in ('IF01','IF10','IF15','IF55','Y011','-9999')
group by replace(substr(a.register_date,1,10),'-',''),a.yard_store
;

--依赖任务137
drop table  if exists temp.ml_day_store_store_dev;
create table temp.ml_day_store_store_dev as
select
store_id as store_key,
replace(dt,'-','') as date_key,
app_reg_num as app_reg_mem_cnt,--app注册会员数
small_routine_reg_num as applets_reg_mem_cnt,--小程序注册会员数
down_num as active_dev_cnt--激活设备数
from
ods.store_energize_reg_num
where
dt >= '$earlierYMD' and dt < '$todayYMD'
--dt>='2021-05-06'
;

drop table  if exists temp.ml_day_store_group_fans;
create table temp.ml_day_store_group_fans as
select
sum(fans_num) as fans_cnt,--社群粉丝数
count(distinct(wxid)) as group_cnt,--社群数
dt as date_key,
store_key
from
(
select
t2.membertotal as fans_num,
t2.dt,
t1.wxid,
upper(t3.store) as store_key
from
(select
wxid
from
(
select
wxid,
owner_id
from ods.wkt_groups
LATERAL VIEW explode(split(ownerwxids,',')) owner_id AS owner_id
)t
where owner_id in ('wxid_1dme58g6h9mi22','wxid_90y8vlyo2suz22','wxid_dkcfa0v4nib622')
group by wxid
) t1
left join
(select * from ods.wkt_group_members where dt >= '$earlier_2' and dt < '$today') t2 on t1.wxid = t2.wxid
left join
ods.wkt_outrelation t3 on t1.wxid = t3.wxid
where t3.store is not null and t3.store !='' and t3.store !='0'
)tb
group by dt,store_key
;
drop table  if exists temp.ml_day_store_group_fans_a;
create table temp.ml_day_store_group_fans_a as
select
tb.date_key as date_key,
tb.store_key as store_key,
(tb.today_fans-tb.yester_fans) as new_fans_cnt,--新增社群粉丝数
(tb.today_groups-tb.yester_groups) as new_groups_cnt--新增社群数
from
(
select
if(t1.fans_cnt is null,0,t1.fans_cnt) as today_fans,
if(t2.fans_cnt is null,0,t2.fans_cnt) as yester_fans,
if(t1.group_cnt is null,0,t1.group_cnt) as today_groups,
if(t2.group_cnt is null,0,t2.group_cnt) as yester_groups,
t1.store_key,
t1.date_key
from
temp.ml_day_store_group_fans t1
left join
temp.ml_day_store_group_fans t2 on date_add(concat(substr(t1.date_key,1,4),'-',substr(t1.date_key,5,2),'-',substr(t1.date_key,7,2)),-1) = concat(substr(t2.date_key,1,4),'-',substr(t2.date_key,5,2),'-',substr(t2.date_key,7,2)) and t1.store_key = t2.store_key
)tb
;

--当日门店发起的直播场次（伊直播）
drop table  if exists temp.ml_day_store_live_broadcast;
create table temp.ml_day_store_live_broadcast as
select
date_format(io.actual_start_time,'yyyyMMdd') as date_key
,io.store_number as store_key
,count(distinct io.number) as live_broadcast_cnt--门店发起的直播场次（伊直播）
from ods.xt_live_live_info  io
where
date_format(io.actual_start_time,'yyyyMMdd') >= '$earlier'
and date_format(io.actual_start_time,'yyyyMMdd') < '$today'
and io.is_delete = 0
group by date_format(io.actual_start_time,'yyyyMMdd'),io.store_number
;

--当日门店对应的城区总下的所有门店的团购订单量
drop table  if exists temp.ml_store_gripper_area_group_buy;
create table temp.ml_store_gripper_area_group_buy as
select
c.area_owner,
a.date_key,
sum(a.actual_amount) as sales_amt_area_group_buy,--门店对应的城区总下的所有门店的团购订单业绩额
count(distinct(case when a.trade_status = '-6' then null else a.order_store_no end )) as sales_cnt_area_group_buy--门店对应的城区总下的所有门店的团购订单笔数
from dw.fact_trade_order a
left join dw.dim_channel b on a.channel_key=b.channel_key
left join dw.dim_store c on a.store_key=c.store_key
where
b.channel_source in('01','04')
and a.dt>='$earlierYMD_2'
and a.order_business_type IN (0,1,2)
and b.channel_type = '155'
and a.date_key >= '$earlier' and a.date_key < '$today'
and a.trade_status in ('3','5','8','-9999','9','-6')
group by
c.area_owner,
a.date_key
;

--3.插入数据
insert overwrite table dm.store_daily_analysis partition(dt)

select
reverse(concat(a.store_key,a.date_key)) as id,
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
coalesce(b.sales_amt_no_discount,0) as  sales_amt_no_discount,--应收金额
coalesce(b.sales_amt,0) as sales_amt,--实收金额
coalesce(cast(l.target as decimal(18,2)),-99) as sales_amt_tgt,
coalesce(b.sales_amt_subsi,0) as  sales_amt_subsi,--销售额（含补贴）
coalesce(b.sales_amt_discount,0) as  sales_amt_discount,--优惠金额
coalesce(b.sales_amt_pay,0) as  sales_amt_pay,--支付金额
coalesce(b.sales_amt_refund,0) as  sales_amt_refund,--退款金额
coalesce(b.sales_cnt_refund,0) as sales_cnt_refund,--退款订单笔数
coalesce(b.sales_cnt,0) as  sales_cnt,--订单笔数(正向)

coalesce(b.passenger_flow,0) as passenger_flow,--客流
coalesce(b.sales_amt_no_discount_mem,0) as sales_amt_no_discount_mem, --会员应收金额
coalesce(b.sales_amt_mem,0) as sales_amt_mem,--会员实收金额
coalesce(round(cast(substr(m.day_mem_percent_target,1,instr(m.day_mem_percent_target,'.')) as int)/100,2),-99) as sales_amt_mem_percent_tgt,--会员销售额占比目标
coalesce(b.sales_amt_subsi_mem,0) as sales_amt_subsi_mem, --会员销售额含补贴
coalesce(b.sales_person_cnt_mem,0) as sales_person_cnt_mem,--消费会员数（不算逆向）
coalesce(b.sales_amt_discount_mem,0) as sales_amt_discount_mem,--会员优惠金额
coalesce(b.sales_amt_pay_mem,0) as sales_amt_pay_mem,--会员支付金额
coalesce(b.sales_amt_refund_mem,0) as sales_amt_refund_mem,--会员退款金额
coalesce(b.sales_cnt_refund_mem,0) as sales_cnt_refund_mem,--会员退款订单笔数
coalesce(b.sales_cnt_mem,0) as sales_cnt_mem,--会员订单笔数

coalesce(c.bg_open_card_cnt,0) as bg_open_card_cnt,--黑金开卡量
coalesce(d.mem_save_amt,0) as mem_save_amt,--会员充值业绩额(亦是到账金额)
coalesce(cast(m.day_recharge_target as decimal(18,2)),-99) as mem_save_amt_tgt,--会员充值业绩额目标
coalesce(e.new_mem_cnt,0) as new_mem_cnt,--拉新人数
coalesce(cast(m.day_laxin_target as int),-99) as new_mem_cnt_tgt,--拉新目标
coalesce(f.store_reg_mem_cnt,0) as store_reg_mem_cnt,--门店注册会员数
coalesce(g.app_reg_mem_cnt,0) as app_reg_mem_cnt,--app注册会员数
coalesce(g.applets_reg_mem_cnt,0) as applets_reg_mem_cnt,--小程序注册会员数
coalesce(g.active_dev_cnt,0) as active_dev_cnt,--激活设备数
coalesce(h.group_cnt,0) as group_cnt,--社群数
coalesce(h.fans_cnt,0) as fans_cnt,--社群粉丝数
coalesce(cast(m.day_group_person_target as int),-99) as fans_cnt_tgt,--社群粉丝数目标
coalesce(i.new_groups_cnt,0) as new_groups_cnt,--新增社群数
coalesce(i.new_fans_cnt,0) as new_fans_cnt,--新增社群粉丝数
coalesce(j.live_broadcast_cnt,0) as live_broadcast_cnt,--门店发起的直播场次（伊直播）
coalesce(k.sales_amt_area_group_buy,0) as sales_amt_area_group_buy,--门店对应的城区总下的所有门店的团购订单业绩额
coalesce(k.sales_cnt_area_group_buy,0) as sales_cnt_area_group_buy,--门店对应的城区总下的所有门店的团购订单笔数

coalesce(d1.sales_amt_no_discount_y,0) as sales_amt_no_discount_y,--伊点卡应收金额
coalesce(d1.sales_amt_y,0) as sales_amt_y,--伊点卡实收金额
coalesce(d1.buy_cnt_y,0) as buy_cnt_y,--伊点卡购买张数
coalesce(d1.sales_amt_no_discount_refund_y,0) as sales_amt_no_discount_refund_y,--伊点卡退款应收金额
coalesce(d1.sales_amt_refund_y,0) as sales_amt_refund_y,--伊点卡退款实收金额
coalesce(d.sales_amt_no_discount_u,0) as sales_amt_no_discount_u,--悠点卡应收金额
coalesce(d.sales_amt_u,0) as sales_amt_u,--悠点卡实收金额
coalesce(d.sales_amt_no_discount_refund_u,0) as sales_amt_no_discount_refund_u,--悠点卡退款应收金额
coalesce(d.sales_amt_refund_u,0) as sales_amt_refund_u, --悠点卡退款实收金额
coalesce(d.saved_cnt_u,0) as saved_cnt_u,--悠点卡充值次数

concat(substr(a.date_key,1,4),'-',substr(a.date_key,5,2),'-',substr(a.date_key,7,2)) as dt

from temp.ml_day_store_base a
left join temp.ml_day_store_order b on a.store_key=b.store_key and a.date_key=b.date_key
left join temp.ml_day_store_black_gold c on a.store_key=c.store_key and a.date_key=c.date_key
left join temp.ml_day_store_mem_recharge d on a.store_key=d.store_key and a.date_key=d.date_key
left join temp.ml_day_store_card_sales d1 on a.store_key=d1.store_key and a.date_key=d1.date_key
left join temp.ml_day_store_new_mem e on a.store_key=e.store_key and a.date_key=e.date_key
left join temp.ml_day_store_store_reg f on a.store_key=f.store_key and a.date_key=f.date_key
left join temp.ml_day_store_store_dev g on a.store_key=g.store_key and a.date_key=g.date_key
left join temp.ml_day_store_group_fans h on a.store_key=h.store_key and a.date_key=h.date_key
left join temp.ml_day_store_group_fans_a i on a.store_key=i.store_key and a.date_key=i.date_key
left join temp.ml_day_store_live_broadcast j on a.store_key=j.store_key and a.date_key=j.date_key

left join temp.ml_store_gripper_area_group_buy k on a.area_manager_code=k.area_owner and a.date_key=k.date_key

left join demo.day_store_achievement_target l on a.store_key = l.org_code and a.date_key = replace(l.date_key,'-','')
left join
(
select
trim(replace(date_key,'-','')) as date_key,
trim(store_key) as store_key,
day_mem_percent_target,
day_group_person_target,
day_shetuan_amount_target,
day_shetuan_order_target,
day_shetuan_unit_price_target,
day_takeout_amount_target,
day_laxin_target,
day_recharge_target
from demo.operation_300_target
where trade_type='门店普通订单'
)m on a.store_key=m.store_key and a.date_key=m.date_key
;

