/*
--主题描述：锁鲜装预测补货邮件数据
--调度策略：每天九9点40，原因：需等待第四范式结果推送。 任务1375
--维度    ：sku+门店
--业务范围：补货
--作者：zengjiamin
--日期：20210329
 */

insert overwrite table  dm.product_lock_fresh_detail

select
 st.`date`
,st.node_id
,st.sku_key
,sku.name
, st.cate_l4
, sku.category_four_name
, sku.package_material_type
, st.exec_replishment
,from_unixtime(unix_timestamp(current_timestamp()) + 28800)
from ods.day_prediction_replenishment st
inner join dw.dim_sku sku on st.sku_key = sku.sku_key
inner join ods.kp_scm_store_sku  scm on  st.sku_key=scm.sku_code
                                    and  st.node_id=scm.store_code
                                    and  scm.is_available='1'
                                    and  scm.is_delete='0'
where st.node_type = 'store'
  and st.channel = '直营'
  and st.dt = date_format(current_date(),'yyyy-MM-dd')
  and st.sku_key in ('20064','20095','20096','20566','20567','20568','20569','20544','20344','20365','20366','20367','20368','20369','20370','20371','20372','20373','20376','20505')
  ;
