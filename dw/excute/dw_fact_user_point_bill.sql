 /*
--主题描述：积分模型
--存储策略：每天增量
--调度策略：T+1每天早上2左右点执行 依赖执行前一天增量数据 调度任务号：1364
--维度    ：会员，门店，组织，渠道
--业务范围：会员积分增减
--作者：zengjiamin
--日期：20210408
---------------------------------------------------修改
日期 20210408  zengjiamin  新增日期和渠道维度。新增积分的流水才会有渠道，扣减的流水默认-9999
*/
 set hive.exec.max.dynamic.partitions=1000;
 set hive.exec.max.dynamic.partitions.pernode=800;

-- 日新增的数据
insert overwrite table dw.fact_user_point_bill partition (dt)
select
     id
    ,date_format(lg.create_time,'yyyyMMdd')   as date_key
    ,nvl(o.channel_key,'-9999')            as channel_key
    ,org_code
    ,market_code
    ,member_card_id
    ,inner_serial_no
    ,related_serial_no
    ,type
    ,case when type = 0 then '扣减积分'
          when type = 1 then '增加积分' end as typename
    ,origin_point
    ,affect_point
    ,effective_point
    ,serial_no
    ,status
    ,case when status = 0 then '正常'
          when status = 1 then '撤销'   end as statusname
    ,is_expired
    ,scene_code
    ,scene_desc
    ,lg.create_time
    ,lg.update_time
    ,from_unixtime(unix_timestamp(current_timestamp()) + 28800)  as etl_last_updatetime
    ,'ZT'  as etl_system
    ,date_format(lg.create_time,'yyyy-MM-dd') as dt
from ods.zt_mc_point_log lg
left join dw.fact_trade_order o on lg.serial_no = o.order_no and o.dt = date_format(date_add(current_date(),-1),'yyyy-MM-dd')
where lg.dt = date_format(date_add(current_date(),-1),'yyyy-MM-dd');

--日更新的数据
drop table if exists temp.temp_user_point_bill;
create table temp.temp_user_point_bill as
select
     id
    ,date_format(lg.create_time,'yyyyMMdd') as date_key
    ,nvl(o.channel_key,'-9999')          as channel_key
    ,org_code
    ,market_code
    ,member_card_id
    ,inner_serial_no
    ,related_serial_no
    ,type
    ,case when type = 0 then '扣减积分'
          when type = 1 then '增加积分' end as typename
    ,origin_point
    ,affect_point
    ,effective_point
    ,serial_no
    ,status
    ,case when status = 0 then '正常'
          when status = 1 then '撤销'   end as statusname
    ,is_expired
    ,scene_code
    ,scene_desc
    ,lg.create_time
    ,lg.update_time
    ,from_unixtime(unix_timestamp(current_timestamp()) + 28800)  as etl_last_updatetime
    ,'ZT'  as etl_system
    ,date_format(lg.create_time,'yyyy-MM-dd') as dt
from stage.zt_mc_point_log lg
left join dw.fact_trade_order o on lg.serial_no = o.order_no and o.dt = date_format(lg.create_time,'yyyy-MM-dd')
where lg.is_deleted = 0;
-- 日更新数据覆写
insert overwrite table dw.fact_user_point_bill partition(dt)
select
     CASE when (s1.id is not NULL ) then s1.id	        		else s2.id	       				end as 	id	,
	 CASE when (s1.id is not NULL ) then s1.date_key	        else s2.date_key	            end as 	date_key	,
	 CASE when (s1.id is not NULL ) then s1.channel_key	        else s2.channel_key	            end as 	channel_key	,
	 CASE when (s1.id is not NULL ) then s1.org_code	        else s2.org_key	                end as 	org_key	,
	 CASE when (s1.id is not NULL ) then s1.market_code	        else s2.store_key	            end as 	store_key	,
	 CASE when (s1.id is not NULL ) then s1.member_card_id	    else s2.member_card_key	        end as 	member_card_key	,
     CASE when (s1.id is not NULL ) then s1.inner_serial_no	    else s2.inner_serial_no	        end as 	inner_serial_no	,
     CASE when (s1.id is not NULL ) then s1.related_serial_no	else s2.related_serial_no	    end as 	related_serial_no	,
     CASE when (s1.id is not NULL ) then s1.type	            else s2.type	    			end as 	type	,
     CASE when (s1.id is not NULL ) then s1.typename			else s2.typename	   		    end as 	typename	,
     CASE when (s1.id is not NULL ) then s1.origin_point	    else s2.origin_point	        end as 	origin_point	,
     CASE when (s1.id is not NULL ) then s1.affect_point	    else s2.affect_point	        end as 	affect_point	,
     CASE when (s1.id is not NULL ) then s1.effective_point	    else s2.effective_point	        end as 	effective_point	,
     CASE when (s1.id is not NULL ) then s1.serial_no	        else s2.serial_no	        	end as 	serial_no	,
     CASE when (s1.id is not NULL ) then s1.status	        	else s2.status	        		end as 	status	,
     CASE when (s1.id is not NULL ) then s1.statusname	        else s2.statusname	        	end as 	statusname	,
     CASE when (s1.id is not NULL ) then s1.is_expired	        else s2.is_expired	        	end as 	is_expired	,
     CASE when (s1.id is not NULL ) then s1.scene_code			else s2.scene_code	    		end as 	scene_code	,
     CASE when (s1.id is not NULL ) then s1.scene_desc	    	else s2.scene_desc	        	end as 	scene_desc	,
     CASE when (s1.id is not NULL ) then s1.create_time			else s2.create_time	    		end as 	create_time	,
     CASE when (s1.id is not NULL ) then s1.update_time			else s2.update_time	    		end as 	update_time	,
	 from_unixtime(unix_timestamp(current_timestamp()) + 28800) etl_last_updatetime,
     'ZT' etl_system,
     CASE when (s1.id is not NULL ) then s1.dt	        		else s2.dt	        			end as 	dt
 from dw.fact_user_point_bill s2
 left join temp.temp_user_point_bill s1 on s1.id = s2.id
 where s2.dt in (SELECT distinct dt as dt  from temp.temp_user_point_bill);
