create table dm.user_score_expired_product_date
(
 expire_product_date     string     comment '过期积分生产日期'
,expire_score            double     comment '过期积分'
,etl_updatetime          datetime   comment 'etl_最后更新时间'
)