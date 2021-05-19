drop table if exists dm.store_monthly_hbase;
create EXTERNAL table dm.store_monthly_hbase(
key string comment '主键'
,store_key string comment '门店编码'
,store_name string comment '门店名称'
,d_month string comment '月份'
,sale_amt decimal(18,4) comment '业绩（门店当天POS实收金额，等于门店零售+门店团购+社区团+外卖订单金额+地推+直播（扣除退款金额，来伊份APP外卖是线上实付金额，第三方外卖是过称金额））'
,sale_amt_target decimal(18,6) comment '业绩目标'
,sale_cnt bigint comment '成交笔数'
,mem_sale_amt decimal(18,4) comment '会员销售业绩'
,area_group_buy_sale_cnt bigint comment '门店对应的城区总下的所有门店的团购订单量'
,area_group_buy_sale_cnt_target bigint comment '门店对应的城区总下的所有门店的团购订单量目标'
,bg_open_card_cnt bigint comment '黑金开卡量'
,bg_open_card_cnt_target bigint comment '黑金开卡目标'
,single_reg_num bigint comment '会员拉新数量'
,single_reg_num_target bigint comment '会员拉新目标'
,mem_save_amt decimal(18,4) comment '会员充值金额(即是到账金额)'
,mem_save_amt_target decimal(18,4) comment '会员充值目标'
,take_out_sale_amt decimal(18,4) comment '外卖金额'
,take_out_sale_amt_target decimal(18,4) comment '外卖金额目标'
,join_group_sale_amt decimal(18,4) comment '拼团到店金额'
,join_group_sale_amt_target decimal(18,4) comment '拼团到店金额目标'
,ground_push_cnt  bigint comment '地推订单量'
,ground_push_cnt_target  bigint comment '地推订单量目标'
,live_broadcast_cnt  bigint comment '门店发起的直播场次（伊直播）'
,live_broadcast_cnt_target  bigint comment '门店发起直播场次目标'
)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES
(
"hbase.columns.mapping" =
":key
,cf:store_key
,cf:store_name
,cf:d_month
,cf:sale_amt
,cf:sale_amt_target
,cf:sale_cnt
,cf:mem_sale_amt
,cf:area_group_buy_sale_cnt
,cf:area_group_buy_sale_cnt_target
,cf:bg_open_card_cnt
,cf:bg_open_card_cnt_target
,cf:single_reg_num
,cf:single_reg_num_target
,cf:mem_save_amt
,cf:mem_save_amt_target
,cf:take_out_sale_amt
,cf:take_out_sale_amt_target
,cf:join_group_sale_amt
,cf:join_group_sale_amt_target
,cf:ground_push_cnt
,cf:ground_push_cnt_target
,cf:live_broadcast_cnt
,cf:live_broadcast_cnt_target")
TBLPROPERTIES("hbase.table.name" = "ns_olap:store_monthly");