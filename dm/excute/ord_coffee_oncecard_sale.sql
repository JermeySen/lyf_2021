/*
--主题描述：咖啡—次卡销售情况以及核销杯数
--存储策略：每月存最后一天月累计数据
--调度策略：T+1每天早上五点左右点执行 依赖执行前一天数据 调度任务号：209,252,147,540,1341,1342
--维度    ：月份
--业务范围：直营，app，咖啡sku_key in ('20313','20314','20315','20316')
--作者：zengjiamin
--日期：20210305
---------------------------------------------------指标定义
时间范围：202010至今
次卡类型：指N元M杯的次卡；
次卡的张数：指对应的时间段内，销售了多少张次卡；（目前次卡只在APP渠道销售）
销售的咖啡杯数：指对应月份销售的次卡对应的咖啡杯数，例如38元5杯的次卡销售了 3张次卡，那么杯数为15；
核销杯数：指对应月份，历史销售核销的次卡中的杯数，进行了核销的杯数

shell 日期循环脚本
startDate=20171201
endDate=20171205
while [[ $startDate -le $endDate ]];
do
   echo $startDate
   startDate=`date -d "$startDate 1 days" +"%Y%m%d"`
done
 */

delete from dm.ord_coffee_oncecard_sale  where date_month = date_format(date_add(current_date(),-1),'yyyyMM');
-- 次卡产品编码
with product as (
select
      a.sku_code
     ,a.product_name
     ,a.card_num
from ods.xt_community_t_community_product  a where a.product_name like '%咖啡%'
)
-- 次卡销售情况
 , card_sale as (
     select
                  substring(oi.date_key,1,6)               as date_month
                 ,count(distinct oi.order_no,oi.store_key) as ordernum
                 ,sum(oi.jc_sku_quantity * product.card_num) as sale_count
                 ,sum(oi.price * oi.jc_sku_quantity)  amout
                 ,sum(oi.actual_amount) actual_amount
          from dw.fact_trade_order_item oi
          inner join product on oi.sku_key = product.sku_code
          inner join dw.dim_channel cl on oi.channel_key = cl.channel_key
          where oi.date_key between concat(date_format(date_add(current_date(),-1),'yyyyMM'),'01')  and date_format(date_add(current_date(),-1),'yyyyMMdd')
          and   trade_status in  (3,5,8,9,-9999,-6)  -- 扣除退款3，5，8，9 -9999 正向-6逆向
          and   cl.channel_source in ('01','02') -- 直营  app
         group by substring(oi.date_key,1,6)
      )

--   使用核销的流水号 与 门店编码
, msc as (
        select
              ta.lstpaysaleno
             ,ta.lstpayorgcode
        from  ods.msc_tisucard tc
        inner join ods.msc_tisuaccount ta on tc.VipCardNo = ta.vipcardno
        where ta.dt=date_format(current_date(), 'yyyy-MM-dd')
        and   ta.balancetotal = 0  -- 表示已使用
        and   tc.cardstatus = '02' -- 正常
        and   ta.lstpaysaleno is  not null
        group by  ta.lstpaysaleno
                 ,ta.lstpayorgcode
         )
  --核销咖啡杯数
, verificate as (
         select
                  substring(oi.date_key,1,6)  as date_month
                 ,sum(oi.jc_sku_quantity) as verificate_count
          from dw.fact_trade_order_item oi
          inner join msc on oi.store_key = msc.lstpayorgcode and oi.order_out_no = msc.lstpaysaleno --and oi.date_key = date_format(a.lstpaydate,'yyyyMMdd')
          inner join dw.dim_channel cl on oi.channel_key = cl.channel_key
          where oi.date_key between concat(date_format(date_add(current_date(),-1),'yyyyMM'),'01')  and date_format(date_add(current_date(),-1),'yyyyMMdd')
          and   trade_status in  (3,5,8,9,-9999,-6)  -- 扣除退款3，5，8，9 -9999 正向-6逆向
          and   cl.channel_source in ('01','02') -- 直营  app
          and   oi.sku_key in ('20313' ,'20314', '20315' ,'20316')  -- 核销的咖啡产品key
         group by substring(oi.date_key,1,6)
         )

insert into  dm.ord_coffee_oncecard_sale
select
     card_sale.date_month
    ,card_sale.ordernum
    ,card_sale.sale_count
    ,card_sale.amout
    ,card_sale.actual_amount
    ,verificate.verificate_count
    ,from_unixtime(unix_timestamp(current_timestamp()) + 28800)
 from card_sale inner join verificate on card_sale.date_month= verificate.date_month