/**
--主题描述：大屏—供应商
--数据探查：保留近30天，每天360条左右
--调度策略：T+1每天早上2点多执行， 依赖执行前一天数据，执行时间2分钟 调度任务号：1320  同步任务号号：1324
--作者：zengjiamin
--日期：20210129
--表依赖：ods.kp_scm_po ，ods.kp_scm_po_detail，temp.ml_sku_x_28days_abcd_level，ods.kp_scm_pa，ods.kp_scm_pa_detail，ods.scm_quality_record，dw.dim_sku
--备注:因hive同步mysql 必须给默认值，所以如果默认-9999 代表null，接口判断不显示。
**/
drop table if exists temp.supply_result;
-- 创建查询结果表临时
create table temp.supply_result as
-- 订单完成率：  根据送达日期   实际数据/供应商确认数量         一个供应商一个月出一个完成率，每个月的完成率=avg(供应商完成率)
with order_complete as (

     select
            date_format(po.arrival_date,'yyyyMM')     as  date_month
           ,nvl(sl.sku_x_sale_level,'D')               as  supply_level
           ,po.supplier_code
     ,sum(pol.received_qty  )/sum(pol.confirm_qty ) as  order_complete_rate
     from ods.kp_scm_po po
     inner join ods.kp_scm_po_detail pol on po.order_no = pol.purchase_order_no
     left join (
                select
                      sku_key
                     ,sku_x_sale_level
                from  temp.ml_sku_x_28days_abcd_level
                where dim_id = 1  -- 全渠道
          ) sl   on pol.sku_code = sl.sku_key
 where 1 = 1
 and  date_format(po.arrival_date,'yyyyMM') between date_format(add_months(date_add(current_date(),-1),-11),'yyyyMM') and date_format(date_add(current_date(),-1),'yyyyMM')
 and po.sku_type = 'Z001'  -- 食品
 and po.is_available = 1 and po.is_deleted = 0
 and pol.is_available = 1 and pol.is_deleted = 0
 group by date_format(po.arrival_date,'yyyyMM') ,nvl(sl.sku_x_sale_level,'D'),po.supplier_code

 )



 --订单及时率
 , order_intime as (

     select
         date_format(pa.appointment_timestamp,'yyyy-MM-dd')   as  date_day
        ,nvl(sl.sku_x_sale_level,'D')                         as  supply_level
        ,count(distinct pa.purchase_entry_no)                 as  appointment_order_count
        ,count(distinct case when date_format(pa.appointment_timestamp,'yyyy-MM-dd') = date_format(pa.completion_time,'yyyy-MM-dd') then  pa.purchase_entry_no end)  as  completion_order_count-- 预约入库时间在当天，并且当天实际入库的入库单
     from   ods.kp_scm_pa  pa
     inner join ods.kp_scm_pa_detail  pal on pa.appointment_no = pal.appointment_no
     left join (
                select
                      sku_key
                     ,sku_x_sale_level
                from  temp.ml_sku_x_28days_abcd_level
                where dim_id = 1  -- 全渠道
               ) sl   on pal.sku_code = sl.sku_key
     where  1 = 1
     and  date_format(pa.appointment_timestamp,'yyyyMM') between date_format(add_months(date_add(current_date(),-1),-11),'yyyyMM') and date_format(date_add(current_date(),-1),'yyyyMM')
     and pa.is_deleted = 0
     and pa.is_available = 1
     and pa.sku_type = 'Z001'  -- 食品
     group by date_format(pa.appointment_timestamp,'yyyy-MM-dd')
             ,nvl(sl.sku_x_sale_level,'D')


)

---采购额top供应商排名
, supplier_rank as (
select
     cast(date_format(date_add(current_date(),-1),'yyyyMMdd') as int) as date_key
    ,po.supplier_code
    ,po.supplier_name                  as supply_name
    ,sku.category_three_name           as sec_category
    ,sum(received_qty * vat_inclusive) as purchase_amount
    ,rank()over(order by sum(received_qty * vat_inclusive) desc)  as purchase_amount_rank
from ods.kp_scm_po po
inner join  ods.kp_scm_po_detail pol on po.order_no = pol.purchase_order_no
inner join dw.dim_sku  sku on pol.sku_code = sku.sku_key
where 1 = 1
and date_format(po.arrival_date,'yyyyMM') between date_format(add_months(date_add(current_date(),-1),-11),'yyyyMM') and date_format(date_add(current_date(),-1),'yyyyMM')
and po.is_available = 1
and   po.is_deleted = 0
and po.sku_type = 'Z001'  -- 食品
group by po.supplier_code,po.supplier_name,sku.category_three_name
)

--入库批次合格率
, in_stock_standard as (
 select
       cast(date_format(date_add(current_date(),-1),'yyyyMMdd') as int) as date_key
      ,date_format(qd.receipt_date,'yyyyMM')                            as  date_month
      ,count(distinct case when freeze_qty = 0 then inspection_code end) / count(distinct inspection_code) as in_stock_standard_rate
 from ods.scm_quality_record qd
 inner join dw.dim_sku sku on sku.sku_key = qd.sku_code  and sku.sku_type_id = '1' -- 食品
 where date_format(qd.receipt_date,'yyyyMM') between date_format(add_months(date_add(current_date(),-1),-11),'yyyyMM') and date_format(date_add(current_date(),-1),'yyyyMM')
 and   qd.is_available  = 1
 and   qd.is_deleted  = 0
 group by date_format(qd.receipt_date,'yyyyMM')
 )



select
     date_key
    ,date_month
    ,supply_level
    ,order_complete_rate
    ,cast(null as decimal(10,4)) as order_intime_rate
    ,cast(null as string) supply_name
    ,cast(null as string) sec_category
    ,cast(null as decimal(20,6)) purchase_amount
    ,cast(null as int) purchase_amount_rank
    ,cast(null as decimal(10,4)) in_stock_standard_rate
    ,1    as module_tag
    ,'订单完成率' as module_tag_name
from (
	select
		 cast(date_format(date_add(current_date(),-1),'yyyyMMdd') as int) as date_key
		,a.date_month
		,a.supply_level
		,avg(a.order_complete_rate)  order_complete_rate
	from order_complete a
	group by a.date_month,a.supply_level
    )  level_complete_rate

union all
select
     date_key
    ,date_month
    ,supply_level
    ,null as order_complete_rate
    ,order_intime_rate
    ,null as supply_name
    ,null as sec_category
    ,null as purchase_amount
    ,null as purchase_amount_rank
    ,null as in_stock_standard_rate
    ,2    as module_tag
    ,'订单及时率' as module_tag_name
from (
     select
		cast(date_format(date_add(current_date(),-1),'yyyyMMdd') as int) as date_key
		,date_format(a.date_day,'yyyyMM')                           as date_month
		,a.supply_level
		,avg(a.completion_order_count / a.appointment_order_count)  as order_intime_rate
     from order_intime a
     group by date_format(a.date_day,'yyyyMM'),a.supply_level
    ) level_order_intime

union all
select
     date_key
    ,date_month
    ,null as supply_level
    ,null as order_complete_rate
    ,null as order_intime_rate
    ,null as supply_name
    ,null as sec_category
    ,null as purchase_amount
    ,null as purchase_amount_rank
    ,in_stock_standard_rate
    ,3    as module_tag
    ,'入库批次合格率' as module_tag_name
from in_stock_standard

union all
select
     date_key
    ,null as date_month
    ,null as supply_level
    ,null as order_complete_rate
    ,null as order_intime_rate
    ,supply_name as supply_name
    ,sec_category as sec_category
    ,purchase_amount as purchase_amount
    ,purchase_amount_rank as purchase_amount_rank
    ,null as in_stock_standard_rate
    ,4    as module_tag
    ,'供应商排名' as module_tag_name
from supplier_rank

union all
select
     date_key
    ,date_month
    ,null as supply_level
    ,order_complete_rate
    ,cast(null as decimal(10,4)) as order_intime_rate
    ,cast(null as string) supply_name
    ,cast(null as string) sec_category
    ,cast(null as decimal(20,6)) purchase_amount
    ,cast(null as int) purchase_amount_rank
    ,cast(null as decimal(10,4)) in_stock_standard_rate
    ,9    as module_tag
    ,'总订单完成率' as module_tag_name
from (
	select
		 cast(date_format(date_add(current_date(),-1),'yyyyMMdd') as int) as date_key
		,a.date_month
		,avg(a.order_complete_rate)  order_complete_rate
	from order_complete a
	where a.date_month = date_format(date_add(current_date(),-1),'yyyyMM')
	group by a.date_month
    )  all_complete_rate

union all
select
     date_key
    ,date_month
    ,null as supply_level
    ,null as order_complete_rate
    ,order_intime_rate
    ,null as supply_name
    ,null as sec_category
    ,null as purchase_amount
    ,null as purchase_amount_rank
    ,null as in_stock_standard_rate
    ,10    as module_tag
    ,'总订单及时率' as module_tag_name
from (
     select
		 cast(date_format(date_add(current_date(),-1),'yyyyMMdd') as int) as date_key
		,date_format(a.date_day,'yyyyMM')                           as date_month
		,avg(a.completion_order_count / a.appointment_order_count)  as order_intime_rate
     from order_intime a
	 where date_format(a.date_day,'yyyyMM')  = date_format(date_add(current_date(),-1),'yyyyMM')
     group by date_format(a.date_day,'yyyyMM')
    )  all_order_intime
;

--重跑数据 删除当日
delete from dm.supplier_analysis_bigscreen
where date_key = cast(date_format(date_add(current_date(),-1),'yyyyMMdd') as int);
-- 插入当日数据
insert into  dm.supplier_analysis_bigscreen
select * from temp.supply_result;

--插入到存储格式为row format delimited fields terminated by '\u0001'，stored as TEXTFILE;
truncate table temp.supplier_analysis_bigscreen;

insert overwrite table temp.supplier_analysis_bigscreen
select
 date_key
,nvl(date_month, ' ')
,nvl(supply_level,' ' )
,nvl(order_complete_rate ,0 )
,nvl(order_intime_rate,0 )
,nvl(supply_name,' ' )
,nvl(sec_category  ,' ' )
,nvl(purchase_amount ,0 )
,nvl(purchase_amount_rank  ,0)
,nvl(in_stock_standard_rate ,0)
,module_tag
,module_tag_name
from dm.supplier_analysis_bigscreen
where date_key = cast(date_format(date_add(current_date(),-1),'yyyyMMdd') as int);




