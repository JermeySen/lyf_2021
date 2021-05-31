create table  temp.temp0526 as
      select
             case when store_type ='直营' then  '01'||business_code||store_code||pay_date
                else  '04'||business_code||store_code||pay_date  end as  id
            ,pay_date
            ,store_code
            ,store_name
            ,store_code||pay_date as  store_daily_tag
            ,l2_company_code
            ,l2_company_name
            ,l2_company_code||'_l3' company_code
            ,l2_company_name||'_l3' company_name
            ,franchisee_code
            ,franchisee_name
            ,province_code
            ,province_name
            ,city_code
            ,city_name
            ,area_code
            ,area_name
            ,province_code||'999' as big_area_manager_code
            ,province_name||'999' as big_area_manager_name
            ,province_code||'888' as area_manager_code
            ,province_name||'888' as area_manager_name
            ,case when store_type ='直营' then '01' else '04' end  as channel_source
            ,store_type                                            as channel_source_name
            ,business_code    as channel_type
            ,business_name    as channel_type_name
            ,sum(sales_amt_no_discount+10) sales_amt_product
            ,sum(sales_amt_no_discount)  sales_amt_no_discount
            ,sum(sales_amt_no_discount+5) sales_amt_actual
            ,sum(sales_amt)   sales_amt
            ,sum(sales_amt-20) purchase_amt_franchisee
            ,sum(sales_amt-15) cost_amt_franchisee
            ,sum(sales_amt-10) gross_profit_franchisee
            ,11 purchase_ord_cnt_franchisee
            ,sum(sales_amt_no_discount+15) GMV
            ,sum(sales_amt_discount)   sales_amt_discount
            ,sum(nvl(sales_amt_refund,0))   sales_amt_refund
            ,1.78  as sales_amt_subsidy
            ,19.89 as cost_amt_tax
            ,20.7  as cost_amt_no_tax
            ,13    as  gross_profit_tax
            ,13.1  as gross_profit_no_tax
            ,sum(passenger_flow)  deal_ord_cnt
            ,sum(jc_sale_sku_qty) jc_sale_sku_qty
            ,sum(jc_sale_sku_r_qty) jc_sale_sku_r_qty
            ,dt
            from dm.product_store_daily_analysis a
            where dt >= '2021-05-01' and is_open =1
            group by pay_date
            ,store_code
            ,store_name
            ,store_type
            ,l2_company_code
            ,l2_company_name
            ,franchisee_code
            ,franchisee_name
            ,province_code
            ,province_name
            ,city_code
            ,city_name
            ,area_code
            ,area_name
            ,business_code
            ,business_name
            ,dt

insert overwrite table  dm.store_daily_business_firstchannel PARTITION  (dt)
select
  id
,pay_date
,store_code
,store_name
,store_daily_tag
,l2_company_code
,l2_company_name
,company_code
,company_name
,franchisee_code
,nvl(franchisee_name,'其他')
,province_code
,province_name
,city_code
,city_name
,area_code
,area_name
,big_area_manager_code
,big_area_manager_name
,area_manager_code
, area_manager_name
,channel_source
,channel_source_name
, channel_type
, channel_type_name
,abs(sales_amt_product)
,abs(sales_amt_no_discount)
,abs(sales_amt_actual)
,abs(sales_amt )
,abs(purchase_amt_franchisee)
,abs(cost_amt_franchisee)
,abs(gross_profit_franchisee)
,abs(purchase_ord_cnt_franchisee)
,abs(GMV)
,abs(sales_amt_discount)
,abs(sales_amt_refund)
,abs(sales_amt_subsidy)
,abs(cost_amt_tax)
,abs(cost_amt_no_tax)
,abs(gross_profit_tax)
,abs(gross_profit_no_tax)
,abs(deal_ord_cnt)
,abs(jc_sale_sku_qty)
,abs(jc_sale_sku_r_qty)
,current_date()
,dt
from temp.temp0526


select count(1) from  dm.store_daily_business_firstchannel