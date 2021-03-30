/*
--主题描述：会员积分分析
--调度策略：没到新的过期积分时间不需要执行。
--维度    ：用户手机号
--业务范围：会员积分流水
--作者：zengjiamin
--日期：20210312
 */

with  expire as (
    select
          member_card_key
        , dt  as create_time
    from  dw.fact_user_point_bill
    where  scene_code = 1  -- 积分过期
      and  is_deleted = 0
      group by  member_card_key, dt
)


insert overwrite table dm.user_score_analysis
select
 score.expired_time
,ur.mobile
,mc.vip_card_no
,score.product_score
,score.used_score
,score.last_score
,score.product_score - score.used_score - score.last_score
,from_unixtime(unix_timestamp(current_timestamp()) + 28800)
from
(
select
     lg.member_card_key
    ,lc.create_time  as expired_time
    ,sum(case when lg.dt < lc.create_time and type = 1 then lg.affect_point / 100  else 0 end) as product_score -- '产生积分'
    ,sum(case when lg.dt < lc.create_time and type = 0 then lg.affect_point / 100  else 0 end) as used_score  --'使用&过期积分'
    ,sum(case when lg.dt = lc.create_time and type = 0 and scene_code = 1 then lg.affect_point / 100  else 0 end) as last_score  --'本次过期的积分'
from dw.fact_user_point_bill lg
inner join expire lc on lg.member_card_key = lc.member_card_key
where lg.status = 0
  and lg.is_deleted = 0
group by lg.member_card_key,lc.create_time

) score
inner join dw.dim_member_card  mc on score.member_card_key = mc.member_card_key
inner join dw.dim_user ur on ur.buyer_key = mc.buyer_key;






