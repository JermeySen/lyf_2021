create table supplier_analysis_bigscreen (
 date_key                    int            comment '日期yyyyMMdd'
,date_month                  string         comment '月份yyyyMM'
,supply_level                string         comment '供应商等级'
,order_complete_rate         decimal(10,4)  comment '订单完成率'
,order_intime_rate           decimal(10,4)  comment '订单及时率'
,supply_name                 string         comment '供应商名称'
,sec_category                string         comment '二级类目'
,purchase_amount             decimal(20,6)  comment '采购金额'
,purchase_amount_rank        int            comment '排行'
,in_stock_standard_rate      decimal(10,4)  comment '入库批次合格率'
,module_tag                  int            comment '模块标识'    -- 1 订单完成率  2订单及时率 3 入库批次合格率 4 采购额top供应商排名  9 总订单完成率  10 总订单及时率
,module_tag_name             string         comment '模块标识名'
)

