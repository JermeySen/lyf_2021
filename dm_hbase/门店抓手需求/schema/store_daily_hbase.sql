drop table if exists dm.store_daily_hbase;
create EXTERNAL table dm.store_daily_hbase(
`key` string COMMENT '主键',
`store_key` string COMMENT '门店编码',
`store_name` string COMMENT '门店名称',

`store_type` string COMMENT '门店类型',
`store_status` string COMMENT '门店当日状态（正常营业/关店）',
`close_date` string COMMENT '关店日期',
`demolition_date` string COMMENT '拆店日期',
`l2_company_code` string COMMENT '所属二级子公司编码',
`l2_company_name` string COMMENT '所属二级子公司名称',
`franchisee_code` string COMMENT '所属加盟商编码',
`franchisee_name` string COMMENT '所属加盟商名称',
`big_area_manager_code` string COMMENT '大区负责人工号',
`big_area_manager_name` string COMMENT '大区负责人姓名',
`area_manager_code` string COMMENT '区域负责人工号',
`area_manager_name` string COMMENT '区域负责人姓名',

`date_key` string COMMENT '日期',
`sale_amt` decimal(18,4) COMMENT '业绩（门店当天POS实收金额，等于门店零售+门店团购+社区团+外卖订单金额+地推+直播（扣除退款金额，来伊份APP外卖是线上实付金额，第三方外卖是过称金额））',
`sale_amt_target` decimal(18,6) COMMENT '业绩目标',
`sale_cnt` bigint COMMENT '成交笔数',
`mem_sale_amt` decimal(18,4) COMMENT '会员销售业绩',
`area_group_buy_sale_cnt` bigint COMMENT '门店对应的城区总下的所有门店的团购订单量',
`area_group_buy_sale_cnt_target` bigint COMMENT '门店对应的城区总下的所有门店的团购订单量目标',
`bg_open_card_cnt` bigint COMMENT '黑金开卡量',
`bg_open_card_cnt_target` bigint COMMENT '黑金开卡目标',
`single_reg_num` bigint COMMENT '会员拉新数量',
`single_reg_num_target` bigint COMMENT '会员拉新目标',
`mem_save_amt` decimal(18,4) COMMENT '会员充值金额(即是到账金额)',
`mem_save_amt_target` decimal(18,4) COMMENT '会员充值目标',
`take_out_sale_amt` decimal(18,4) COMMENT '外卖金额',
`take_out_sale_amt_target` decimal(18,4) COMMENT '外卖金额目标',
`join_group_sale_amt` decimal(18,4) COMMENT '拼团到店金额',
`join_group_sale_amt_target` decimal(18,4) COMMENT '拼团到店金额目标',
`ground_push_cnt` bigint COMMENT '地推订单量',
`ground_push_cnt_target` bigint COMMENT '地推订单量目标',
`live_broadcast_cnt` bigint COMMENT '门店发起的直播场次（伊直播）',
`live_broadcast_cnt_target` bigint COMMENT '门店发起直播场次目标',

`no_discount_sales_amt` decimal(18,4) COMMENT '应收金额',
`subsi_sales_amt` decimal(18,4) COMMENT '销售额（含补贴）',
`discount_sales_amt` decimal(18,4) COMMENT '优惠金额',
`pay_sales_amt` decimal(18,4) COMMENT '支付金额',
`refund_sales_amt` decimal(18,4) COMMENT '退款金额',
`refund_sales_cnt` int COMMENT '退款订单笔数',
`passenger_flow_cnt` int COMMENT '客流（取正向订单数量+逆向订单数量，即：正逆向订单数量绝对值相加，均从POS上取数）',
`no_discount_mem_sales_amt` decimal(18,4) COMMENT '会员应收金额',
`subsi_mem_sales_amt` decimal(18,4) COMMENT '会员销售额含补贴',
`mem_sales_person_cnt` int COMMENT '消费会员数（不算逆向）',
`discount_mem_sales_amt` decimal(18,4) COMMENT '会员优惠金额',
`pay_mem_sales_amt` decimal(18,4) COMMENT '会员支付金额',
`refund_mem_sales_amt` decimal(18,4) COMMENT '会员退款金额',
`refund_mem_sales_cnt` int COMMENT '会员退款订单笔数',
`mem_sales_cnt` int COMMENT '会员订单笔数',
`mem_store_reg_cnt` int COMMENT '门店注册会员数',
`mem_app_reg_cnt` int COMMENT 'APP注册会员数',
`mem_applets_reg_cnt` int COMMENT '小程序注册会员数',
`active_dev_cnt` int COMMENT '激活设备数',
`group_cnt` int COMMENT '社群数',
`fans_cnt` int COMMENT '社群粉丝数',
`new_groups_cnt` int COMMENT '新增社群数',
`new_fans_cnt` int COMMENT '新增社群粉丝数',
`area_group_buy_sales_amt` decimal(18,4) COMMENT '门店对应的城区总下的所有门店的团购订单业绩额',
`no_discount_y_sales_amt` decimal(18,4) COMMENT '伊点卡应收金额',
`y_sales_amt` decimal(18,4) COMMENT '伊点卡实收金额',
`y_buy_cnt` int COMMENT '伊点卡购买张数',
`no_discount_refund_y_sales_amt` decimal(18,4) COMMENT '伊点卡退款应收金额',
`refund_y_sales_amt` decimal(18,4) COMMENT '伊点卡退款实收金额',
`no_discount_u_sales_amt` decimal(18,4) COMMENT '悠点卡应收金额',
`u_sales_amt` decimal(18,4) COMMENT '悠点卡实收金额',
`no_discount_refund_u_sales_amt` decimal(18,4) COMMENT '悠点卡退款应收金额',
`refund_u_sales_amt` decimal(18,4) COMMENT '悠点卡退款实收金额',
`u_saved_cnt` int COMMENT '悠点卡充值次数'
,period_6_sale_amt decimal(18,4) comment '时间段（6:00-6:59）的销售额'
,period_7_sale_amt decimal(18,4) comment '时间段（7:00-7:59）的销售额'
,period_8_sale_amt decimal(18,4) comment '时间段（8:00-8:59）的销售额'
,period_9_sale_amt decimal(18,4) comment '时间段（9:00-9:59）的销售额'
,period_10_sale_amt decimal(18,4) comment '时间段（10:00-10:59）的销售额'
,period_11_sale_amt decimal(18,4) comment '时间段（11:00-11:59）的销售额'
,period_12_sale_amt decimal(18,4) comment '时间段（12:00-12:59）的销售额'
,period_13_sale_amt decimal(18,4) comment '时间段（13:00-13:59）的销售额'
,period_14_sale_amt decimal(18,4) comment '时间段（14:00-14:59）的销售额'
,period_15_sale_amt decimal(18,4) comment '时间段（15:00-15:59）的销售额'
,period_16_sale_amt decimal(18,4) comment '时间段（16:00-16:59）的销售额'
,period_17_sale_amt decimal(18,4) comment '时间段（17:00-17:59）的销售额'
,period_18_sale_amt decimal(18,4) comment '时间段（18:00-18:59）的销售额'
,period_19_sale_amt decimal(18,4) comment '时间段（19:00-19:59）的销售额'
,period_20_sale_amt decimal(18,4) comment '时间段（20:00-20:59）的销售额'
,period_21_sale_amt decimal(18,4) comment '时间段（21:00-21:59）的销售额'
,period_22_sale_amt decimal(18,4) comment '时间段（22:00-22:59）的销售额'
,period_23_sale_amt decimal(18,4) comment '时间段（23:00-23:59）的销售额'
)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES
(
"hbase.columns.mapping" =
":key
,cf:store_key
,cf:store_name
,cf:store_type
,cf:store_status
,cf:close_date
,cf:demolition_date
,cf:l2_company_code
,cf:l2_company_name
,cf:franchisee_code
,cf:franchisee_name
,cf:big_area_manager_code
,cf:big_area_manager_name
,cf:area_manager_code
,cf:area_manager_name
,cf:date_key
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
,cf:live_broadcast_cnt_target
,cf:no_discount_sales_amt
,cf:subsi_sales_amt
,cf:discount_sales_amt
,cf:pay_sales_amt
,cf:refund_sales_amt
,cf:refund_sales_cnt
,cf:passenger_flow_cnt
,cf:no_discount_mem_sales_amt
,cf:subsi_mem_sales_amt
,cf:mem_sales_person_cnt
,cf:discount_mem_sales_amt
,cf:pay_mem_sales_amt
,cf:refund_mem_sales_amt
,cf:refund_mem_sales_cnt
,cf:mem_sales_cnt
,cf:mem_store_reg_cnt
,cf:mem_app_reg_cnt
,cf:mem_applets_reg_cnt
,cf:active_dev_cnt
,cf:group_cnt
,cf:fans_cnt
,cf:new_groups_cnt
,cf:new_fans_cnt
,cf:area_group_buy_sales_amt
,cf:no_discount_y_sales_amt
,cf:y_sales_amt
,cf:y_buy_cnt
,cf:no_discount_refund_y_sales_amt
,cf:refund_y_sales_amt
,cf:no_discount_u_sales_amt
,cf:u_sales_amt
,cf:no_discount_refund_u_sales_amt
,cf:refund_u_sales_amt
,cf:u_saved_cnt
,cf:period_6_sale_amt
,cf:period_7_sale_amt
,cf:period_8_sale_amt
,cf:period_9_sale_amt
,cf:period_10_sale_amt
,cf:period_11_sale_amt
,cf:period_12_sale_amt
,cf:period_13_sale_amt
,cf:period_14_sale_amt
,cf:period_15_sale_amt
,cf:period_16_sale_amt
,cf:period_17_sale_amt
,cf:period_18_sale_amt
,cf:period_19_sale_amt
,cf:period_20_sale_amt
,cf:period_21_sale_amt
,cf:period_22_sale_amt
,cf:period_23_sale_amt")
TBLPROPERTIES("hbase.table.name" = "ns_olap:store_daily");