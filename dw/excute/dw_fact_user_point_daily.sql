
--  取当前会员最近的积分余额
with  last_remain_point as (
 select
 member_card_key
,remain_point
,dt
from
    (
    select
         o.member_card_key
        ,o.remain_point
        ,o.dt
        ,row_number()over(partition by o.member_card_key order by o.dt desc) rn
    from dw.fact_user_point_daily  o
    ) a
where a.rn = 1
)
--  当天新的积分
, current_data as (
select
     dt
    ,member_card_key
    ,sum(case when pb.type = 0 then pb.affect_point * -1 else pb.affect_point end) affect_point
from dw.fact_user_point_bill pb
where  1=1
and  pb.dt =  date_format(date_add(current_date(),-1),'yyyy-MM-dd')
group by member_card_key,dt
)

select
date_format(date_add(current_date(),-1),'yyyyMMdd')          as date_key
,cd.member_card_key
,cd.affect_point + nvl(rp.remain_point,0)                    as remain_point
,from_unixtime(unix_timestamp(current_timestamp()) + 28800)  as etl_last_updatetime
,'中台'                                                       as etl_system
,cd.dt
from current_data cd
left join last_remain_point rp on cd.member_card_key = rp.member_card_key and cd.dt != rp.dt;
;


--全量初始化单天 积分余额
insert overwrite table dw.fact_user_point_daily partition (dt)
select
    date_key
   ,member_card_key
   ,sum(affect_point) over (partition by a.member_card_key order by a.date_key asc) remain_point
   ,etl_last_updatetime
   ,etl_system
   ,dt
from (
    select
     date_format(pb.create_time,'yyyyMMdd') as date_key
    ,member_card_key
    ,sum(case when pb.type = 0 then pb.affect_point * -1 else pb.affect_point end) affect_point
    ,from_unixtime(unix_timestamp(current_timestamp()) + 28800)  as etl_last_updatetime
    ,'中台'  as etl_system
    ,date_format(pb.create_time,'yyyy-MM-dd') as dt
    from dw.fact_user_point_bill pb
    where 1=1
    group by member_card_key,date_format(pb.create_time,'yyyyMMdd'),date_format(pb.create_time,'yyyy-MM-dd')
     ) a



