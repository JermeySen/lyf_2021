------------------------------------------------------------------------------- zt 中台

set tez.queue.name=dw; 
-----增量
DROP table temp.wf_sqt_hx_order_1;
DROP table temp.wf_sqt_hx_order_2;
DROP table temp.wf_sqt_hx_order_3;
DROP table temp.wf_sqt_hx_order;
DROP table temp.wf_sqt_hx_card_no;
DROP table temp.wf_sqt_hx_card_no_1;
DROP table temp.wf_sqt_hx_card_no_2;
DROP table temp.wf_sqt_hx_card_no_3;
DROP table temp.wf_order_current_count;


-----会员直营订单日数量
create table temp.wf_order_current_count
as
select date_format(a.payment_time,'yyyy-MM-dd') as date_key,
a.buyer_id,count(1) as order_count 
From ods.zt_tc_order a  
where a.trade_type in(6,7,8) and a.payment_time is not null 
and a.buyer_id is not null and a.is_deleted = 0  
and a.dt >= date_add(current_date(),-100)  and 1=2
group by date_format(a.payment_time,'yyyy-MM-dd'),a.buyer_id ;

----- 排除非社团核销券(20200526更新) and a.billno is NOT NULL and a.dt>='201911';
CREATE table temp.wf_sqt_hx_card_no_1 
as 
SELECT DISTINCT a.cardfaceno,a.orgcode as lstpayorgcode,b.carduseprjcode,
case when c.out_pay_no is NOT NULL then c.out_pay_no else a.billno end as lstpaysaleno 
From ods.msc_tisuaccbook a 
INNER JOIN ods.msc_tisucard b on a.cardfaceno=b.cardfaceno
left join ods.zt_pc_pmz_pay_trans c on a.billno=c.pay_no
where a.orgcode !='IF01' and b.cardtypecode = '734'
and a.billno is NOT NULL and a.dt >= date_format(date_add(current_date(),-120),'yyyyMMdd');

CREATE table temp.wf_sqt_hx_card_no_2 
as 
select distinct a.card_no,b.saleno,b.orgcode
    from (select ZfNo,saleno,orgcode from ods.cmp_tSalSalePay where ZfName != '电子提货卡' and dt >= '2019-10-01') b 
    inner join ods.o2owms_virtual_purchase_record a 
    on a.card_no = b.ZfNo
    where a.type = '21' and a.result = '1';

CREATE table temp.wf_sqt_hx_card_no_3
as 
select distinct card_no,type,result from (
select  a.card_no,a.type,a.result,b.card_no as card_no_1 
from ods.o2owms_virtual_purchase_record a 
left join temp.wf_sqt_hx_card_no_2 b on a.card_no=b.card_no ) a where card_no_1 is null;

------------------and c.dt > '2019-06-01' and c.trade_type in (6,7,8);
CREATE table temp.wf_sqt_hx_card_no 
as   
select distinct a.card_no
from temp.wf_sqt_hx_card_no_3 a 
join temp.wf_sqt_hx_card_no_1 b on a.card_no = b.cardfaceno 
join ods.zt_tc_order c on b.lstpaysaleno = c.order_no_out and b.lstpayorgcode = c.shop_code
left join ods.zt_bdc_store d on b.lstpayorgcode = d.code
left join ods.zt_tc_order_line h 
on c.id = h.order_id
left join ods.msc_tisuzqprjuseplu m on m.prjcode =b.carduseprjcode and m.grpcode = h.sku_code
where a.type = '21' and a.result= '1' and m.grpcode is not null and c.dt > date_add(current_date(),-120) and c.trade_type in (6,7,8);
  
-------社区团数据核销（update 20200526）
CREATE table temp.wf_sqt_hx_order_1 
as 
select 
  a.order_code,
  b.buyer_id,
  b.payment_time, 
  b.amount,
  case when d.out_pay_no is NOT NULL then d.out_pay_no else c.lstpaysaleno end as hx_order_code, 
  c.lstpayorgcode as hx_orgcode
from ods.o2owms_virtual_purchase_record a 
inner join temp.wf_sqt_hx_card_no  f on a.card_no=f.card_no 
 left join  ods.zt_tc_order  b on a.order_code = b.order_no 
 left join temp.wf_sqt_hx_card_no_1  c  on a.card_no = c.cardfaceno 
 left join ods.zt_pc_pmz_pay_trans d on c.lstpaysaleno=d.pay_no 
 where a.type = '21' and a.result= '1' 
 and a.dt >= date_add(current_date(),-120) ;
 
---社区团新-核销去重
CREATE table temp.wf_sqt_hx_order_2
as
SELECT distinct payment_time,hx_order_code,hx_orgcode 
from temp.wf_sqt_hx_order_1;
 
---社区团新-核销去重
CREATE table temp.wf_sqt_hx_order_3
as
select distinct a.order_code,
  a.buyer_id,
  a.payment_time, 
  a.amount,
  a.hx_order_code, 
  a.hx_orgcode, 
  c.buyer_id as hx_buyer_key,
  cast(c.payment_time as date) as lstpaydate, 
  datediff(cast(c.payment_time as date),cast(b.payment_time as date)) as hx_days, 
  case when datediff(cast(c.payment_time as date),cast(b.payment_time as date)) =0 then '当天'
when datediff(cast(c.payment_time as date),cast(b.payment_time as date)) =1 then '1天'
when datediff(cast(c.payment_time as date),cast(b.payment_time as date)) > 1 and datediff(cast(c.payment_time as date),cast(b.payment_time as date)) <= 7 then '2-7天'
when datediff(cast(c.payment_time as date),cast(b.payment_time as date)) > 7 and datediff(cast(c.payment_time as date),cast(b.payment_time as date)) <= 15 then '8-15天'
when datediff(cast(c.payment_time as date),cast(b.payment_time as date)) > 15 and datediff(cast(c.payment_time as date),cast(b.payment_time as date)) <= 30 then '16-30天'
when datediff(cast(c.payment_time as date),cast(b.payment_time as date)) > 30 then '30天以上'
end as community_corps_days_type
  From temp.wf_sqt_hx_order_1 a  
 INNER JOIN temp.wf_sqt_hx_order_2 b  on a.payment_time=b.payment_time and a.hx_order_code=b.hx_order_code and a.hx_orgcode=b.hx_orgcode 
 INNER JOIN ods.zt_tc_order c on a.hx_order_code=c.order_no_out and a.hx_orgcode=c.shop_code 
 where c.dt >= date_add(current_date(),-120) and c.payment_time is not null;

---社区团新
CREATE table temp.wf_sqt_hx_order
as
select order_code,buyer_id,payment_time,amount,hx_order_code,hx_orgcode,
hx_buyer_key,lstpaydate,hx_days,community_corps_days_type,order_count,
company_code from (
select order_code,buyer_id,payment_time,amount,hx_order_code,hx_orgcode,
hx_buyer_key,lstpaydate,hx_days,community_corps_days_type,order_count,
company_code,row_number() over ( partition by order_code order by hx_order_code,hx_orgcode asc ) as rn 
from (
select  distinct
a.order_code,
 a.buyer_id,
 a.payment_time, 
 a.amount,
 a.hx_order_code, 
 a.hx_orgcode, 
 a.hx_buyer_key,
 a.lstpaydate, 
 case when a.hx_days < 0  then 0 else a.hx_days end as hx_days, 
 case when a.hx_days < 0  then '当天' else a.community_corps_days_type end as community_corps_days_type,
1 as order_count,
case when c.company_code is null then -9999 else c.company_code end as company_code 
from temp.wf_sqt_hx_order_3 a 
LEFT JOIN ods.zt_bdc_store c on a.hx_orgcode= c.code  ) A ) B where  rn=1;

set tez.queue.name=dw;
set hive.exec.reducers.bytes.per.reducer=2342177280;
set hive.auto.convert.join=false;
set hive.merge.tezfiles=true;
set hive.merge.mapredfiles = true;
set hive.exec.max.dynamic.partitions=300;
set hive.exec.max.dynamic.partitions.pernode=400;

------订单第三方补贴金额
drop table temp.wf_order_third_amount;

create table temp.wf_order_third_amount
as
select shop_code,order_no,sum(share_promotion) as share_promotion from (
select b.shop_code,a.order_no,cast(sum(abs(a.share_promotion))  as decimal(18,2)) share_promotion
from ods.zt_tc_order_promotion a 
left join ods.zt_tc_order b on a.order_no=b.order_no
where activity_type_code in ('65','78','87','71','64','85','89','68','81','61','73','76') and a.create_time >= date_add(current_date(),-200)
group by b.shop_code,a.order_no
union all 
select b.shop_code,a.reverse_order_no,cast(sum(abs(a.share_promotion))*-1  as decimal(18,2)) share_promotion
from ods.zt_tc_reverse_order_promotion a 
left join ods.zt_tc_reverse_order b on a.reverse_order_no=b.reverse_order_no
where  activity_type_code in ('65','78','87','71','64','85','89','68','81','61','73','76') and a.create_time >= date_add(current_date(),-200)
group by b.shop_code,a.reverse_order_no
) t group by shop_code,order_no;


----- 95折优惠
drop table temp.wf_order_95;
create table temp.wf_order_95
as
select shop_code,order_no,sum(share_promotion) as share_promotion from ( 
select b.shop_code,a.order_no,cast(sum(abs(a.share_promotion))  as decimal(18,2)) share_promotion 
from ods.zt_tc_order_promotion a 
left join ods.zt_tc_order b on a.order_no=b.order_no 
where (a.activity_type_code in ('90') or a.template_id='7012') and a.create_time >= date_add(current_date(),-150) 
group by b.shop_code,a.order_no 
union all 
select b.shop_code,a.reverse_order_no,cast(sum(abs(a.share_promotion))*-1  as decimal(18,2)) share_promotion 
from ods.zt_tc_reverse_order_promotion a 
left join ods.zt_tc_reverse_order b on a.reverse_order_no=b.reverse_order_no 
where  activity_type_code in ('90') and a.create_time >= date_add(current_date(),-150) 
group by b.shop_code,a.reverse_order_no 
) t group by shop_code,order_no;


------- 社区团中间步骤处理表
drop table temp.wf_tab_sqt1102_1;

CREATE TABLE temp.wf_tab_sqt1102_1
as 
SELECT hx_order_code,hx_orgcode,sum(amount) as amount From temp.wf_sqt_hx_order a 
GROUP BY hx_order_code,hx_orgcode;

drop table temp.wf_tab_sqt1102_2;

CREATE TABLE temp.wf_tab_sqt1102_2
as 
select hx_order_code,hx_orgcode,community_corps_days_type,hx_days From (
SELECT hx_order_code,hx_orgcode,community_corps_days_type,hx_days,
row_number() over ( partition by hx_order_code,hx_orgcode order by hx_days asc ) as rn
From temp.wf_sqt_hx_order a ) a where rn=1 ;

drop table temp.wf_tab_sqt1102;

CREATE TABLE temp.wf_tab_sqt1102
as 
select a.hx_order_code,a.hx_orgcode,a.amount,b.community_corps_days_type,b.hx_days 
From temp.wf_tab_sqt1102_1 a
inner join temp.wf_tab_sqt1102_2 b on a.hx_order_code=b.hx_order_code and a.hx_orgcode=b.hx_orgcode;



--------------------------------- 订单收货地址
drop table temp.wf_zt_order_area_1;

create table temp.wf_zt_order_area_1
as
SELECT distinct a.id,a.order_no,
a.good_receiver_province_id,
a.good_receiver_city_id,
a.good_receiver_area_id
From ods.zt_tc_order_address a 
where a.good_receiver_province_id is not null 
and a.dt >= date_add(current_date(),-100) and a.dt <= date_add(current_date(),-1)
union all
SELECT DISTINCT a.id,a.reverse_order_no, 
b.good_receiver_province_id,
b.good_receiver_city_id,
b.good_receiver_area_id
From ods.zt_tc_reverse_order a 
inner JOIN (SELECT id,order_no,good_receiver_province_id,good_receiver_province,
good_receiver_city_id,good_receiver_city,
good_receiver_area_id,good_receiver_area
From ods.zt_tc_order_address a 
where a.dt >= date_add(current_date(),-100) and a.dt <= date_add(current_date(),-1)
and good_receiver_province_id is not null) b on a.order_no=b.order_no
where a.order_no is NOT NULL;

drop table temp.wf_zt_order_area_2;

create table temp.wf_zt_order_area_2
as
select a.id,a.order_no,
case when b.code is not null then b.code else e.code end as province_code,
case when b.code is not null then b.name else e.name end  as province_name,
case when c.code is not null then c.code else f.code end  as city_code,
case when c.code is not null then c.name else f.name end  as city_name,
case when d.code is not null then d.code else g.code end  as area_code,
case when d.code is not null then d.name else g.name end  as area_name
From temp.wf_zt_order_area_1 a 
left join ods.zt_bdc_area b on  cast(a.good_receiver_province_id as string)=cast(b.code as string)
left join ods.zt_bdc_area c on  cast(a.good_receiver_city_id as string)=cast(c.code as string)
left join ods.zt_bdc_area d on  cast(a.good_receiver_area_id as string)=cast(d.code as string)
left join ods.zt_bdc_area e on cast(a.good_receiver_province_id as string)=cast(e.id as string) 
left join ods.zt_bdc_area f on cast(a.good_receiver_city_id as string)=cast(f.id as string) 
left join ods.zt_bdc_area g on cast(a.good_receiver_area_id as string)=cast(g.id as string);

drop table temp.wf_zt_order_area;

create table temp.wf_zt_order_area
as
select id,order_no,province_code,province_name,city_code,city_name,area_code,area_name
from (
select id,order_no,province_code,province_name,city_code,city_name,area_code,area_name,
row_number() over ( partition by order_no order by id desc ) as rn
from temp.wf_zt_order_area_2 ) a where rn=1;


---步骤3：zt 正向订单
--INSERT into dw.fact_trade_order_20191228 partition(dt)
drop table temp.wf_zt_order_one;

CREATE TABLE temp.wf_zt_order_one
as 
SELECT a.order_no,a.parent_order_no as parent_order_no,a.id||'_'||a.order_no||'_'||a.shop_code as order_store_no,
date_format(a.payment_time,'yyyyMMdd') as date_key,
b.company_code as org_key,
b.area as area_key,
case when a.trade_type=91 then 'IF02_123_1' when a.trade_type=92 then 'IF02_126_1'  else a.channel_code||'_'||a.trade_type end as channel_key,
a.shop_code as store_key,
date_format(a.payment_time,'yyyyMMdd')||'_'||a.shop_code as date_store_id,
cast(case when a.buyer_id is null then -9999 else a.buyer_id end as string) as buyer_key,
case a.client when 'POS' then 1 when 'PC' then 2 when 'APP' then 3 when '小程序' then 4 when 'H5' then 5 when 'ANDROID' then 6
when 'OFFICIAL' then 7 when 'IOS' then 8 when 'WECHAT' then 10  when 'MOBILE_POS' then 11 else 9 end as clinet_key,
a.orgin_amount,
a.actual_amount as amount,
case when f.amount is not null then f.amount else a.amount end as actual_amount,
a.discount_price,
0.00 as lyf_sharing_money,
0.00 as union_sharing_money,
a.delivery_fee,
0.00 as gross_amount,
0.00 as compensatory_amount,
cast(case when a.buyer_id is null then -9999 else a.buyer_id end as string) as buyer_id,
case when a.trade_status = 0 and a.payment_time is not null then -9999 else case when a.trade_status = 2 then 3 else a.trade_status end end as trade_status,
case when a.trade_status = 0 and a.payment_time is not null then 'app支付并退单' else case a.trade_status when 0 then '订单取消' when 1 then '待付款' when 2 then '拼团中' when 3 then '待发货' when 5 then '已发货' when 8 then '订单成功' when 9 then '订单关闭' end end as trade_status_name,
case when a.trade_type in (91,92) then 1 else a.trade_type end as trade_type,
case a.trade_type when 1 then '普通' when 2 then '预售' when 3 then '拼团' when 4 then '拼券' when 5 then '旺店通' 
when 6 then 'POS门店' when 7 then '外卖自营' when 8 then '外卖第三方' when 9 then '电商超市' when 10 then '2B分销' when 11 then '加盟商' when 12 then '虚拟商品' when 91 then '普通' when 92 then '普通' end  as trade_type_name,
a.source as order_source,
case a.source when 1 then '门店下单'  when 2 then '导入订单'  when 3 then '用户下单'  when 4 then '手工建单' end as order_source_name,
'zt' as order_system,
'toC' order_to_bc,
cast(a.cancel_type as string) as cancel_type,
a.cancel_reason_desc,
a.is_parent,
a.is_reverse,
a.is_normal,
cast(a.expect_receive_type as string) as expect_receive_type,
cast(a.create_time as string) as create_time,
cast(a.payment_time as string) as payment_time ,
cast(a.order_logistics_time as string) as order_logistics_time,
cast(a.expect_receive_time as string) as expect_receive_time,
cast(a.cancel_time as string) as cancel_time,
'' as return_order_no,
case when a.trade_type=12 then 9 else 0 end as order_business_type,
1 is_kylin_status,
0 as reverse_type,
0 as reverse_scope,
case when d.member_level is NULL then 'VIP0' else d.member_level end as member_level,
a.order_no_out,
cast(a.merchant_id as string) as merchant_id,
g.merchant_name as merchant_name,
case when f.hx_order_code is not null then 1 else case when w.order_code is NOT NULL then 1 else 0 end end is_community_corps,
case when f.hx_order_code is not null then f.hx_order_code else case when w.order_code is NOT NULL then w.hx_orgcode||'_'||w.hx_order_code else '' end end as third_party_orderno,
k.share_promotion as third_party_amount,
a.user_type,
case when f.hx_order_code is not null then m.order_count end as order_count_currentday,
case when w.order_code is not null then 1 else 0 end as community_corps_success,
'' as community_corps_statrdate,
case when f.hx_order_code is not null then f.hx_days else case when w.order_code is NOT NULL then w.hx_days else 0 end end as community_corps_days,
case when f.hx_order_code is not null then f.community_corps_days_type else case when w.order_code is NOT NULL then w.community_corps_days_type else '' end end as community_corps_days_type,
case when a.payment_time is null then -9999 else cast(hour(a.payment_time)+1 as int) end as hour_key,
0.00 cw_gross_amount,
case when x.activate_user is not null then 1 else 0 end as is_premium,
z.share_promotion as discount_95_amount,
case when y.order_no is not null then 1 else 0 end as is_sale_card,
a.amount as ord_actual_amount
,case when v.province_code is not null then v.province_code else case when a.shop_code !='IF01' then b.province_code end end as province_code
,case when v.province_code is not null then v.province_name else case when a.shop_code !='IF01' then b.province end end as province_name
,case when v.city_code is not null then v.city_code else case when a.shop_code !='IF01' then b.city_code end end as city_code
,case when v.city_code is not null then v.city_name else case when a.shop_code !='IF01' then b.city end end as city_name
,case when v.area_code is not null then v.area_code else case when a.shop_code !='IF01' then b.area_code end end as area_code
,case when v.area_code is not null then v.area_name else case when a.shop_code !='IF01' then b.area end end as area_name
,a.dt
From ods.zt_tc_order a 
LEFT JOIN dw.dim_store b on a.shop_code=b.store_key
LEFT JOIN dw.dim_user d on a.buyer_id=d.buyer_key
LEFT JOIN temp.wf_tab_sqt1102 f on a.order_no_out=f.hx_order_code and a.shop_code = f.hx_orgcode
LEFT JOIN temp.wf_sqt_hx_order w on a.order_no=w.order_code
left join ods.zt_bdc_merchant g on g.merchant_id=a.merchant_id
left join temp.wf_order_third_amount k on a.shop_code=k.shop_code and a.order_no=k.order_no
left join temp.wf_order_current_count m on a.buyer_id=m.buyer_id and date_format(a.payment_time,'yyyyMMdd')=m.date_key
left JOIN (SELECT DISTINCT a.activate_user,date_format(a.activate_time,'yyyyMMdd') as active_date_key from ods.qt_pm_t_member_card as a where a.activate_user is NOT NULL and card_status='actived') x on a.buyer_id=x.activate_user and date_format(a.payment_time,'yyyyMMdd')>=x.active_date_key
left JOIN (SELECT DISTINCT order_no from ods.qt_pm_t_member_card as a where order_no is not null) y on a.order_no=y.order_no 
left join temp.wf_order_95 z on a.order_no=z.order_no and a.shop_code=z.shop_code
left join temp.wf_zt_order_area v on a.order_no=v.order_no
where a.trade_type in(1,3,4,5,6,7,8,12,91,92) and a.is_deleted = 0   
and a.dt >= date_add(current_date(),-70) and a.dt <= date_add(current_date(),-1);

--------------步骤1： 中台交易逆向订单切换（直营/加盟/社区拼团）
drop table temp.wf_zt_order_two;
--- 步骤3：逆向订单
CREATE TABLE temp.wf_zt_order_two
as
SELECT a.reverse_order_no as order_no,'' as parent_order_no,a.id||'_'||a.reverse_order_no||'_'||(case when a.shop_code is null then substr(a.channel_code,1,4) else a.shop_code end) as order_store_no,
case when trade_type in (6,7,8) and substr(a.channel_code||'_'||a.trade_type,5,6) != '_102_7' then date_format(a.apply_time,'yyyyMMdd') else date_format(a.business_date,'yyyyMMdd') end as date_key,
b.company_code as org_key,
b.area as area_key,
case when a.trade_type=91 then 'IF02_123_1' when a.trade_type=92 then 'IF02_126_1'  else a.channel_code||'_'||a.trade_type end as channel_key,
(case when a.shop_code is null then substr(a.channel_code,1,4) else a.shop_code end) as store_key,
date_format(a.business_date,'yyyyMMdd')||'_'||(case when a.shop_code is null then substr(a.channel_code,1,4) else a.shop_code end) as date_store_id,
cast(case when a.user_id is null then -9999 else a.user_id end as string) as buyer_key,
1 as clinet_key,
a.apply_return_amount*-1 as orgin_amount,
a.apply_return_amount*-1 as amount,
case when f.amount is not null then abs(f.amount)*-1 else a.actual_return_amount*-1 end as actual_amount,
0.00 discount_price,
0.00 as lyf_sharing_money,
0.00 as union_sharing_money,
a.freight*-1 as delivery_fee,
0.00 as gross_amount,
0.00 as compensatory_amount,
cast(case when a.user_id is null then -9999 else a.user_id end as string ) as buyer_id,
a.trade_status*-1 as trade_status,
case when a.trade_status = 1 then '待审核' when a.trade_status = 2 then '待退货' when a.trade_status = 3 then '待收货' when a.trade_status = 4 then '待确认' 
when a.trade_status = 5 then '待付款' when a.trade_status = 6 then '已完成' when a.trade_status = 7 then '已取消' when a.trade_status = 8 then '已驳回' else '已完成' end  as trade_status_name,
case when a.trade_type in (91,92) then 1 else a.trade_type end as trade_type,
case a.trade_type when 1 then '普通' when 2 then '预售' when 3 then '拼团' when 4 then '拼券' when 5 then '旺店通' 
when 6 then 'POS门店' when 7 then '外卖自营' when 8 then '外卖第三方' when 9 then '电商超市' when 10 then '2B分销' when 11 then '加盟商' when 12 then '虚拟商品' when 91 then '普通' when 92 then '普通' end  as trade_type_name,
a.source as order_source,
case a.source when 1 then '用户申请'  when 2 then '客服创建'  when 3 then '门店申请' end as order_source_name,
'zt' as order_system,
'toC' order_to_bc,
'' cancel_type,
'' cancel_reason_desc,
0 is_parent,
0 is_reverse,
a.is_normal,
'' expect_receive_type,
cast(a.create_time as string) as create_time,
case when trade_type in (6,7,8) then cast(a.apply_time as string) else cast(a.business_date as string) end  as payment_time,
cast(a.business_date as string) as order_logistics_time,
'' expect_receive_time,
cast(a.apply_time as string) as cancel_time,
a.order_no as return_order_no
,case when a.trade_type=12 then 9 else 0 end as order_business_type
,1 is_kylin_status
,a.reverse_type
,a.reverse_scope,
case when d.member_level is NULL then 'VIP0' else d.member_level end as member_level,
a.reverse_order_no_out as order_no_out,
cast(a.merchant_id as string) as merchant_id,
g.merchant_name as merchant_name,
case when f.hx_order_code is not null then 1 else case when w.order_code is NOT NULL then 1 else 0 end end is_community_corps,
case when f.hx_order_code is not null then f.hx_order_code else case when w.order_code is NOT NULL then w.hx_orgcode||'_'||w.hx_order_code else '' end end as third_party_orderno,
k.share_promotion as third_party_amount,
'' as user_type,
case when f.hx_order_code is not null then m.order_count end as order_count_currentday,
case when w.order_code is not null then 1 else 0 end as community_corps_success,
'' as community_corps_statrdate,
case when f.hx_order_code is not null then f.hx_days else case when w.order_code is NOT NULL then w.hx_days else 0 end end as community_corps_days,
case when f.hx_order_code is not null then f.community_corps_days_type else case when w.order_code is NOT NULL then w.community_corps_days_type else '' end end as community_corps_days_type,
case when a.business_date is null then -9999 else cast(hour(a.business_date)+1 as int) end as hour_key,
0.00 as cw_gross_amount,
case when x.activate_user is not null then 1 else 0 end as is_premium,
z.share_promotion as discount_95_amount,
case when y.order_no is not null then 1 else 0 end as is_sale_card,
a.actual_return_amount*-1 as ord_actual_amount
,case when v.province_code is not null then v.province_code else case when a.shop_code !='IF01' then b.province_code end end as province_code
,case when v.province_code is not null then v.province_name else case when a.shop_code !='IF01' then b.province end end as province_name
,case when v.city_code is not null then v.city_code else case when a.shop_code !='IF01' then b.city_code end end as city_code
,case when v.city_code is not null then v.city_name else case when a.shop_code !='IF01' then b.city end end as city_name
,case when v.area_code is not null then v.area_code else case when a.shop_code !='IF01' then b.area_code end end as area_code
,case when v.area_code is not null then v.area_name else case when a.shop_code !='IF01' then b.area end end as area_name
,date_format(cast(a.create_time as date),'yyyy-MM-dd') dt
From ods.zt_tc_reverse_order a 
LEFT JOIN dw.dim_store b on (case when a.shop_code is null then substr(a.channel_code,1,4) else a.shop_code end)=b.store_key
LEFT JOIN dw.dim_user d on a.user_id=d.buyer_key
LEFT JOIN temp.wf_tab_sqt1102 f on a.reverse_order_no_out=f.hx_order_code 
and (case when a.shop_code is null then substr(a.channel_code,1,4) else a.shop_code end) = f.hx_orgcode
LEFT JOIN temp.wf_sqt_hx_order w on a.reverse_order_no=w.order_code
left join ods.zt_bdc_merchant g on g.merchant_id=a.merchant_id 
left join temp.wf_order_third_amount k 
on (case when a.shop_code is null then substr(a.channel_code,1,4) else a.shop_code end)=k.shop_code and a.reverse_order_no=k.order_no
left join temp.wf_order_current_count m on a.user_id=m.buyer_id and date_format(a.business_date,'yyyyMMdd')=m.date_key
left JOIN (SELECT DISTINCT a.activate_user,date_format(a.activate_time,'yyyyMMdd') as active_date_key from ods.qt_pm_t_member_card as a where a.activate_user is NOT NULL and card_status='actived') x on a.user_id=x.activate_user and (case when trade_type in (6,7,8) then date_format(a.apply_time,'yyyyMMdd') else date_format(a.business_date,'yyyyMMdd') end)>=x.active_date_key
left JOIN (SELECT DISTINCT order_no from ods.qt_pm_t_member_card as a where order_no is not null) y on a.reverse_order_no=y.order_no 
left join temp.wf_order_95 z on a.reverse_order_no=z.order_no 
and (case when a.shop_code is null then substr(a.channel_code,1,4) else a.shop_code end)=z.shop_code
left join temp.wf_zt_order_area v on a.reverse_order_no=v.order_no
where a.trade_type in(1,3,4,5,6,7,8,12,91,92) and a.is_deleted=0 
 and cast(a.create_time as date)  >= date_add(current_date(),-70) and cast(a.create_time as date)  <= date_add(current_date(),-1);

-------销售易数据
drop table temp.wf_xsy_order_one;
--- 步骤4：逆向订单
CREATE TABLE temp.wf_xsy_order_one
as
SELECT a.name as order_no,----订单号
a.id||'_'||a.customitem3 as parent_order_no,
a.id||'_'||a.customitem1 order_store_no,
from_unixtime(cast(cast(a.createdat as double)/1000+28800 as bigint),'yyyyMMdd') as date_key,
'-9999' as org_key,
'-9999' as area_key,
case when a.customitem80__c=1 then 'XSY_TG' else 'XSY_JXS' end as channel_key,
'-9999' as store_key,
'-9999' as date_store_id,
cast(a.customitem12 as string) as buyer_key,
-9999 as clinet_key,
case when a.customitem6 = 1 then abs(a.customitem36) else abs(a.customitem36)*-1 end as orgin_amount,
case when a.customitem6 = 1 then abs(a.customitem76__c) else abs(a.customitem76__c)*-1 end as amount,
case when a.customitem6 = 1 then abs(a.customitem28) else abs(a.customitem28)*-1 end as actual_amount,
case when a.customitem6 = 1 then abs(a.customitem36)-abs(a.customitem76__c) else (abs(a.customitem36)-abs(a.customitem76__c))*-1 end as discount_amount,
0.00 as lyf_sharing_money,
0.00 as union_sharing_money,
0.00 as delivery_fee,
case when a.customitem6 = 1 then abs(a.customitem67__c) else abs(a.customitem67__c)*-1 end as gross_amount,
0.00 as compensatory_amount,
cast(a.customitem12 as string) as buyer_id,
case when a.customitem6 = 1 then case a.approvalstatus when 0 then 1 when 1 then 1 when 2 then -9999 when 3 then 3 when 4 then -9999 end else case a.approvalstatus when 0 then -1 when 1 then -1 when 2 then -6 when 3 then -6 when 4 then -1 end end trade_status,
case a.approvalstatus when 0 then '待提交' when 1 then '审批中' when 2 then '审批拒绝' when 3 then '审批通过' when 4 then '撤回' end as trade_status_name,
case when a.customitem80__c=1 then 77 else 78 end as trade_type,
case when a.customitem80__c=1 then '销售易-团购' else '销售易-经销商' end as trade_type_name,
4 as order_source,
'手工建单' as order_source_name,
'XSY' as order_system,
'ToB' as order_to_bc,
cast(a.customitem30 as string) as cancel_type,
b.cancel_name as cancel_reason_desc
,0 as is_parent
,0 as is_reverse
,0 as is_normal
,'1' as expect_receive_type
,from_unixtime(cast(cast(a.createdat as double)/1000+28800 as bigint),'yyyy-MM-dd') as create_time
,from_unixtime(cast(cast(a.customitem54 as double)/1000+28800 as bigint),'yyyy-MM-dd') as payment_time
,from_unixtime(cast(cast(a.customitem82__c as double)/1000+28800 as bigint),'yyyy-MM-dd') as order_logistics_time
,from_unixtime(cast(cast(a.customitem17 as double)/1000+28800 as bigint),'yyyy-MM-dd') as expect_receive_time
,'' cancel_time
,a.customitem7 as return_order_no
,0 as order_business_type
,0 as is_kylin_status
,5 as reverse_type
,1 as reverse_scope
,'VIP0' as member_level
,'' as order_out_no
,'' as merchant_id
,'' as merchant_name
,0 as is_community_corps
,'' as third_party_orderno
,0.00 as third_party_amount
,'' as user_type
,0 as order_count_currentday
,0 as community_corps_success
,'' as community_corps_statrdate
,0 as community_corps_days
,'' as community_corps_days_type
,9 as hour_key
,0.00 cw_gross_amount
,0 as is_premium
,0.00 as discount_95_amount
,0 as is_sale_card
,case when a.customitem6 = 1 then abs(a.customitem28) else abs(a.customitem28)*-1 end as ord_actual_amount
,'' as province_code
,'' as province
,'' as city_code
,'' as city
,'' as area_code
,'' as  area
,a.dt
from ods.xsy_order a 
left join (
select 1 as types,'销售会谈' as cancel_name
union all 
select 2 as types,'贸易展览会销售活动' as cancel_name
union all 
select 3 as types,'电视商业' as cancel_name
union all 
select 4 as types,'客户建议' as cancel_name
union all 
select 5 as types,'报纸广告' as cancel_name
union all 
select 6 as types,'极好的价格' as cancel_name
union all 
select 7 as types,'快速交货' as cancel_name
union all 
select 8 as types,'优良服务' as cancel_name
union all 
select 9 as types,'因口味与原来有变化' as cancel_name
union all 
select 10 as types,'因商品质量问题' as cancel_name
union all 
select 11 as types,'因当时买的太多吃不了' as cancel_name
union all 
select 12 as types,'因个人原因，现在不想吃了' as cancel_name
union all 
select 13 as types,'因商品是朋友送的，我不喜欢' as cancel_name
union all 
select 14 as types,'没有理由' as cancel_name
union all 
select 15 as types,'价格差异：价格太高' as cancel_name
union all 
select 16 as types,'质量低劣' as cancel_name
union all 
select 17 as types,'转运中受损' as cancel_name
union all 
select 18 as types,'数量不符' as cancel_name
union all 
select 19 as types,'物料损坏' as cancel_name
union all 
select 20 as types,'免费样本' as cancel_name
union all 
select 21 as types,'价格差异：价格太低' as cancel_name
union all 
select 22 as types,'自行过帐已处理' as cancel_name
union all 
select 23 as types,'SBWAP：差异清算（数量/值）' as cancel_name
union all 
select 24 as types,'SBWAP：新的未清项' as cancel_name
) b on a.customitem30=b.types
where a.customitem39=1 and a.dt >= date_add(current_date(),-70) and a.dt <= date_add(current_date(),-1);


------加盟进货-正向订单
drop table temp.wf_jmcg_order_one;
--- 步骤5：正向订单
CREATE TABLE temp.wf_jmcg_order_one
as
SELECT a.po_no as order_no,----订单号
a.id||'_'||a.po_no as parent_order_no,
a.id||'_'||a.shop_code order_store_no,
date_format(a.create_time,'yyyyMMdd') as date_key,
a.company_code as org_key,
'-9999' as area_key,
a.shop_code||substr(channel_code,length(channel_code)-3,4)||'_79' as channel_key,
a.shop_code as store_key,
a.shop_code||'_'||date_format(a.create_time,'yyyyMMdd') as date_store_id,
'-9999' as buyer_key,
-9999 as clinet_key,
a.amount as orgin_amount,
a.amount as amount,
a.amount as actual_amount,
0.00 as discount_amount,
0.00 as lyf_sharing_money,
0.00 as union_sharing_money,
0.00 as delivery_fee,
0.00 as gross_amount,
0.00 as compensatory_amount,
'-9999' as buyer_id,
case a.trade_status when 0 then 0 when 1 then 1 when 2 then 3 when 3 then 5 when 4 then 8 when 5 then 8 end as trade_status,
case a.trade_status when 0 then '取消' when 1 then '待确认' when 2 then '已确认' when 3 then '已发货' when 4 then '已收货' when 5 then '已完成' end as trade_status_name,
79 as trade_type,
'加盟渠道进货' as trade_type_name,
4 as order_source,
'手工建单' as order_source_name,
'JMJH' as order_system,
'ToC' as order_to_bc,
'' as cancel_type,
'' as cancel_reason_desc
,0 as is_parent
,0 as is_reverse
,0 as is_normal
,'1' as expect_receive_type
,cast(a.create_time as string) as create_time
,cast(a.create_time as string) as payment_time
,cast(a.expect_date as string) as order_logistics_time
,cast(a.expect_date as string) as expect_receive_time
,cast(a.cancel_time as string) as cancel_time
,'' as return_order_no
,0 as order_business_type
,0 as is_kylin_status
,5 as reverse_type
,1 as reverse_scope
,'VIP0' as member_level
,a.order_no_out as order_out_no
,cast(a.merchant_id as string) as merchant_id
,'' as merchant_name
,0 as is_community_corps
,'' as third_party_orderno
,0.00 as third_party_amount
,'' as user_type
,0 as order_count_currentday
,0 as community_corps_success
,'' as community_corps_statrdate
,0 as community_corps_days
,'' as community_corps_days_type
,9 as hour_key
,0.00 cw_gross_amount
,0 as is_premium
,0.00 as discount_95_amount
,0 as is_sale_card
,a.amount as ord_actual_amount
,b.province_code
,b.province
,b.city_code
,b.city
,b.area_code
,b.area
,a.dt
from ods.zt_tci_inner_po a 
left join dw.dim_store b on a.shop_code=b.store_key
where a.shop_type=3 and a.is_deleted=0 
and a.dt >= date_add(current_date(),-70) and a.dt <= date_add(current_date(),-1);

-----加盟进货---逆向订单
drop table temp.wf_jmcg_order_two;
--- 步骤5：逆向订单
CREATE TABLE temp.wf_jmcg_order_two
as
SELECT a.reverse_no as order_no,----订单号
a.id||'_'||a.reverse_no as parent_order_no,
a.id||'_'||a.shop_code order_store_no,
date_format(a.create_time,'yyyyMMdd') as date_key,
a.company_code as org_key,
'-9999' as area_key,
a.shop_code||substr(channel_code,length(channel_code)-3,4)||'_79' as channel_key,
a.shop_code as store_key,
a.shop_code||'_'||date_format(a.create_time,'yyyyMMdd') as date_store_id,
'-9999' as buyer_key,
-9999 as clinet_key,
a.amount*-1 as orgin_amount,
a.amount*-1 as amount,
a.amount*-1 as actual_amount,
0.00 as discount_amount,
0.00 as lyf_sharing_money,
0.00 as union_sharing_money,
0.00 as delivery_fee,
0.00 as gross_amount,
0.00 as compensatory_amount,
'-9999' as buyer_id,
case a.status when 0 then 0 when 1 then -1 when 2 then -2 when 3 then -3 when 4 then -4 when 5 then -6 end as trade_status,
case a.status when 0 then '取消' when 1 then '待确认' when 2 then '待退货' when 3 then '待收货' when 4 then '已收货' when 5 then '已完成' end as trade_status_name,
79 as trade_type,
'加盟渠道进货' as trade_type_name,
4 as order_source,
'手工建单' as order_source_name,
'JMJH' as order_system,
'ToC' as order_to_bc,
'' as cancel_type,
'' as cancel_reason_desc
,0 as is_parent
,0 as is_reverse
,0 as is_normal
,'1' as expect_receive_type
,cast(a.create_time as string) as create_time
,cast(a.create_time as string) as payment_time
,cast(a.expect_date as string) as order_logistics_time
,cast(a.audit_time as string) as expect_receive_time
,cast(a.create_time as string) as cancel_time
,'' as return_order_no
,0 as order_business_type
,0 as is_kylin_status
,5 as reverse_type
,1 as reverse_scope
,'VIP0' as member_level
,a.order_no_out as order_out_no
,cast(a.merchant_id as string) as merchant_id
,'' as merchant_name
,0 as is_community_corps
,'' as third_party_orderno
,0.00 as third_party_amount
,'' as user_type
,0 as order_count_currentday
,0 as community_corps_success
,'' as community_corps_statrdate
,0 as community_corps_days
,'' as community_corps_days_type
,9 as hour_key
,0.00 cw_gross_amount
,0 as is_premium
,0.00 as discount_95_amount
,0 as is_sale_card
,a.amount*-1 as ord_actual_amount
,b.province_code
,b.province
,b.city_code
,b.city
,b.area_code
,b.area
,date_format(a.create_time,'yyyy-MM-dd') as dt
from ods.zt_tci_inner_reverse_po a 
left join dw.dim_store b on a.shop_code=b.store_key
where a.shop_type=3 and a.is_deleted=0 
and a.create_time >= date_add(current_date(),-70) and a.create_time <= date_add(current_date(),-1);

------------------------------------------------------------------------------------ 汇聚写入数据
drop table temp.wf_order_hz;

create table  temp.wf_order_hz
as  
SELECT *From temp.wf_zt_order_one
UNION all 
SELECT *From temp.wf_zt_order_two
UNION all 
select *From temp.wf_xsy_order_one
UNION all 
select *From temp.wf_jmcg_order_one
UNION all 
select *From temp.wf_jmcg_order_two;

---写入数据
set tez.queue.name=dw;
set hive.exec.reducers.bytes.per.reducer=2342177280;
set hive.auto.convert.join=false;
set hive.merge.tezfiles=true;
set hive.merge.mapredfiles = true;
set hive.exec.max.dynamic.partitions=300;
set hive.exec.max.dynamic.partitions.pernode=400;

INSERT overwrite  table dw.fact_trade_order partition(dt)
SELECT *From temp.wf_order_hz; 
