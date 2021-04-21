/*
--主题描述：门店退货明细
--存储策略：每天重刷60天数据，
--调度策略：T+1每天早上五点左右点执行 依赖执行近60天数据 调度任务号：209,252,1378
--维度    ：门店,天
--业务范围：直营加盟门店
--作者：zengjiamin
--日期：20210406
 */
--**********************************修改
--日期 20210408  zengjiamin  员工工号换成员工名称
with  reverse_order as (
select
     date_format(a.apply_time,'yyyy-MM-dd')                                as dt
    ,shop_code                                                             as store_key
    ,sum(case when b.reverse_destination ='退格斗' then b.actual_amount end) as  return_store
    ,sum(case when b.reverse_destination ='退仓'   then b.actual_amount end) as  return_warehouse
from ods.zt_tc_reverse_order  a
inner join ods.zt_tc_reverse_order_line  b on a.id =  b.reverse_order_id
inner join dw.dim_channel cl               on  a.channel_code||'_'||a.trade_type = cl.channel_key
where a.apply_time >= date_format(date_add(current_date(),-60),'yyyy-MM-dd')
 and cl.channel_source in ('01' ,'04') -- 直营  加盟
 and a.trade_status = '6'
group by shop_code,date_format(a.apply_time,'yyyy-MM-dd')
)

,  return_data  as (
		select
             s.l2_company_code                                                                as company_code
            ,s.l2_company_name                                                                as company_name
			,ro.cn as region_owner
			,ao.cn as area_owner
			,a.store_key
			,s.store_name
            ,cl.channel_source_name                                                            as channel_source
			,sum( abs(a.actual_amount)  )               as return_amount
			,count(distinct a.order_no||a.store_key  ) as  return_ordernum
			,count(distinct a.dt   )                   as  return_days
			,count(distinct case when  abs(a.actual_amount) >= 200 and abs(a.actual_amount) < 500  then a.order_no||a.store_key end ) as return_ordernum_1
			,count(distinct case when  abs(a.actual_amount) >= 500 and abs(a.actual_amount) < 1000 then a.order_no||a.store_key end ) as return_ordernum_2
			,count(distinct case when  abs(a.actual_amount) >= 1000 then a.order_no||a.store_key end )                                as return_ordernum_3
			,from_unixtime(unix_timestamp(current_timestamp()) + 28800)                        as etl_updatetime
			,dt
		from  dw.fact_trade_order a
		inner join dw.dim_channel cl on a.channel_key = cl.channel_key
		inner join dw.dim_store_daily_snapshot s on a.store_key = s.store_key and  s.dt = a.dt
		left join (select employee_number,cn from ods.zt_uc_user_employee group by employee_number,cn) ro on ro.employee_number = s.region_owner
		left join (select employee_number,cn from ods.zt_uc_user_employee group by employee_number,cn) ao on ao.employee_number = s.area_owner
		where a.dt >=  date_format(date_add(current_date(),-60),'yyyy-MM-dd')
		and   a.trade_status = '-6'--in  ('3','5','8','9','-9999','-6') -- 扣除退款3，5，8，9 -9999 正向-6逆向
		and   cl.channel_source in ('01' ,'04') -- 直营  加盟
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
,sum(a.actual_amount) + sum(a.third_party_amount)  as  sale_amount
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
		rd.company_code
		,rd.company_name
		,rd.region_owner
		,rd.area_owner
		,rd.store_key
		,rd.store_name
		,rd.channel_source
		,cd.sale_amount
		,rd.return_amount
		,rd.return_ordernum
		,rd.return_days
		,rd.return_ordernum_1
		,rd.return_ordernum_2
		,rd.return_ordernum_3
		,ro.return_warehouse
		,ro.return_store
		,from_unixtime(unix_timestamp(current_timestamp()) + 28800)                        as etl_updatetime
		,rd.dt
from return_data rd
left join compelete_data   on rd.store_key = cd.store_key and rd.dt = cd.dt
left join reverse_order ro on rd.store_key = ro.store_key and rd.dt = ro.dt
;
--
-- select
--  s.l2_company_code
-- ,s.l2_company_name
-- ,ro.cn as region_owner
-- ,ao.cn as area_owner
-- ,a.store_key
-- ,s.store_name
-- ,cl.channel_source_name
-- ,sum(a.actual_amount) + sum(nvl(a.third_party_amount,0))                           as  sale_amount
-- ,sum(case when a.trade_status = '-6' then abs(a.actual_amount) end )               as return_amount
-- ,count(distinct case when a.trade_status = '-6' then a.order_no||a.store_key end ) as  return_ordernum
-- ,count(distinct case when a.trade_status = '-6' then a.dt  end )                   as  return_days
-- ,count(distinct case when a.trade_status = '-6' and abs(a.actual_amount) >= 200 and abs(a.actual_amount) < 500  then a.order_no||a.store_key end ) as return_ordernum_1
-- ,count(distinct case when a.trade_status = '-6' and abs(a.actual_amount) >= 500 and abs(a.actual_amount) < 1000 then a.order_no||a.store_key end ) as return_ordernum_2
-- ,count(distinct case when a.trade_status = '-6' and abs(a.actual_amount) >= 1000 then a.order_no||a.store_key end )                                as return_ordernum_3
-- ,null as return_warehouse
-- ,null as return_store
-- ,from_unixtime(unix_timestamp(current_timestamp()) + 28800)                        as etl_updatetime
-- ,dt
-- from  dw.fact_trade_order a
-- inner join dw.dim_channel cl on a.channel_key = cl.channel_key
-- inner join dw.dim_store_daily_snapshot s on a.store_key = s.store_key and  s.dt = a.dt
-- left join (select employee_number,cn from ods.zt_uc_user_employee group by employee_number,cn) ro on ro.employee_number = s.region_owner
-- left join (select employee_number,cn from ods.zt_uc_user_employee group by employee_number,cn) ao on ao.employee_number = s.area_owner
-- where a.dt >=  date_format(date_add(current_date(),-60),'yyyy-MM-dd')
-- and   a.trade_status in  ('3','5','8','9','-9999','-6') -- 扣除退款3，5，8，9 -9999 正向-6逆向
-- and   cl.channel_source in ('01' ,'04') -- 直营  加盟
-- group by  s.l2_company_code
--          ,s.l2_company_name
--          ,s.region_owner
--          ,ro.cn
--          ,s.area_owner
--          ,ao.cn
--          ,a.store_key
--          ,s.store_name
--          ,cl.channel_source_name
--          ,a.dt;
--*****************************************************************************
--  城区级数据
select
     d.dt            as `日期`
    ,d.company_name  as `子公司`
    ,d.region_owner  as `片区负责人`
    ,d.area_owner    as `城区负责人`
    ,count(distinct d.store_key) as `总门店数`
    ,sum(d.sale_amount)          as `销售额`
    ,sum(d.return_amout)         as `退货额`
    ,sum(d.return_ordernum)      as `退货笔数`
    ,sum(d.return_amout) / sum(d.sale_amount)   as `退货额占比`

    ,count(distinct case when d.return_amout >=200 and d.return_amout<500 then d.store_key  end)                                `门店数[200-500)`
    ,count(distinct case when d.return_amout >=200 and d.return_amout<500 then d.store_key  end) / count(distinct d.store_key)  `门店占比[200-500)`
    ,count(distinct case when d.return_amout >=500 and d.return_amout<1000 then d.store_key end)                                `门店数[500-1000)`
    ,count(distinct case when d.return_amout >=500 and d.return_amout<1000 then d.store_key end) / count(distinct d.store_key)  `门店占比[500-1000)`
    ,count(distinct case when d.return_amout >=1000  then d.store_key end)                                                      `门店数>=1000`
    ,count(distinct case when d.return_amout >=1000  then d.store_key end) / count(distinct d.store_key)                        `门店占比>=1000`
    ,count(distinct case when d.return_ordernum >4  then d.store_key end)                                                       `门店数大于4笔`
    ,count(distinct case when d.return_ordernum >4  then d.store_key end) / count(distinct d.store_key)                         `门店占比`
from dm.ord_return_store_detail d
group by d.dt,d.company_name,d.region_owner,d.area_owner
--片区级数据
select
     d.dt            as `日期`
    ,d.company_name  as `子公司`
    ,d.region_owner  as `片区负责人`
    ,count(distinct d.store_key) as `总门店数`
    ,sum(d.sale_amount)          as `销售额`
    ,sum(d.return_amout)         as `退货额`
    ,sum(d.return_ordernum)      as `退货笔数`
    ,sum(d.return_amout) / sum(d.sale_amount)   as `退货额占比`

    ,count(distinct case when d.return_amout >=200 and d.return_amout<500 then d.store_key  end)                                `门店数[200-500)`
    ,count(distinct case when d.return_amout >=200 and d.return_amout<500 then d.store_key  end) / count(distinct d.store_key)  `门店占比[200-500)`
    ,count(distinct case when d.return_amout >=500 and d.return_amout<1000 then d.store_key end)                                `门店数[500-1000)`
    ,count(distinct case when d.return_amout >=500 and d.return_amout<1000 then d.store_key end) / count(distinct d.store_key)  `门店占比[500-1000)`
    ,count(distinct case when d.return_amout >=1000  then d.store_key end)                                                      `门店数>=1000`
    ,count(distinct case when d.return_amout >=1000  then d.store_key end) / count(distinct d.store_key)                        `门店占比>=1000`
    ,count(distinct case when d.return_ordernum >4  then d.store_key end)                                                       `门店数大于4笔`
    ,count(distinct case when d.return_ordernum >4  then d.store_key end) / count(distinct d.store_key)                         `门店占比`
from dm.ord_return_store_detail d
group by d.dt,d.company_name,d.region_owner

-- 子公司级数据
select
     d.dt            as `日期`
    ,d.company_name  as `子公司`
    ,count(distinct d.store_key) as `总门店数`
    ,sum(d.sale_amount)          as `销售额`
    ,sum(d.return_amout)         as `退货额`
    ,sum(d.return_ordernum)      as `退货笔数`
    ,sum(d.return_amout) / sum(d.sale_amount)   as `退货额占比`
    ,count(distinct case when d.return_amout >=200 and d.return_amout<500 then d.store_key  end)                                `门店数[200-500)`
    ,count(distinct case when d.return_amout >=200 and d.return_amout<500 then d.store_key  end) / count(distinct d.store_key)  `门店占比[200-500)`
    ,count(distinct case when d.return_amout >=500 and d.return_amout<1000 then d.store_key end)                                `门店数[500-1000)`
    ,count(distinct case when d.return_amout >=500 and d.return_amout<1000 then d.store_key end) / count(distinct d.store_key)  `门店占比[500-1000)`
    ,count(distinct case when d.return_amout >=1000  then d.store_key end)                                                      `门店数>=1000`
    ,count(distinct case when d.return_amout >=1000  then d.store_key end) / count(distinct d.store_key)                        `门店占比>=1000`
    ,count(distinct case when d.return_ordernum >4  then d.store_key end)                                                       `门店数大于4笔`
    ,count(distinct case when d.return_ordernum >4  then d.store_key end) / count(distinct d.store_key)                         `门店占比`
from dm.ord_return_store_detail d
group by d.dt,d.company_name
--门店级数据
select
 dt              as `日期`
,company_name    as `子公司`
,region_owner    as `片区负责人`
,area_owner   	 as `城区负责人`
,store_key       as `门店编码`
,store_name      as  `门店名称`
,sale_amount     as  `销售额`
,return_amout  	 as  `退货金额`
,return_ordernum as  `退货笔数`
,return_days     as  `退货天数`
,return_ordernum_1  as `退货额[200-500)的笔数`
,return_ordernum_2  as `退货额[200-500)的笔数`
,return_ordernum_3  as `退货额[200-500)的笔数`
,return_warehouse   as `退仓（金额）`
,return_store       as `退格斗（金额）`
from dm.ord_return_store_detail

-- 门店退货明细
select
 dt                 as `日期`
,company_name       as `子公司`
,region_owner       as `片区负责人`
,area_owner   	    as `城区负责人`
,store_key          as `门店编码`
,store_name         as  `门店名称`
,creator    	    as  `操作营业员工号`
,order_no  		  	as `退货流水号`
,return_time        as `退货日期（日时分秒）`
,sku_key      		as `退货商品SKU编码`
,sku_name  		 	as `退货商品名称`
,return_num      	as `数量`
,sales_unit      	as `数量单位`
,return_amount    	as `退货额`
,apply_reason  		as `退货原因`
,apply_reason_id    as `退货原因id`
,return_direction   as `退货去向`
from dm.ord_return_sku_detail

-- 退货原因

select
 dt                 as `日期`
,company_name       as `子公司`
,region_owner       as `片区负责人`
,area_owner   	    as `城区负责人`
,apply_reason  		as `退货原因`
,sum(return_amount) as `退货额`
from dm.ord_return_sku_detail
group by dt,company_code,company_name,region_owner,area_owner,apply_reason_id,apply_reason
