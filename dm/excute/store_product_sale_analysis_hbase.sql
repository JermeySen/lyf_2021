/*
--主题描述：门店营业员业绩提成——正常销售报表
--存储策略：hive动态映射到hbase  rowkey='反转(sku编码+门店+支付日期)'
--调度策略：每天跑近1天数据，任务号1398，依赖执行的调度任务号：1408
--维度    ：sku,天,门店
--业务范围：直营加盟
--作者：zengjiamin
--日期：20210508
 */
--**********************************修改
drop table if exists temp.result_amt;
create table temp.result_amt as
with amt as (
            select
                   a.id
                  ,concat(
                  'receive_amt:',receive_amt,','
                  'actual_amt:' ,actual_amt,','
                  'return_receive_amt:',return_receive_amt,','
                  'return_actual_amt:' ,return_actual_amt,','
                  'pay_sku_amt:'       ,pay_sku_amt,','
                  'return_sku_amt:'    ,return_sku_amt ) as str_amt
            from (
                select
                    reverse(a.sku_code||store_code||pay_date)                       as   id
                    ,cast(sum(nvl(sales_amt_no_discount,0)) as string)              as receive_amt
                    ,cast(sum(nvl(sales_amt,0))             as string)              as actual_amt
                    ,cast(sum(nvl(abs(sales_amt_no_discount_refund),0)) as string)  as return_receive_amt
                    ,cast(sum(nvl(abs(sales_amt_refund),0))      as string)         as return_actual_amt
                    ,cast(sum(nvl(xs_sale_sku_qty,0))       as string)              as pay_sku_amt
                    ,cast(sum(nvl(abs(xs_sale_sku_r_qty),0))     as string)         as return_sku_amt
                from  dm.product_store_daily_analysis a
                where a.dt >= date_format(date_add(current_date(),-1),'yyyy-MM-dd')
                 group by a.sku_code,a.store_code,a.pay_date
                ) a
)

,business_amt as (
                 select
                        id,a.sku_code,pay_date
                       ,concat_ws(',',collect_list(str_business_amt))  as    str_business_amt
                 from  (select
                             reverse(a.sku_code||store_code||pay_date)        as   id
                            ,a.sku_code
                            ,a.pay_date
                            ,concat(    a.business_code,'&receive_amt:'       ,cast(nvl(sales_amt_no_discount,0) as string) ,','
                                      , a.business_code,'&actual_amt:'        ,cast(nvl(sales_amt,0) as string)  ,','
                                      , a.business_code,'&return_receive_amt:',cast(nvl(abs(sales_amt_no_discount_refund),0) as string) ,','
                                      , a.business_code,'&return_actual_amt:' ,cast(nvl(abs(sales_amt_refund),0) as string) ,','
                                      , a.business_code,'&pay_sku_amt:'       ,cast(nvl(xs_sale_sku_qty,0) as string)  ,','
                                      , a.business_code,'&return_sku_amt:'    ,cast(nvl(abs(xs_sale_sku_r_qty),0) as string)  ,','
                                      , 'sale_unit:'                          ,xs_unit_code
                                    )     as   str_business_amt
                        from  dm.product_store_daily_analysis a
                         where a.dt >= date_format(date_add(current_date(),-1),'yyyy-MM-dd')
                         ) a
                 group by a.id,a.sku_code,pay_date
)
select
     bt.id  as key
    ,str_to_map(bt.str_business_amt||','||t.str_amt, ',' , ':') as str_map
    ,bt.pay_date
    ,bt.sku_code
from business_amt bt left join amt t on bt.id =t.id
;

insert into dm.store_product_sale_analysis_hbase
select key,str_map,pay_date,sku_code from temp.result_amt  ;


