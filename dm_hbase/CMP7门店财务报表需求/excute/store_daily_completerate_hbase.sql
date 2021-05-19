/*
--主题描述：CMP7日达成率
--调度策略：每天跑近1天数据，任务号
--业务范围：直营加盟
--作者：zengjiamin
--日期：20210518
 */
insert into dm.store_daily_completerate_hbase
select
 id
,store_code
,pay_date
,sales_amt_tgt
,sales_amt
,sales_cnt-sales_cnt_refund
from dm.store_daily_analysis
where dt >=  date_format(date_add(current_date(),-1),'yyyy-MM-dd')