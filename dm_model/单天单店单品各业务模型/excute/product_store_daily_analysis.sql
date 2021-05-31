/*
--主题描述：单天单店单品（分业务类型）
--存储策略：按天分区，
--调度策略：T+1每天早上八点30执行 ，任务号1408，依赖执行的调度任务号：209,252,912,1378,1116,994
--维度    ：sku，业务类型,天，门店
--业务范围：直营加盟门店,
--作者：zengjiamin
--日期：20210508
 */
--app外卖取线上金额，销量 单位取线下。
--left  join  dw.dim_sku_special_sort st on st.sku_key = oi.sku_key and st.work_type_id = '1'
--inner join dw.dim_sku sku    on sku.sku_key    = oi.sku_key
--社区团：实收对应线上，应收线下
drop table if exists temp.community_data;
drop table if exists temp.direct_join_data;
drop table if exists temp.app_data;
drop table if exists temp.onlive_data;
drop table if exists temp.sale_sku ;

create table temp.community_data as
        select
				 oi.store_key
				,'9100'     as channel_type
				,'拼团到店' as channel_type_name
				,oi.sku_key
				,oi.sales_unit
				,oi.jc_unit
				,oi.is_gift
				,date_format(oi.payment_time,'yyyyMMdd')                                                  as pay_date
				,0.00 as sales_amt_no_discount
	            ,0.00 as sales_amt
	            ,0.00 as sales_amt_discount
	            ,0.00 as sales_amt_refund
	            ,0.00 as sales_amt_no_discount_refund
				,abs(nvl(sum( case when trade_status in ('3','5','8','9','-9999')  then oi.jc_sku_quantity end),0.00))   as jc_sale_sku_qty
				,abs(nvl(sum( case when trade_status   = '-6'  then oi.jc_sku_quantity end),0.00))                       as jc_sale_sku_r_qty
				,abs(nvl(sum( case when trade_status in ('3','5','8','9','-9999')  then oi.sku_quantity end),0.00))     as xs_sale_sku_qty
				,abs(nvl(sum( case when trade_status  ='-6' then oi.sku_quantity end) ,0.00))                           as xs_sale_sku_r_qty
				,count(distinct case when trade_status in ('3','5','8','9','-9999')  then oi.order_store_no end )  as sales_ord_cnt
				,count(distinct case when trade_status   = '-6'  then oi.order_store_no end )                      as sales_ord_cnt_refund
		--  新增  渠道，补贴金额，应收金额
				,cl.channel_source
				,cl.channel_source_name
                ,0.00 as sales_amt_receive
				,date_format(oi.payment_time,'yyyy-MM-dd')                                                         as dt
		from dw.fact_trade_order_item oi
		inner join dw.dim_channel cl on oi.channel_key = cl.channel_key
		where date_format(oi.payment_time,'yyyy-MM-dd') >= date_format(date_add(current_date(),-1),'yyyy-MM-dd')
		and   oi.dt >= date_format(date_add(current_date(),-10),'yyyy-MM-dd')
		and   trade_status in  ('3','5','8','9','-9999','-6')  -- 扣除退款3，5，8，9 -9999 正向-6逆向
		and   cl.channel_source in ('01','04') -- 直营 , 加盟
		and   oi.order_business_type in (0,1,2)  -- 排除虚拟单
-- 		and   oi.is_community_corps = 1  -- 社团核销
	    and oi.trade_type='4'  and oi.channel_key like 'IF01_115%'--拼团到店
		group by date_format(oi.payment_time,'yyyyMMdd')
				,oi.store_key
				,cl.channel_source
				,cl.channel_source_name
				,oi.sku_key
				,oi.sales_unit
				,oi.jc_unit
				,oi.is_gift
				,date_format(oi.payment_time,'yyyy-MM-dd');

create table temp.direct_join_data as
select
         oi.store_key
        , cl.channel_type
        , cl.channel_type_name
        ,oi.sku_key
        ,oi.sales_unit
        ,oi.jc_unit
        ,oi.is_gift
        ,date_format(oi.payment_time,'yyyyMMdd')                                                  as pay_date
        ,abs(nvl(sum(oi.price * oi.sku_quantity),0.00))                                                           as sales_amt_no_discount
        ,abs(nvl(sum(actual_amount),0.00))                                                                        as sales_amt
        ,abs(nvl(sum(oi.discount_amout),0.00))                                                                    as sales_amt_discount
        ,abs(nvl(sum(case when trade_status  = '-6'  then oi.price * oi.sku_quantity end),0.00))                  as sales_amt_refund
        ,abs(nvl(sum(case when trade_status  = '-6'  then oi.actual_amount end),0.00))                            as sales_amt_no_discount_refund
        ,abs(nvl(sum( case when trade_status in ('3','5','8','9','-9999')  then oi.jc_sku_quantity end),0.00))    as jc_sale_sku_qty
        ,abs(nvl(sum( case when trade_status   = '-6'  then oi.jc_sku_quantity end),0.00))                        as jc_sale_sku_r_qty
        ,abs(nvl(sum( case when trade_status in ('3','5','8','9','-9999')  then oi.sku_quantity end),0.00))       as xs_sale_sku_qty
        ,abs(nvl(sum( case when trade_status  ='-6' then oi.sku_quantity end),0.00))                              as xs_sale_sku_r_qty
        ,count(distinct case when trade_status in ('3','5','8','9','-9999')  then oi.order_store_no end )  as sales_ord_cnt
        ,count(distinct case when trade_status   = '-6'  then oi.order_store_no end )                      as sales_ord_cnt_refund
--  新增  渠道，补贴金额，应收金额
        ,cl.channel_source
        ,cl.channel_source_name
        ,sum( case when trade_status in ('3','5','8','9','-9999')  then oi.actual_amount else 0.00 end)    as sales_amt_receive
        ,date_format(oi.payment_time,'yyyy-MM-dd')                                                         as dt
from dw.fact_trade_order_item oi
inner join dw.dim_channel cl on oi.channel_key = cl.channel_key
where date_format(oi.payment_time,'yyyy-MM-dd') >= date_format(date_add(current_date(),-1),'yyyy-MM-dd')
and   oi.dt >= date_format(date_add(current_date(),-10),'yyyy-MM-dd')
and   trade_status in  ('3','5','8','9','-9999','-6')  -- 扣除退款3，5，8，9 -9999 正向-6逆向
and   cl.channel_source in ('01','04') -- 直营 , 加盟
and   oi.order_business_type in (0,1,2)  -- 排除虚拟单
and   cl.channel_type <> '102'    -- 排除app外卖
and   oi.is_community_corps != 1  -- 剔除社团核销
group by date_format(oi.payment_time,'yyyyMMdd')
        ,oi.store_key
        ,cl.channel_source
        ,cl.channel_source_name
        ,cl.channel_type
        ,cl.channel_type_name
        ,oi.sku_key
        ,oi.sales_unit
        ,oi.jc_unit
        ,oi.is_gift
        ,date_format(oi.payment_time,'yyyy-MM-dd')
-- ***************************************************sku'QT0001' 补贴金额
union all
select
          o.store_key
		, cl.channel_type
        , cl.channel_type_name
        ,'QT0001'             as sku_key
        ,cast(null as string) as sales_unit
        ,cast(null as string) as jc_unit
        ,'2'                    as is_gift
        ,date_format(o.payment_time,'yyyyMMdd')   as pay_date
        ,0.00                                     as sales_amt_no_discount
        ,third_party_amount                       as sales_amt
        ,0.00                                     as sales_amt_discount
        ,0.00                 				      as sales_amt_refund
		,0.00									  as sales_amt_no_discount_refund
        ,0.00									  as jc_sale_sku_qty
        ,0.00 									  as jc_sale_sku_r_qty
        ,0.00									  as xs_sale_sku_qty
        ,0.00									  as xs_sale_sku_r_qty
        ,0										  as sales_ord_cnt
        ,0										  as sales_ord_cnt_refund
        ,cl.channel_source
        ,cl.channel_source_name
        ,0.00									  as sales_amt_receive
        ,date_format(o.payment_time,'yyyy-MM-dd') as dt
from dw.fact_trade_order o
inner join dw.dim_channel cl on o.channel_key = cl.channel_key
where date_format(o.payment_time,'yyyy-MM-dd') >= date_format(date_add(current_date(),-1),'yyyy-MM-dd')
and   o.dt >= date_format(date_add(current_date(),-10),'yyyy-MM-dd')
and   trade_status in  ('3','5','8','9','-9999','-6')  -- 扣除退款3，5，8，9 -9999 正向-6逆向
and   cl.channel_source in ('01','04') -- 直营 , 加盟
and   o.order_business_type in (0,1,2)  -- 排除虚拟单
and   o.third_party_amount > 0;


 -- app外卖  金额取线上 ，数量， 单位取线下。
create table temp.app_data as
select
	    off_line.store_key
       ,off_line.channel_type
       ,off_line.channel_type_name
       ,off_line.sku_key
       ,off_line.sales_unit
       ,off_line.jc_unit
       ,off_line.is_gift
       ,off_line.pay_date
	   ,on_line.sales_amt_no_discount
	   ,on_line.sales_amt
	   ,on_line.sales_amt_discount
	   ,on_line.sales_amt_refund
	   ,on_line.sales_amt_no_discount_refund
	   ,off_line.jc_sale_sku_qty
	   ,off_line.jc_sale_sku_r_qty
	   ,off_line.xs_sale_sku_qty
	   ,off_line.xs_sale_sku_r_qty
	   ,off_line.sales_ord_cnt
	   ,off_line.sales_ord_cnt_refund
-- 新增 渠道，应收额
       ,off_line.channel_source
       ,off_line.channel_source_name
       ,on_line.sales_amt_receive
	   ,off_line.dt
from(  -- app外卖线下数量  单位  订单数
	select
         oi.store_key
		,date_format(oi.payment_time,'yyyy-MM-dd')                                                as dt
		,cl.channel_source
        ,cl.channel_source_name
        ,cl.channel_type
        ,cl.channel_type_name
        ,oi.sku_key
        ,oi.sales_unit
        ,oi.jc_unit
        ,oi.is_gift
        ,date_format(oi.payment_time,'yyyyMMdd')                                                  as pay_date
        ,abs(nvl(sum( case when trade_status in ('3','5','8','9','-9999')  then oi.jc_sku_quantity end),0.00))   as jc_sale_sku_qty
        ,abs(nvl(sum( case when trade_status   = '-6'  then oi.jc_sku_quantity end),0.00))                       as jc_sale_sku_r_qty
        ,abs(nvl(sum( case when trade_status in ('3','5','8','9','-9999')  then oi.sku_quantity end),0.00))      as xs_sale_sku_qty
        ,abs(nvl(sum( case when trade_status  ='-6' then oi.sku_quantity end),0.00))                             as xs_sale_sku_r_qty
        ,count(distinct case when trade_status in ('3','5','8','9','-9999')  then oi.order_store_no end )  as sales_ord_cnt
        ,count(distinct case when trade_status   = '-6'  then oi.order_store_no end )                      as sales_ord_cnt_refund
	from dw.fact_trade_order_item oi
	inner join dw.dim_channel cl on oi.channel_key = cl.channel_key
	where date_format(oi.payment_time,'yyyy-MM-dd') >= date_format(date_add(current_date(),-1),'yyyy-MM-dd')
	and   oi.dt >= date_format(date_add(current_date(),-10),'yyyy-MM-dd')
	and   trade_status in  ('3','5','8','9','-9999','-6')  -- 扣除退款3，5，8，9 -9999 正向-6逆向
	and   cl.channel_source IN ('01','04') --直营 加盟
	and   oi.order_business_type in (0,1,2)  -- 排除虚拟单
	and   cl.channel_type = '102' -- 下线app外卖
	group by date_format(oi.payment_time,'yyyyMMdd')
			,oi.store_key
			,cl.channel_source
            ,cl.channel_source_name
			,cl.channel_type
			,cl.channel_type_name
			,oi.sku_key
			,oi.sales_unit
			,oi.jc_unit
			,oi.is_gift
			,date_format(oi.payment_time,'yyyy-MM-dd')
    ) off_line
left join(   --  app外卖线上金额
		   select
                  date_format(oi.payment_time,'yyyy-MM-dd')                                                as dt
                 ,oi.store_key
                 ,oi.sku_key
                 ,abs(nvl(sum(oi.price * oi.sku_quantity),0.00))                                                     as sales_amt_no_discount
                 ,abs(nvl(sum(actual_amount),0.00))                                                                  as sales_amt
                 ,abs(nvl(sum(oi.discount_amout),0.00))                                                              as sales_amt_discount
                 ,abs(nvl(sum(case when trade_status  = '-6'  then oi.price * oi.sku_quantity end),0.00))            as sales_amt_refund
                 ,abs(nvl(sum(case when trade_status  = '-6'  then oi.actual_amount end),0.00))                      as sales_amt_no_discount_refund
                 ,abs(nvl(sum( case when trade_status in ('3','5','8','9','-9999')  then oi.actual_amount else 0.00 end),0.00))   as sales_amt_receive
		   from dw.fact_trade_order_item oi
		   inner join dw.dim_channel cl on oi.channel_key = cl.channel_key
		   where date_format(oi.payment_time,'yyyy-MM-dd') >= date_format(date_add(current_date(),-1),'yyyy-MM-dd')
		   and   oi.dt >= date_format(date_add(current_date(),-10),'yyyy-MM-dd')
		   and   trade_status in  ('3','5','8','9','-9999','-6')  -- 扣除退款3，5，8，9 -9999 正向-6逆向
		   and   cl.channel_source = '02' --app
		   and   oi.order_business_type in (0,1,2)  -- 排除虚拟单
		   and   cl.channel_type = '102' -- 线上app外卖
		   group by oi.store_key
					,oi.sku_key
					,date_format(oi.payment_time,'yyyy-MM-dd')
		 )on_line
on  off_line.dt = on_line.dt and off_line.store_key = on_line.store_key and off_line.sku_key = on_line.sku_key
;


-- ******************************************************社团核销  temp.wf_sqt_hx_order_3_0710_p:线上skucode 与线下skucode对应关系


--直播
create table temp.onlive_data as
select
         oi.store_key
        ,'9200' as business_code
        ,'直播'  as business_name
        ,oi.sku_key
        ,oi.sales_unit
        ,oi.jc_unit
        ,oi.is_gift
        ,date_format(oi.payment_time,'yyyyMMdd')                                                  as pay_date
        ,abs(nvl(sum(oi.price * oi.sku_quantity),0.00))                                                         as sales_amt_no_discount
        ,abs(nvl(sum(actual_amount),0.00))                                                                      as sales_amt
        ,abs(nvl(sum(oi.discount_amout),0.00))                                                                  as sales_amt_discount
        ,abs(nvl(sum(case when trade_status  = '-6'  then oi.price * oi.sku_quantity end),0.00))                as sales_amt_refund
        ,abs(nvl(sum(case when trade_status  = '-6'  then oi.actual_amount end),0.00))                          as sales_amt_no_discount_refund
        ,abs(nvl(sum( case when trade_status in ('3','5','8','9','-9999')  then oi.jc_sku_quantity end),0.00))  as jc_sale_sku_qty
        ,abs(nvl(sum( case when trade_status   = '-6'  then oi.jc_sku_quantity end),0.00))                      as jc_sale_sku_r_qty
        ,abs(nvl(sum( case when trade_status in ('3','5','8','9','-9999')  then oi.sku_quantity end),0.00))     as xs_sale_sku_qty
        ,abs(nvl(sum( case when trade_status  ='-6' then oi.sku_quantity end),0.00))                            as xs_sale_sku_r_qty
        ,count(distinct case when trade_status in ('3','5','8','9','-9999')  then oi.order_store_no end )  as sales_ord_cnt
        ,count(distinct case when trade_status   = '-6'  then oi.order_store_no end )                      as sales_ord_cnt_refund
-- 新增 渠道，补贴金额，应收额
        ,'9200' as channel_source
        ,'直播' as channel_source_name
        ,sum( case when trade_status in ('3','5','8','9','-9999')  then oi.actual_amount else 0.00 end)    as sales_amt_receive
        ,date_format(oi.payment_time,'yyyy-MM-dd')                                                as dt
from dw.fact_trade_order_item oi
inner join ods.zt_tc_order_line ol on substr(oi.order_store_no,0,16) = ol.id
                                  and ol.dt >= date_format(date_add(current_date(),-10),'yyyy-MM-dd')
                                  and ol.ext_data like '%room%'
                                  and ol.is_deleted = 0
where date_format(oi.payment_time,'yyyy-MM-dd') >= date_format(date_add(current_date(),-1),'yyyy-MM-dd')
and   oi.dt >= date_format(date_add(current_date(),-10),'yyyy-MM-dd')
and   trade_status in  ('3','5','8','9','-9999','-6')  -- 扣除退款3，5，8，9 -9999 正向-6逆向
and   oi.order_business_type in (0,1,2)  -- 排除虚拟单
group by date_format(oi.payment_time,'yyyyMMdd')
        ,oi.store_key
        ,oi.sku_key
        ,oi.sales_unit
        ,oi.jc_unit
        ,oi.is_gift
        ,date_format(oi.payment_time,'yyyy-MM-dd')
;
--   数据集合
create table  temp.sale_sku as
select * from temp.community_data
union all
select * from temp.direct_join_data
union all
select * from temp.app_data
union all
select * from temp.onlive_data
;

insert overwrite table dm.product_store_daily_analysis PARTITION  (dt)
select
       su.sku_key||su.business_code||su.store_key||su.pay_date            as  id
      ,su.store_key
      ,dst.store_name
      ,case when substring(su.store_key,2,1) = 'R' then '加盟' else '直营'    end
      ,cast(case when dst.is_open is null then -1 else dst.is_open end as string)
      ,dst.l2_company_code
      ,dst.l2_company_name
      ,aa.province_code
      ,aa.province_name
      ,aa.city_code
      ,aa.city_name
      ,aa.area_key
      ,aa.area_name
      ,dst.franchisee
      ,dst.franchisee_name
      ,su.business_code
      ,su.business_name
      ,sku.spu_code
      ,sku.spu_type
      ,su.sku_key
      ,case when su.sku_key = 'QT0001' then '补贴' else  sku.name end  sku.name
      ,sta.sku_status
      ,sku.second_material_code
      ,sku.second_material_name
      ,cast(sku.brand_id as string) as brand_id
      ,sku.brand_name
      ,case when su.sku_key = 'QT0001' then null else nvl(sl.sku_x_sale_level,'D') end          as sku_xg_sale_level
      ,case when su.sku_key = 'QT0001' then null else nvl(sl.sku_sale_amt_level,'D')  end       as sku_sale_amt_level
      ,cast(su.is_gift as string)   as is_gift
      ,sku.category_one_code
      ,sku.category_one_name
      ,sku.category_two_code
      ,sku.category_two_name
      ,sku.category_three_code
      ,sku.category_three_name
      ,sku.category_four_code
      ,sku.category_four_name
      ,su.pay_date
      ,nvl(su.sales_amt_no_discount,0.00)  as sales_amt_no_discount
      ,nvl(su.sales_amt,0.00)              as sales_amt
      ,nvl(su.sales_amt_discount,0.00)     as sales_amt_discount
      ,nvl(abs(su.sales_amt_no_discount_refund),0.00) as sales_amt_no_discount_refund
      ,nvl(abs(su.sales_amt_refund),0.00)  as sales_amt_refund
      ,su.jc_unit
      ,nvl(su.jc_sale_sku_qty,0.00)        as jc_sale_sku_qty
      ,nvl(abs(su.jc_sale_sku_r_qty),0.00) as jc_sale_sku_r_qty
      ,su.sales_unit
      ,nvl(su.xs_sale_sku_qty,0.00)        as xs_sale_sku_qty
      ,nvl(abs(su.xs_sale_sku_r_qty),0.00) as xs_sale_sku_r_qty
      ,sc.unit_name                        as xg_unit
      ,nvl(su.jc_sale_sku_qty,0.00)   / sc.scale as xg_sale_sku_qty
      ,nvl(abs(su.jc_sale_sku_r_qty),0.00) / sc.scale as xg_sale_sku_r_qty
      ,nvl(su.sales_ord_cnt,0)        as sales_ord_cnt
      ,nvl(su.sales_ord_cnt_refund,0) as sales_ord_cnt_refund
      ,nvl(su.sales_ord_cnt,0) + nvl(su.sales_ord_cnt_refund,0)  as passenger_flow
      ,from_unixtime(unix_timestamp(current_timestamp()) + 28800)                               as etl_updatetime
-- 新增 三级子公司 渠道，补贴金额，应收额
      ,dst.company_code
      ,dst.company_name
      ,su.channel_source
      ,su.channel_source_name
      ,su.sales_amt_receive
      ,su.dt
from temp.sale_sku su
left join dw.dim_sku   sku on su.sku_key = sku.sku_key
left  join dw.dim_store_daily_snapshot dst on dst.store_key = su.store_key and dst.dt = date_format(date_add(current_date(),-1),'yyyy-MM-dd')
left  join dw.dim_area aa  on aa.area_key = dst.area_code
left  join (select       distinct sku_code as sku_key
                        ,dt
                        ,case status when 'TOSUBMIT'    then '待提交'
                               when 'POTENTIAL'   then '潜在'
                               when 'INTENTIONAL' then '意向品'
                               when 'OFFICIAL'    then '正式商品'
                               when 'NEW'         then '新品(已上市)'
                               when 'NORMAL'      then '正常'
                               when 'PRECLOSE'    then '预下市'
                               when 'CLOSED'      then '已下市'
                               when 'PAUSE'       then '暂停销售'
                               else '未知'        end   as  sku_status
                 from ods.kp_scm_sku_mgr
                 where dt = date_format(date_add(current_date(),-1),'yyyy-MM-dd')
             )sta  on  su.sku_key  = sta.sku_key
left  join (
             select
                    distinct
                     b.sku_code
                    ,c.name as unit_name
                    ,a.scale
             From ods.zt_ic_sku_unit a
             left join ods.zt_ic_sku b on a.sku_id=b.id
             left join ods.zt_ic_unit c on a.unit_id=c.id
             where a.unit_id = '104' and a.is_deleted = 0  --箱规
            ) sc on su.sku_key = sc.sku_code

left join (
            select
                    dt
                   ,sku_key
                   ,three_level_code
                   ,sku_x_sale_level
                   ,sku_sale_amt_level
            from dm.product_all_channel_kpi
            where dt = date_format(date_add(current_date(),-1),'yyyy-MM-dd') -- and dt <= '2021-04-01'
            and dim_id = 6 -- 门店
          ) sl on su.sku_key = sl.sku_key and sl.dt = su.dt and su.store_key = sl.three_level_code
;
