create table dm.user_score_expired
(
 expire_datetime  timestamp  comment '过期日期'
,expire_score     double     comment '过期积分'
,etl_updatetime   timestamp  comment 'etl_最后更新时间'
)