 set hive.exec.max.dynamic.partitions=1000;
 set hive.exec.max.dynamic.partitions.pernode=800;
-- 日新增的数据
insert overwrite table dw.fact_user_point_bill partition (dt)
select
     id
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
    ,sequence
    ,reason
    ,status
    ,case when status = 0 then '正常'
          when status = 1 then '撤销'   end as statusname
    ,is_expired
    ,org_code
    ,market_code
    ,scene_code
    ,scene_desc
    ,card_category_id
    ,create_time
    ,update_time
    ,tenant_id
    ,app_id
    ,is_deleted
    ,from_unixtime(unix_timestamp(current_timestamp()) + 28800)  as etl_last_updatetime
    ,'中台'  as etl_system
    ,date_format(create_time,'yyyy-MM-dd') as dt
from ods.zt_mc_point_log lg
where lg.dt = date_format(date_add(current_date(),-1),'yyyy-MM-dd');

--日更新的数据
drop table if exists temp.temp_user_point_bill;
create table temp.temp_user_point_bill as
select
     id
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
    ,sequence
    ,reason
    ,status
    ,case when status = 0 then '正常'
          when status = 1 then '撤销'   end as statusname
    ,is_expired
    ,org_code
    ,market_code
    ,scene_code
    ,scene_desc
    ,card_category_id
    ,create_time
    ,update_time
    ,tenant_id
    ,app_id
    ,is_deleted
    ,from_unixtime(unix_timestamp(current_timestamp()) + 28800)  as etl_last_updatetime
    ,'中台'  as etl_system
    ,date_format(create_time,'yyyy-MM-dd') as dt
from ods.zt_mc_point_log lg
where date_format(lg.update_time,'yyyy-MM-dd') = date_format(date_add(current_date(),-1),'yyyy-MM-dd');
-- 日更新数据覆写
insert overwrite table dw.fact_user_point_bill partition(dt)
select
     CASE when (s1.id is not NULL ) then s1.id	        		else s2.id	       				end as 	id	,
	 CASE when (s1.id is not NULL ) then s1.member_card_id	    else s2.member_card_key	        end as 	member_card_key	,
     CASE when (s1.id is not NULL ) then s1.inner_serial_no	    else s2.inner_serial_no	        end as 	inner_serial_no	,
     CASE when (s1.id is not NULL ) then s1.related_serial_no	else s2.related_serial_no	    end as 	related_serial_no	,
     CASE when (s1.id is not NULL ) then s1.type	            else s2.type	    			end as 	type	,
     CASE when (s1.id is not NULL ) then s1.typename			else s2.typename	   		    end as 	typename	,
     CASE when (s1.id is not NULL ) then s1.origin_point	    else s2.origin_point	        end as 	origin_point	,
     CASE when (s1.id is not NULL ) then s1.affect_point	    else s2.affect_point	        end as 	affect_point	,
     CASE when (s1.id is not NULL ) then s1.effective_point	    else s2.effective_point	        end as 	effective_point	,
     CASE when (s1.id is not NULL ) then s1.serial_no	        else s2.serial_no	        	end as 	serial_no	,
     CASE when (s1.id is not NULL ) then s1.sequence	        else s2.sequence	        	end as 	sequence	,
     CASE when (s1.id is not NULL ) then s1.reason	        	else s2.reason	        		end as 	reason	,
     CASE when (s1.id is not NULL ) then s1.status	        	else s2.status	        		end as 	status	,
     CASE when (s1.id is not NULL ) then s1.statusname	        else s2.statusname	        	end as 	statusname	,
     CASE when (s1.id is not NULL ) then s1.is_expired	        else s2.is_expired	        	end as 	is_expired	,
     CASE when (s1.id is not NULL ) then s1.org_code	        else s2.org_key	        		end as 	org_key	,
     CASE when (s1.id is not NULL ) then s1.market_code	    	else s2.store_key	        	end as 	store_key	,
     CASE when (s1.id is not NULL ) then s1.scene_code			else s2.scene_code	    		end as 	scene_code	,
     CASE when (s1.id is not NULL ) then s1.scene_desc	    	else s2.scene_desc	        	end as 	scene_desc	,
     CASE when (s1.id is not NULL ) then s1.card_category_id	else s2.card_category_id	    end as 	card_category_id	,
     CASE when (s1.id is not NULL ) then s1.create_time			else s2.create_time	    		end as 	create_time	,
     CASE when (s1.id is not NULL ) then s1.update_time			else s2.update_time	    		end as 	update_time	,
     CASE when (s1.id is not NULL ) then s1.tenant_id			else s2.tenant_id	    		end as 	tenant_id	,
     CASE when (s1.id is not NULL ) then s1.app_id				else s2.app_id	    			end as 	app_id	,
     CASE when (s1.id is not NULL ) then s1.is_deleted 			else s2.is_deleted	        	end as 	is_deleted	,
	 from_unixtime(unix_timestamp(current_timestamp()) + 28800) etl_last_updatetime,
     'ZT' etl_system,
     CASE when (s1.id is not NULL ) then s1.dt	        		else s2.dt	        			end as 	dt
 from dw.fact_user_point_bill s2
 left join temp.temp_user_point_bill s1 on s1.id = s2.id
 where s2.dt in (SELECT distinct dt as dt  from temp.temp_user_point_bill);