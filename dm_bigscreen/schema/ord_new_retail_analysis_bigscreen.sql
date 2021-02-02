drop table dm.ord_new_retail_analysis_bigscreen;

create table dm.ord_new_retail_analysis_bigscreen (
 date_key                    int            comment '统计日期yyyyMMdd'
,date_year                   string         comment '支付年份yyyy'
,date_day                    string         comment '支付日期yyyyMMdd'
,sale_type_id                int            comment '销售类型id'
,sale_type_name              string         comment '销售类型'  -- 1,社区团购，2全员销售，3直播，4app外卖 ，5第三方外卖，6全渠道总销售额
,sale_amount                 decimal(20,6)  comment '销售额'
,sale_amount_no_refund       decimal(20,6)  comment '不含退款销售额'
,sale_amount_target          decimal(20,6)  comment '目标'
,complete_rate               decimal(10,4)   comment '达成率'
,pay_user_numbers            int            comment '支付人数'
,related_rate                decimal(10,4)   comment '连带率'
,share_rate                  decimal(10,4)   comment '全员销售分享转化率'
,broadcast_numbers           int            comment '直播场次'
,order_numbers               int            comment '外卖成交笔数'
)


-----------------------------------


