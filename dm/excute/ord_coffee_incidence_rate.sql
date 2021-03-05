/*
--主题描述：咖啡—连带率
--存储策略：每月存最后一天月累计数据
--调度策略：T+1每天早上八点执行 依赖执行前一天数据 调度任务号：1295  同步任务号号：1296
--维度    ：月份
--业务范围：直营，sku_key in ('20313','20314','20315','20316')
--作者：zengjiamin
--日期：20210303
---------------------------------------------------指标定义
--咖啡连带率：去门店购买咖啡当天还购买了门店其他商品的人数占比（仅统计在门店验证了会员的用户=购买咖啡当天还购买了其他商品的人数/咖啡购买人数）
--咖啡购买人数：当天购买咖啡则算1人，时间纬度内不去重；
--购买咖啡当天还购买了其他商品的人数：购买咖啡当天还购买了其他商品的人数；

*/

delete from dm.ord_coffee_incidence_rate where date_month = date_format(date_add(current_date(),-1),'yyyyMM');

with  a  as (
          select
                  oi.date_key
                 ,oi.buyer_key
          from dw.fact_trade_order_item oi
          inner join dw.dim_channel c on oi.channel_key =c.channel_key
          where oi.date_key between concat(date_format(date_add(current_date(),-1),'yyyyMM'),'01')  and date_format(date_add(current_date(),-1),'yyyyMMdd')
          and   trade_status in  (3,5,8,9,-9999,-6)  -- 扣除退款3，5，8，9 -9999 正向-6逆向
          and   c.channel_source ='01' -- 直营
          and   oi.sku_key  in ('20313','20314','20315','20316')
          group by oi.date_key,oi.buyer_key
          )
,    b  as (
          select
                  oi.date_key
                 ,oi.buyer_key
          from dw.fact_trade_order_item oi
          inner join dw.dim_channel c on oi.channel_key =c.channel_key
          where oi.date_key between concat(date_format(date_add(current_date(),-1),'yyyyMM'),'01')  and date_format(date_add(current_date(),-1),'yyyyMMdd')
          and   trade_status in  (3,5,8,9,-9999,-6)  -- 扣除退款3，5，8，9 -9999 正向-6逆向
          and   c.channel_source ='01' -- 直营
          and   oi.sku_key not in ('20313','20314','20315','20316')
          group by oi.date_key,oi.buyer_key
         )

insert into  dm.ord_coffee_incidence_rate
select
       coffee.date_month
      ,other.othercount / coffee.coffee_usercount
      ,other.othercount
      ,coffee.coffee_usercount
      ,from_unixtime(unix_timestamp(current_timestamp()) + 28800)
from (
      select
            substring(a.date_key,1,6) as  date_month
           ,count(distinct a.date_key,a. buyer_key ) as coffee_usercount
      from a
      group by substring(a.date_key,1,6)
     ) coffee left join
     (
     select
            substring(a.date_key,1,6) as date_month
           ,count(distinct a.date_key,a. buyer_key ) as othercount
     from a inner join b on a.date_key = b.date_key and a.buyer_key =b.buyer_key
     group by substring(a.date_key,1,6)
     ) other on coffee.date_month = other.date_month

