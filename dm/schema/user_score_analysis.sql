create table dm.user_score_analysis
(
 expired_time    string         comment '清理积分时间'
,mobile_no       string         comment '手机号'
,vipcard_no      string         comment 'vipcard'
,product_score   double         comment '产生积分'
,used_score      double         comment '使用&过期积分'
,last_score      double         comment '本次过期的积分'
,remain_score    double         comment '剩余积分'
,etl_updatetime  timestamp      comment 'etl_更新时间'
)

