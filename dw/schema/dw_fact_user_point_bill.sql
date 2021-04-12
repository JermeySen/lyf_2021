drop table dw.fact_user_point_bill;
create table dw.fact_user_point_bill (
 id                               string         comment '主键id'
,date_key                         string         comment '日期key,yyyyMMdd创建日期'
,channel_key                      string         comment '渠道编号'
,org_key                          string         comment '组织编号'
,store_key                        string         comment '门店编号'
,member_card_key                  bigint         comment '会员卡id'
,inner_serial_no                  string         comment '随机生成流水号'
,related_serial_no                string         comment '关联积分流水号'
,type                             int            comment '类型0-扣减积分 1-增加积分'
,typename                         string         comment '类型名称'
,origin_point                     bigint         comment '原始积分'
,affect_point                     bigint         comment '变动积分(单位分100 == 积分'
,effective_point                  bigint         comment '有效积分'
,serial_no                        string         comment '订单流水号'
,status                           int            comment '0-正常1-撤销'
,statusname                       string         comment '状态名称'
,is_expired                       int            comment '是否过期0-未过期 1-过期'
,scene_code                       int            comment '场景类型'
,scene_desc                       string         comment '场景描述'
,create_time                      timestamp      comment '创建时间'
,update_time                      timestamp      comment '最近更新时间'
,etl_last_updatetime              timestamp      comment 'ETL最后更新时间'
,etl_system                       string         comment '数据来源'
) PARTITIONED BY(dt string)


-----------------------------------



