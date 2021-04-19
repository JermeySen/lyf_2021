
create table dm.ord_return_store_detail
(
 company_code    	string         comment '公司编码'
,company_name       string         comment '公司名称'
,region_owner       string         comment '片区负责人'
,area_owner   		string         comment '城区负责人'
,store_key      	string         comment '门店编码'
,store_name      	string         comment '门店名称'
,channel_source     string         comment '渠道类型'
,sale_amount    	double         comment '销售额'
,return_amout  	    double     	   comment '退货额'
,return_ordernum    int            comment '退货笔数'
,return_days      	int            comment '退货天数'
,return_ordernum_1  int            comment '退货额[200-500)的笔数'
,return_ordernum_2  int            comment '退货额[500-1000)的笔数'
,return_ordernum_3  int            comment '退货额>=1000的笔数'
,return_warehouse   string         comment '退仓（金额）'
,return_store       string         comment '退格斗（金额)'
,etl_updatetime  	timestamp      comment 'etl_更新时间'
) PARTITIONED by (dt string)


with  return_date as (
select
 s.l2_company_code
,s.l2_company_name
,ro.cn as region_owner
,ao.cn as area_owner
,a.store_key
,s.store_name
,cl.channel_source_name
,sum( abs(a.actual_amount))               as return_amount
,count(distinct  a.order_no||a.store_key  ) as  return_ordernum
,count(distinct a.dt   )                   as  return_days
,count(distinct case when  abs(a.actual_amount) >= 200 and abs(a.actual_amount) < 500  then a.order_no||a.store_key end ) as return_ordernum_1
,count(distinct case when  abs(a.actual_amount) >= 500 and abs(a.actual_amount) < 1000 then a.order_no||a.store_key end ) as return_ordernum_2
,count(distinct case when  abs(a.actual_amount) >= 1000 then a.order_no||a.store_key end )                                as return_ordernum_3
,cast(null as string) as return_warehouse
,cast(null as string) as return_store
,from_unixtime(unix_timestamp(current_timestamp()) + 28800)                        as etl_updatetime
,dt
from  dw.fact_trade_order a
inner join dw.dim_channel cl on a.channel_key = cl.channel_key
inner join dw.dim_store_daily_snapshot s on a.store_key = s.store_key and  s.dt = a.dt
left join (select employee_number,cn from ods.zt_uc_user_employee group by employee_number,cn) ro on ro.employee_number = s.region_owner
left join (select employee_number,cn from ods.zt_uc_user_employee group by employee_number,cn) ao on ao.employee_number = s.area_owner
where a.dt >=  date_format(date_add(current_date(),-60),'yyyy-MM-dd')
and   a.trade_status  = '-6'
and   cl.channel_source in ('01' ,'04')
group by  s.l2_company_code
         ,s.l2_company_name
         ,s.region_owner
         ,ro.cn
         ,s.area_owner
         ,ao.cn
         ,a.store_key
         ,s.store_name
         ,cl.channel_source_name
         ,a.dt
)
, compelete_data  as (
select
 date_format(a.payment_time,'yyyy-MM-dd')			      as dt
,a.store_key
,sum(a.actual_amount) + sum(nvl(a.third_party_amount,0))  as  sale_amount
from  dw.fact_trade_order a
inner join dw.dim_channel cl on a.channel_key = cl.channel_key
where  date_format(a.payment_time,'yyyy-MM-dd') >=  date_format(date_add(current_date(),-60),'yyyy-MM-dd')
and   a.dt >= date_format(date_add(current_date(),-90),'yyyy-MM-dd')
and   a.trade_status in  ('3','5','8','9','-9999','-6')
and   cl.channel_source in ('01' ,'04')
group by
          a.store_key
         , date_format(a.payment_time,'yyyy-MM-dd')
)
insert overwrite table dm.ord_return_store_detail PARTITION  (dt)
select
 rd.l2_company_code
,rd.l2_company_name
,rd.region_owner
,rd.area_owner
,rd.store_key
,rd.store_name
,rd.channel_source_name
,cd.sale_amount
,rd.return_amount
,rd.return_ordernum
,rd.return_days
,rd.return_ordernum_1
,rd.return_ordernum_2
,rd.return_ordernum_3
,rd.return_warehouse
,rd.return_store
,rd.etl_updatetime
,rd.dt
from return_date rd
left  join  compelete_data  cd on rd.store_key = cd.store_key and rd.dt =cd.dt

