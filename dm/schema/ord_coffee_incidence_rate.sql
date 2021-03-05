drop table dm.ord_coffee_incidence_rate;
create table dm.ord_coffee_incidence_rate (
 date_month                  string         comment '支付月份yyyyMM'
,coffee_incidence_rate       decimal(20,6)  comment '连带率'
,coffee_other_user_count     int            comment '购买咖啡当天还购买了其他商品的人数'
,coffee_user_count           int            comment '购买咖啡人数'
,etl_last_updatetime         timestamp     comment '最后更新时间'
)


-----------------------------------


