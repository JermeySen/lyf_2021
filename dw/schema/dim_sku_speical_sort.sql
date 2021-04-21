create table dw.dim_sku_special_sort
(
 sku_key          string     comment 'sku编码 门店营业员业绩报表使用'
,sku_name         string     comment 'sku'
,category_id      int        comment '类目id 2001 咖啡   1001 酒'
,category_name    string     comment '类目名称'
,etl_updatetime   timestamp  comment 'etl_最后更新时间'
)




insert into dw.dim_sku_special_sort

select
 sku.sku_key
,sku.name
,case when  sku.sku_key in ( '20313'
,'20314'
,'20315'
,'20316') then 2001 else 1001 end

,case when  sku.sku_key in ( '20313'
,'20314'
,'20315'
,'20316') then '咖啡' else '酒' end
,current_date()
from dw.dim_sku sku
where sku.sku_key in
(
 '20313'
,'20314'
,'20315'
,'20316'

,'19565'
,'20002'
,'20326'
,'20340'
,'20339'
,'20267'
,'20338'
,'20337'
,'20268'
,'20269'

)