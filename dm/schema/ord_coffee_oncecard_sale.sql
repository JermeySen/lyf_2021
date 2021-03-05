drop table dm.ord_coffee_oncecard_sale;
create table dm.ord_coffee_oncecard_sale (
 date_month                       string         comment '支付月份yyyyMM'
,coffee_oncecard_ordernum         int            comment '次卡订单笔数'
,coffee_oncecard_salecount        int            comment '次卡咖啡杯数'
,coffee_oncecard_receiveamount    decimal(20,6)  comment '应收金额(折钱金额)'
,coffee_oncecard_actualamount     decimal(20,6)  comment '实收(折后业绩)'
,coffee_verificate_count          int            comment '核销杯数'
,etl_last_updatetime              timestamp      comment '最后更新时间'
)


-----------------------------------


