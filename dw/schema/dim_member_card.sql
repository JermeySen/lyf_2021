drop table dw.dim_member_card;
create table dw.dim_member_card (
 member_card_key                  bigint         comment '会员卡id(自增长)'
,member_card_no                   string         comment '会员号'
,vip_card_no                      string         comment 'vipcardno'
,card_no                          string         comment '会员卡内号'
,card_template_code               string         comment '模板编码'
,card_template_name               string         comment '模板名称'
,member_level                     int            comment '会员等级'
,buyer_key                        bigint         comment '用户id'
,template_id                      bigint         comment '会员模板id'
,old_level                        int            comment '老等级'
,experience                       bigint         comment '经验值'
,point                            bigint         comment '积分'
,valid_start                      timestamp      comment '有效起始日期'
,valid_end                        timestamp      comment '有效截止日期'
,active_date                      timestamp      comment '激活日期'
,bind_date                        timestamp      comment '绑定日期'
,register_source                  string         comment '注册来源'
,register_terminal                string         comment '注册终端'
,register_date                    timestamp      comment '注册日期'
,register_ip                      string         comment '注册ip'
,register_address                 string         comment '注册详细地址'
,register_area_name               int            comment '注册省市区'
,register_area_id                 string         comment '注册省市编码'
,status_id                        int            comment '0-正常1-撤销'
,status_name                      string         comment '0-正常1-撤销'
,card_category_id                 bigint         comment '会员体系id'
,is_old                           int            comment '是否老会员：0 不是， 1是'
,create_time                      timestamp      comment '创建时间'
,update_time                      timestamp      comment '更新时间'
,is_deleted                       int            comment '是否删除'
,tenant_id                        string         comment '商户id'
,app_id                           string         comment 'appid'
,creator                          bigint         comment '创建人'
,etl_last_updatetime              timestamp      comment 'ETL最后更新时间'
,etl_system                       string         comment '数据来源'
)  PARTITIONED BY(dt string);


-----------------------------------


