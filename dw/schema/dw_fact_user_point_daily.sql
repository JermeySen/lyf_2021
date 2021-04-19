drop table dw.fact_user_point_daily;
create table dw.fact_user_point_daily (
 date_key                         string         comment '日期key,yyyyMMdd创建日期'
,member_card_key                  bigint         comment '会员卡id'
,remain_point                     bigint         comment '当前积分余额'
,etl_last_updatetime              timestamp      comment 'ETL最后更新时间'
,etl_system                       string         comment '数据来源'
) PARTITIONED BY(dt string)
