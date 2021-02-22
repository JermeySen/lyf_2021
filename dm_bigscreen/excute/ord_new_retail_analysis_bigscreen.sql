/**
--主题描述：大屏—新零售
--数据探查：保留近30天，每天203条左右
--调度策略：T+1每天早上4点多执行， 依赖执行前一天数据，执行时间30分钟，调度任务号：1300  同步任务号号：1301
--作者：zengjiamin
--日期：20210113
--表依赖：dw.fact_trade_order_item ，dw.dim_channel，ods.zt_tc_order_line
--备注:因hive同步mysql 必须给默认值，所以如果默认-9999 代表null，接口判断不显示。
**/
-- 保留近30天数据
delete from  dm.ord_new_retail_analysis_bigscreen
where date_key <= cast(date_format(date_add(current_date(),-30),'yyyyMMdd') as int);

set tez.queue.name=dw;
-- 删除中间临时表
drop table if exists temp.ord_nrt_end_amount;
drop table if exists temp.ord_nrt_broadcast;
drop table if exists temp.ord_nrt_result;
-- 创建查询临时表
create table temp.ord_nrt_end_amount as
with amount as (
select
      cast(date_format(date_add(current_date(),-1),'yyyyMMdd') as int)  as date_key
     ,oi.date_key                 as date_day
     ,substr(oi.date_key , 0 ,4)  as year
     ,sum( actual_amount )        as sale_amount -- 扣除退款
     ,sum(case when oi.is_community_corps = 1              then actual_amount else 0 end) as community_sale_amount
     ,count(distinct case when oi.is_community_corps = 1   then oi.buyer_key  end)        as pay_user_numbers
     ,sum(case when cl.channel_type = '102'                then actual_amount else 0 end) as app_sale_amount
     ,sum(case when cl.channel_type in ('101','103','121') then actual_amount else 0 end) as other_sale_amount
     ,sum(case when cl.channel_type = '102' and  trade_status in  ('3','5','8','9','-9999')
               then actual_amount else 0 end)                                             as app_sale_amount_norefund
     ,sum(case when cl.channel_type in ('101','103','121')  and  trade_status in  ('3','5','8','9','-9999')
               then actual_amount else 0 end)                                             as other_sale_amount_norefund
     ,count(distinct case when trade_status in  ('3','5','8','9','-9999') and cl.channel_type = '102'
                          then oi.order_no||oi.store_key  end)                                     as app_order_numbers
     ,count(distinct case when trade_status in  ('3','5','8','9','-9999') and cl.channel_type in ('101','103','121')
                          then oi.order_no||oi.store_key end)                                     as other_order_numbers
from dw.fact_trade_order_item oi
inner join dw.dim_channel cl on oi.channel_key = cl.channel_key
where (oi.date_key between date_format(date_add(current_date(),-30),'yyyyMMdd')  and  date_format(date_add(current_date(),-1),'yyyyMMdd')
or     oi.date_key between date_format(date_add(add_months(current_date(),-12),-30),'yyyyMMdd')  and  date_format(date_add(add_months(current_date(),-12),-1),'yyyyMMdd')) -- 支付时间
and   trade_status in  ('3','5','8','9','-9999','-6')  -- 扣除退款3，5，8，9 -9999 正向-6逆向
and   cl.channel_source in ('01','02','03','04','77','78') -- 全渠道
and   substr(oi.channel_key,5,6) <> '_100_7' -- 排除门店自营外卖 ，--102_7 app自营外卖
group by oi.date_key,substr(oi.date_key ,0 ,4)
)
-- 连带购买人数
, related_buyers as (
select
         date_format(date_add(current_date(),-1),'yyyyMMdd')  as date_day
        ,count(distinct buyer_key)                            as related_buyers
from (
      select oi.buyer_key
      from  dw.fact_trade_order_item oi
      inner join dw.dim_channel cl on oi.channel_key = cl.channel_key
      where oi.is_community_corps = 1
      and   oi.date_key =  date_format(date_add(current_date(),-1),'yyyyMMdd')
      and   oi.trade_status in  ('3','5','8','9','-9999','-6')
      intersect
      select oi.buyer_key
      from  dw.fact_trade_order_item oi
      inner join dw.dim_channel cl on oi.channel_key = cl.channel_key
      where oi.is_community_corps = 0
      and   oi.date_key =  date_format(date_add(current_date(),-1),'yyyyMMdd')
      and   oi.trade_status in  ('3','5','8','9','-9999','-6')
     ) T
)

select
     ant.date_key
    ,ant.date_day
    ,ant.year
    ,ant.sale_amount
    ,ant.community_sale_amount
    ,ant.pay_user_numbers
    ,ant.app_sale_amount
    ,ant.other_sale_amount
    ,ant.app_sale_amount_norefund
    ,ant.other_sale_amount_norefund
    ,ant.app_order_numbers
    ,ant.other_order_numbers
    ,case when rbs.related_buyers is null then null else rbs.related_buyers / ant.pay_user_numbers end  as  related_rate
from amount ant
left join related_buyers rbs on ant.date_day = rbs.date_day
;
-- 直播数据
--  select
create table  temp.ord_nrt_broadcast as
select
     cast(date_format(date_add(current_date(),-1),'yyyyMMdd') as int)  as date_key
    ,a.date_day
    ,substr(a.date_day , 0 ,4)  as year
    ,a.broadcast_numbers
    ,b.sale_amount
from (
    select
       date_format(io.actual_start_time,'yyyyMMdd') as date_day
      ,count(distinct io.number)                   as broadcast_numbers
    from ods.xt_live_live_info  io
    where  date_format(io.actual_start_time,'yyyy-MM-dd') >=  date_format(date_add(current_date(),-30),'yyyy-MM-dd')
    and   io.is_delete = 0
    group by date_format(io.actual_start_time,'yyyyMMdd')
     ) a left join
     (
     select
          oi.date_key	         as date_day
         ,sum(oi.actual_amount)  as sale_amount
     from (
          select ol.id ,ol.ext_data,actual_price from  ods.zt_tc_order_line ol
          where ol.is_deleted = 0
          and   ol.ext_data like '%room%'
          and   ol.dt >=  date_format(date_add(current_date(),-30),'yyyy-MM-dd')
          ) broadcast
     inner join  dw.fact_trade_order_item oi  on substr(oi.order_store_no,0,16) = broadcast.id
     where       oi.date_key between date_format(date_add(current_date(),-30),'yyyyMMdd')  and  date_format(date_add(current_date(),-1),'yyyyMMdd')
     and         oi.dt >= date_format(date_add(current_date(),-30),'yyyy-MM-dd')
     group by    oi.date_key
     ) b on a.date_day = b.date_day;


create table temp.ord_nrt_result as

select
 date_key               as date_key
,year					as date_year
,date_day               as date_day
,1 						as sale_type_id
,'社区团购' 			as sale_type_name
,community_sale_amount  as sale_amount
,null                   as sale_amount_no_refund
,cast(null as decimal(20,6))  as sale_amount_target
,cast(null  as decimal(10,6)) as complete_rate
,pay_user_numbers       as pay_user_numbers
,related_rate           as related_rate
,cast(null  as decimal(10,6)) as share_rate
,cast(null as int) 		as broadcast_numbers
,cast(null as int) 		as order_numbers
from temp.ord_nrt_end_amount ant

union all
--****************全员销售  暂时无数据
--****************直播
select
 date_key               as date_key
,year					as date_year
,date_day               as date_day
,3 						as sale_type_id
,'直播' 				as sale_type_name
,sale_amount  		    as sale_amount
,null                   as sale_amount_no_refund
,null       			as sale_amount_target
,null					as complete_rate
,null					as pay_user_numbers
,null					as related_rate
,null 					as share_rate
,broadcast_numbers		as broadcast_numbers
,null		            as order_numbers
from temp.ord_nrt_broadcast bc

union all
--****************app外卖
select
 date_key               as date_key
,year					as date_year
,date_day               as date_day
,4 						as sale_type_id
,'app外卖' 				as sale_type_name
,app_sale_amount  		as sale_amount
,app_sale_amount_norefund  as sale_amount_no_refund
,null       			as sale_amount_target
,null					as complete_rate
,null					as pay_user_numbers
,null					as related_rate
,null 					as share_rate
,null					as broadcast_numbers
,app_order_numbers		as order_numbers

from temp.ord_nrt_end_amount ant

--****************第三方外卖
union all
select
 date_key               as date_key
,year					as date_year
,date_day               as date_day
,5 						as sale_type_id
,'第三方外卖' 			as sale_type_name
,other_sale_amount  	as sale_amount
,other_sale_amount_norefund as sale_amount_no_refund
,null       			as sale_amount_target
,null					as complete_rate
,null					as pay_user_numbers
,null					as related_rate
,null 					as share_rate
,null					as broadcast_numbers
,other_order_numbers    as order_numbers
from temp.ord_nrt_end_amount ant
--****************全渠道总销售额
union all
select
 date_key               as date_key
,year					as date_year
,date_day               as date_day
,6 						as sale_type_id
,'全渠道' 			    as sale_type_name
,sale_amount  	        as sale_amount
,null                   as sale_amount_no_refund
,null       			as sale_amount_target
,null					as complete_rate
,null					as pay_user_numbers
,null					as related_rate
,null 					as share_rate
,null					as broadcast_numbers
,null                   as order_numbers
from temp.ord_nrt_end_amount ant;
--重跑数据 删除当日
delete from dm.ord_new_retail_analysis_bigscreen
where date_key = cast(date_format(date_add(current_date(),-1),'yyyyMMdd') as int);
-- 插入当日数据
insert into  dm.ord_new_retail_analysis_bigscreen
select * from temp.ord_nrt_result;

--插入到存储格式为row format delimited fields terminated by '\u0001'，stored as TEXTFILE;
truncate table temp.ord_new_retail_analysis_bigscreen;

insert overwrite table temp.ord_new_retail_analysis_bigscreen
select
 date_key
,date_year
,date_day
,sale_type_id
,sale_type_name
,nvl(sale_amount,0)
,nvl(sale_amount_no_refund,0)  as sale_amount_no_refund
,nvl(sale_amount_target ,-9999) as sale_amount_target
,nvl(complete_rate ,-9999)     as complete_rate
,nvl(pay_user_numbers  ,0) as pay_user_numbers
,nvl(related_rate ,0)      as related_rate
,nvl(share_rate ,-9999)    as share_rate
,nvl(broadcast_numbers ,0) as broadcast_numbers
,nvl(order_numbers ,0)         as order_numbers
from  dm.nrt_bigscreen_new_retail_analysis
where date_key = cast(date_format(date_add(current_date(),-1),'yyyyMMdd') as int);




















