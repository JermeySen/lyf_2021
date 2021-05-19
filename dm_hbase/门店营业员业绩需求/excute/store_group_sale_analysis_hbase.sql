/*
--主题描述：门店营业员业绩提成——来团购报表
--存储策略：hive动态映射到hbase,  rowkey='反转(支付日期+门店 202104201U70)''
--调度策略：每天跑近1天数据，任务号1398，依赖执行的调度任务号：209,252,912
--维度    ：天,门店
--业务范围：直营加盟
--作者：zengjiamin
--日期：20210420
 */
--**********************************修改
with  introducer as (
select
     o.order_no
    ,get_json_object(o.ext_param,"$.introducerId")  as introducer_id
from ods.zt_tc_order  o
where date_format(o.payment_time,'yyyy-MM-dd') =date_format(date_add(current_date(),-1),'yyyy-MM-dd')
and   o.dt >= date_format(date_add(current_date(),-10),'yyyy-MM-dd')
and  trade_status in  ('3','5','8','9','-9999','-6')
)

, result as (
select

         date_format(oi.payment_time,'yyyyMMdd')                                          as  pay_date
        ,oi.store_key
        ,ir.introducer_id                                                                 as introducer
        ,oi.order_no
        ,cast(nvl(oi.orgin_amount,0)    as string)                                                       as receive_amt
        ,cast(nvl(oi.actual_amount,0)   as string)                                                       as actual_amt
        ,cast(nvl(oi.discount_amount,0) as string)                                                       as discount_amt
        ,cast(nvl(case when trade_status  = '-6'  then oi.orgin_amount     end ,0) as string)            as return_receive_amt
        ,cast(nvl(case when trade_status  = '-6'  then oi.actual_amount    end ,0) as string)            as return_actual_amt
        ,date_format(oi.payment_time,'yyyy-MM-dd')                  as dt
        ,from_unixtime(unix_timestamp(current_timestamp()) + 28800) as etl_updatetime
from dw.fact_trade_order oi
inner join dw.dim_channel cl on oi.channel_key = cl.channel_key
left  join introducer ir on ir.order_no = oi.order_no
where date_format(oi.payment_time,'yyyy-MM-dd') >= date_format(date_add(current_date(),-1),'yyyy-MM-dd')
and   oi.dt > date_format(date_add(current_date(),-10),'yyyy-MM-dd')
and   trade_status in  ('3','5','8','9','-9999','-6')  -- 扣除退款3，5，8，9 -9999 正向-6逆向
and   cl.channel_source in ('01','04') -- 直营  加盟
and   oi.order_business_type in (0,1,2)  -- 排除虚拟单
and   cl.channel_type = '155'  -- 门店团购
)

insert into  dm.store_group_sale_analysis_hbase
select
      reverse(a.id)  as  rowkey
     ,str_to_map(concat_ws('&',collect_list(str)),'&',':') as str_map
from (
select
  store_key||pay_date   as   id
 ,order_no
 ,concat(  order_no,':'
        ,'{"pay_date":"',pay_date
        ,'","introducer":"',introducer
        ,'","receive_amt":"',receive_amt
        ,'","actual_amt":"',actual_amt
        ,'","discount_amt":"',discount_amt
        ,'","return_receive_amt":"',return_receive_amt
        ,'","return_actual_amt":"',return_actual_amt,'"}'
        ) str
from result
) a
group by a.id;


