/*
--主题描述：过期积分统计
--调度策略：没到新的过期积分时间不需要执行。
--维度    ：过期积分产生日期
--业务范围：会员积分流水
--作者：zengjiamin
--日期：20210326
 */
insert overwrite table dm.user_score_expired_product_date
SELECT
	t.expire_product_date
	,sum(t.affect_point / 100) expire_score
	,current_date()
FROM
	(
		SELECT
		    a.dt AS expire_product_date,
			m.affect_point
		FROM
			dw.fact_user_point_bill m
		LEFT JOIN dw.fact_user_point_bill a ON m.related_serial_no = a.inner_serial_no and a.type = 1
		WHERE
			m.status = 0
		and m.type = 0
		and m.is_deleted = 0
		AND m.scene_code = '1'
	) AS t
GROUP BY
	t.expire_product_date;