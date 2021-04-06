delete from  dw.dim_store_daily_snapshot where dt = date_format(date_add(current_date(),-1),'yyyy-MM-dd');

insert  into dw.dim_store_daily_snapshot
select
 *
,date_format(date_add(current_date(),-1),'yyyy-MM-dd')
from dw.dim_store;