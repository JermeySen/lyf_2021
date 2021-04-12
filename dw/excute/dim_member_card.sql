/*
--主题描述：会员卡
--存储策略：每月存最后一天月累计数据
--调度策略：T+1每天早上2点左右执行 依赖执行前一天数据 调度任务号：1363，依赖：17,27
--维度    ：会员卡id
--业务范围：
--作者：zengjiamin
--日期：20210408
---------------------------------------------------
*/
set tez.queue.name = dw;
set hive.exec.max.dynamic.partitions=1000;
set hive.exec.max.dynamic.partitions.pernode=400;
insert overwrite table dw.dim_member_card
select
	 mmc.id
	,mmc.member_card_no
    ,mmc.vip_card_no
    ,mmc.card_no
	,mct.code
	,mct.card_template_name
	,mct.member_level
    ,mmc.user_id
    ,mmc.template_id
    ,mmc.old_level
    ,mmc.experience
    ,mmc.point
    ,mmc.valid_start
    ,mmc.valid_end
    ,mmc.active_date
    ,mmc.bind_date
    ,mmc.register_source
    ,mmc.register_terminal
    ,mmc.register_date
    ,mmc.register_ip
    ,mmc.register_address
    ,mmc.register_area_name
    ,mmc.register_area_code
    ,mmc.member_card_status
    ,case mmc.member_card_status when 1 then '注册' when 3 then '激活' else '未知' end
    ,mmc.card_category_id
    ,mmc.is_old
    ,mmc.create_time
    ,mmc.update_time
    ,mmc.is_deleted
    ,mmc.tenant_id
    ,mmc.app_id
    ,mmc.creator
    ,from_unixtime(unix_timestamp(current_timestamp()) + 28800) etl_last_updatetime
    ,'ZT' etl_system
    ,date_format(mmc.create_time,'yyyy-MM-dd') dt
from ods.zt_mc_member_card mmc
left join ods.zt_mc_card_template  mct on mct.id = mmc.old_level
;

---  每天增量
drop table if exists temp.temp_card;
create table temp.temp_card as
select
	 mmc.id
	,mmc.member_card_no
    ,mmc.vip_card_no
    ,mmc.card_no
	,mct.code
	,mct.card_template_name
	,mct.member_level
    ,mmc.user_id
    ,mmc.template_id
    ,mmc.old_level
    ,mmc.experience
    ,mmc.point
    ,mmc.valid_start
    ,mmc.valid_end
    ,mmc.active_date
    ,mmc.bind_date
    ,mmc.register_source
    ,mmc.register_terminal
    ,mmc.register_date
    ,mmc.register_ip
    ,mmc.register_address
    ,mmc.register_area_name
    ,mmc.register_area_code
    ,mmc.member_card_status
    ,case mmc.member_card_status when 1 then '注册' when 3 then '激活' else '未知' end member_card_status_name
    ,mmc.card_category_id
    ,mmc.is_old
    ,mmc.create_time
    ,mmc.update_time
    ,mmc.is_deleted
    ,mmc.tenant_id
    ,mmc.app_id
    ,mmc.creator
    ,from_unixtime(unix_timestamp(current_timestamp()) + 28800) etl_last_updatetime
    ,'ZT' etl_system
    ,date_format(mmc.create_time,'yyyy-MM-dd') dt
from ods.zt_mc_member_card mmc
left join ods.zt_mc_card_template  mct on mct.id = mmc.old_level
where date_format(nvl(mmc.update_time,mmc.create_time),'yyyy-MM-dd') = date_format(date_add(current_date(),-1),'yyyy-MM-dd');

 delete  from dw.dim_member_card  where member_card_key in (select id from temp.temp_card);
 insert into dw.dim_member_card select * from temp.temp_current;

-- insert overwrite table dw.dim_member_card PARTITION(dt)
--   select
--      CASE when (s1.id is not NULL ) then s1.id	        		else s2.member_card_key	        end as 	id	,
-- 	 CASE when (s1.id is not NULL ) then s1.member_card_no	    else s2.member_card_no	        end as 	member_card_no	,
--      CASE when (s1.id is not NULL ) then s1.vip_card_no	        else s2.vip_card_no	        	end as 	vip_card_no	,
--      CASE when (s1.id is not NULL ) then s1.card_no	            else s2.card_no	        	end as 	card_no	,
--      CASE when (s1.id is not NULL ) then s1.code	            else s2.card_template_code	    end as 	card_template_code	,
--      CASE when (s1.id is not NULL ) then s1.card_template_name	else s2.card_template_name	    end as 	card_template_name	,
--      CASE when (s1.id is not NULL ) then s1.member_level	    else s2.member_level	        end as 	member_level	,
--      CASE when (s1.id is not NULL ) then s1.user_id	        	else s2.buyer_key	        	end as 	buyer_key	,
--      CASE when (s1.id is not NULL ) then s1.code	            else s2.template_id	        	end as 	template_id	,
--      CASE when (s1.id is not NULL ) then s1.old_level	        else s2.old_level	        	end as 	old_level	,
--      CASE when (s1.id is not NULL ) then s1.experience	        else s2.experience	        	end as 	experience	,
--      CASE when (s1.id is not NULL ) then s1.point	        	else s2.point	        		end as 	point	,
--      CASE when (s1.id is not NULL ) then s1.valid_start	        else s2.valid_start	        	end as 	valid_start	,
--      CASE when (s1.id is not NULL ) then s1.valid_end	        else s2.valid_end	        	end as 	valid_end	,
--      CASE when (s1.id is not NULL ) then s1.active_date	        else s2.active_date	        	end as 	active_date	,
--      CASE when (s1.id is not NULL ) then s1.bind_date	        else s2.bind_date	        	end as 	bind_date	,
--      CASE when (s1.id is not NULL ) then s1.register_source	    else s2.register_source	        end as 	register_source	,
--      CASE when (s1.id is not NULL ) then s1.register_terminal	else s2.register_terminal	    end as 	register_terminal	,
--      CASE when (s1.id is not NULL ) then s1.register_date	    else s2.register_date	        end as 	register_date	,
--      CASE when (s1.id is not NULL ) then s1.register_ip	        else s2.register_ip	        	end as 	register_ip	,
--      CASE when (s1.id is not NULL ) then s1.register_address	else s2.register_address	    end as 	register_address	,
--      CASE when (s1.id is not NULL ) then s1.register_area_name	else s2.register_area_name	    end as 	register_area_name	,
--      CASE when (s1.id is not NULL ) then s1.register_area_code	else s2.register_area_id	    end as 	register_area_id	,
--      CASE when (s1.id is not NULL ) then s1.member_card_status	else s2.status_id	    		end as 	status_id	,
--      CASE when (s1.id is not NULL ) then s1.member_card_statusid else s2.status_name	        	end as 	status_name	,
--      CASE when (s1.id is not NULL ) then s1.card_category_id	else s2.card_category_id	    end as 	card_category_id	,
--      CASE when (s1.id is not NULL ) then s1.is_old	        	else s2.is_old	        		end as 	is_old	,
--      CASE when (s1.id is not NULL ) then s1.create_time	        else s2.create_time	        	end as 	create_time	,
--      CASE when (s1.id is not NULL ) then s1.update_time	        else s2.update_time	        	end as 	update_time	,
--      CASE when (s1.id is not NULL ) then s1.is_deleted	        else s2.is_deleted	        	end as 	is_deleted	,
--      CASE when (s1.id is not NULL ) then s1.tenant_id	        else s2.tenant_id	        	end as 	tenant_id	,
--      CASE when (s1.id is not NULL ) then s1.app_id	        	else s2.app_id	        		end as 	app_id	,
--      CASE when (s1.id is not NULL ) then s1.creator	        	else s2.creator	        		end as 	creator	,
-- 	 from_unixtime(unix_timestamp(current_timestamp()) + 28800) etl_last_updatetime,
--      'ZT' etl_system,
--      CASE when (s1.id is not NULL ) then s1.dt	        		else s2.dt	        			end as 	dt
--  from dw.dim_member_card s2
--  left join temp.temp_card s1 on s1.id = s2.member_card_key
--  where s2.dt in (SELECT distinct dt as dt  from temp.temp_card);

--

