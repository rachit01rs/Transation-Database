IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_update_customer_Txn_limit]') AND type in (N'P', N'PC'))
DROP PROC  spa_update_customer_Txn_limit
GO
CREATE PROC spa_update_customer_Txn_limit
AS
BEGIN
SET NOCOUNT ON
--DROP TABLE #temp_7days
--DROP TABLE #temp_15days
--DROP TABLE #temp_1month
--DROP TABLE #temp_3month
--DROP TABLE #temp_6month
--DROP TABLE #temp_1Year
--DROP TABLE #temp_MoreThanYear
DECLARE @date DATETIME
SET @date=dbo.getDateHO(GETUTCDATE())
	---------------7 days----------------------

	SELECT customer_sno,c.CustomerId,COUNT(m.tranno) total_txn_send,SUM(paidAmt) total_amount INTO #temp_7days FROM dbo.moneySend m WITH(NOLOCK)
	JOIN dbo.customerDetail c WITH(NOLOCK) on c.sno=m.customer_sno 
	WHERE m.TransStatus NOT IN ('Cancel') AND  DATEDIFF(day,m.DOT,@date)<= 7
	AND customer_sno IS NOT NULL
	GROUP BY customer_sno,c.CustomerId

	UPDATE dbo.customer_limit_check SET days_7_amount=total_amount,days_7_count=total_txn_send  FROM #temp_7days t WITH(NOLOCK)
	JOIN dbo.customer_limit_check c ON c.customer_id=t.CustomerId AND c.customer_sno=t.customer_sno

	INSERT INTO dbo.customer_limit_check
			( customer_sno ,
			  customer_id ,
			  days_7_amount ,
			  days_7_count 
			)
	SELECT t.customer_sno,t.CustomerId,t.total_amount,t.total_txn_send  FROM #temp_7days t WITH(NOLOCK)
	LEFT outer JOIN dbo.customer_limit_check c WITH(NOLOCK) ON c.customer_id=t.CustomerId AND c.customer_sno=t.customer_sno
	WHERE c.customer_sno IS NULL
	DROP TABLE #temp_7days
	---------------15 days----------------------

	SELECT customer_sno,c.CustomerId,COUNT(m.tranno) total_txn_send,SUM(paidAmt) total_amount INTO #temp_15days FROM dbo.moneySend m WITH(NOLOCK)
	JOIN dbo.customerDetail c WITH(NOLOCK) on c.sno=m.customer_sno 
	WHERE m.TransStatus NOT IN ('Cancel') AND  DATEDIFF(day,m.DOT,@date)<= 15
	AND customer_sno IS NOT NULL
	GROUP BY customer_sno,c.CustomerId

	UPDATE dbo.customer_limit_check SET days_15_amount=total_amount,days_15_count=total_txn_send  FROM #temp_15days t WITH(NOLOCK)
	JOIN dbo.customer_limit_check c ON c.customer_id=t.CustomerId AND c.customer_sno=t.customer_sno

	INSERT INTO dbo.customer_limit_check
			( customer_sno ,
			  customer_id ,
			  days_15_amount ,
			  days_15_count 
			)
	SELECT t.customer_sno,t.CustomerId,t.total_amount,t.total_txn_send  FROM #temp_15days t WITH(NOLOCK)
	LEFT outer JOIN dbo.customer_limit_check c WITH(NOLOCK) ON c.customer_id=t.CustomerId AND c.customer_sno=t.customer_sno
	WHERE c.customer_sno IS NULL

	DROP TABLE #temp_15days
	---------------1 months----------------------
	SELECT customer_sno,c.CustomerId,COUNT(m.tranno) total_txn_send,SUM(paidAmt) total_amount INTO #temp_1month FROM dbo.moneySend m WITH(NOLOCK)
	JOIN dbo.customerDetail c WITH(NOLOCK) on c.sno=m.customer_sno 
	WHERE m.TransStatus NOT IN ('Cancel') AND  DATEDIFF(month,m.DOT,@date)<= 1
	AND customer_sno IS NOT NULL
	GROUP BY customer_sno,c.CustomerId

	UPDATE dbo.customer_limit_check SET days_30_amount=total_amount,days_30_count=total_txn_send  FROM #temp_1month t WITH(NOLOCK)
	JOIN dbo.customer_limit_check c ON c.customer_id=t.CustomerId AND c.customer_sno=t.customer_sno

	INSERT INTO dbo.customer_limit_check
			( customer_sno ,
			  customer_id ,
			  days_30_amount ,
			  days_30_count 
			)
	SELECT t.customer_sno,t.CustomerId,t.total_amount,t.total_txn_send FROM #temp_1month t WITH(NOLOCK)
	LEFT outer JOIN dbo.customer_limit_check c WITH(NOLOCK) ON c.customer_id=t.CustomerId AND c.customer_sno=t.customer_sno
	WHERE c.customer_sno IS NULL
	DROP TABLE #temp_1month
	---------------3 months----------------------

	SELECT customer_sno,c.CustomerId,COUNT(m.tranno) total_txn_send,SUM(paidAmt) total_amount INTO #temp_3month FROM dbo.moneySend m WITH(NOLOCK)
	JOIN dbo.customerDetail c WITH(NOLOCK) on c.sno=m.customer_sno 
	WHERE m.TransStatus NOT IN ('Cancel') AND  DATEDIFF(month,m.DOT,@date)<= 3
	GROUP BY customer_sno,c.CustomerId

	UPDATE dbo.customer_limit_check SET days_90_amount=total_amount,days_90_count=total_txn_send  FROM #temp_3month t WITH(NOLOCK)
	JOIN dbo.customer_limit_check c ON c.customer_id=t.CustomerId AND c.customer_sno=t.customer_sno

	INSERT INTO dbo.customer_limit_check
			( customer_sno ,
			  customer_id ,
			  days_90_amount ,
			  days_90_count 
			)
	SELECT t.customer_sno,t.CustomerId,t.total_amount,t.total_txn_send FROM #temp_3month t WITH(NOLOCK)
	LEFT outer JOIN dbo.customer_limit_check c WITH(NOLOCK) ON c.customer_id=t.CustomerId AND c.customer_sno=t.customer_sno
	WHERE c.customer_sno IS NULL
	DROP TABLE #temp_3month
	---------------6 months----------------------


	SELECT customer_sno,c.CustomerId,COUNT(m.tranno) total_txn_send,SUM(paidAmt) total_amount INTO #temp_6Month FROM dbo.moneySend m WITH(NOLOCK)
	JOIN dbo.customerDetail c WITH(NOLOCK) on c.sno=m.customer_sno 
	WHERE m.TransStatus NOT IN ('Cancel') AND  DATEDIFF(month,m.DOT,@date)<=6 
	GROUP BY customer_sno,c.CustomerId


	UPDATE dbo.customer_limit_check SET month_6_amount=total_amount,month_6_count=total_txn_send  FROM #temp_6Month t WITH(NOLOCK)
	JOIN dbo.customer_limit_check c ON c.customer_id=t.CustomerId AND c.customer_sno=t.customer_sno

	INSERT INTO dbo.customer_limit_check
			( customer_sno ,
			  customer_id ,
			  month_6_amount ,
			  month_6_count 
			)
	SELECT t.customer_sno,t.CustomerId,t.total_amount,t.total_txn_send  FROM #temp_6Month t WITH(NOLOCK)
	LEFT outer JOIN dbo.customer_limit_check c WITH(NOLOCK) ON c.customer_id=t.CustomerId AND c.customer_sno=t.customer_sno
	WHERE c.customer_sno IS NULL
	DROP TABLE #temp_6month
	---------------1 Year----------------------

	SELECT customer_sno,c.CustomerId,COUNT(m.tranno) total_txn_send,SUM(paidAmt) total_amount INTO #temp_1Year FROM dbo.moneySend m WITH(NOLOCK)
	JOIN dbo.customerDetail c WITH(NOLOCK) on c.sno=m.customer_sno 
	WHERE m.TransStatus NOT IN ('Cancel') AND  DATEDIFF(month,m.DOT,@date)<=12
	GROUP BY customer_sno,c.CustomerId

	UPDATE dbo.customer_limit_check SET year_1_amount=total_amount,year_1_count=total_txn_send  FROM #temp_1Year t WITH(NOLOCK)
	JOIN dbo.customer_limit_check c ON c.customer_id=t.CustomerId AND c.customer_sno=t.customer_sno

	INSERT INTO dbo.customer_limit_check
			( customer_sno ,
			  customer_id ,
			  year_1_amount ,
			  year_1_count 
			)
	SELECT t.customer_sno,t.CustomerId,t.total_amount,t.total_txn_send  FROM #temp_1Year t WITH(NOLOCK)
	LEFT outer JOIN dbo.customer_limit_check c WITH(NOLOCK) ON c.customer_id=t.CustomerId AND c.customer_sno=t.customer_sno
	WHERE c.customer_sno IS NULL

	DROP TABLE #temp_1Year
	---------------More Than 1 Year----------------------

	SELECT customer_sno,c.CustomerId,COUNT(m.tranno) total_txn_send,SUM(paidAmt) total_amount INTO #temp_MoreThanYear FROM dbo.moneySend m WITH(NOLOCK)
	JOIN dbo.customerDetail c WITH(NOLOCK) on c.sno=m.customer_sno 
	WHERE m.TransStatus NOT IN ('Cancel') 
	GROUP BY customer_sno,c.CustomerId


	UPDATE dbo.customer_limit_check SET year_more_amount=total_amount,year_more_count=total_amount  FROM #temp_MoreThanYear t WITH(NOLOCK)
	JOIN dbo.customer_limit_check c ON c.customer_id=t.CustomerId AND c.customer_sno=t.customer_sno

	INSERT INTO dbo.customer_limit_check
			( customer_sno ,
			  customer_id ,
			  year_more_amount ,
			  year_more_count 
			)
	SELECT t.customer_sno,t.CustomerId,t.total_amount,t.total_txn_send  FROM #temp_MoreThanYear t WITH(NOLOCK)
	LEFT outer JOIN dbo.customer_limit_check c WITH(NOLOCK) ON c.customer_id=t.CustomerId AND c.customer_sno=t.customer_sno
	WHERE c.customer_sno IS NULL
	DROP TABLE #temp_MoreThanYear
	
	UPDATE dbo.customer_limit_check SET updated_date=@date

END
