IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_txn_status]') AND type in (N'P', N'PC'))
DROP PROC spa_get_txn_status
GO
CREATE PROC spa_get_txn_status
@sno INT 
AS
BEGIN
SET NOCOUNT ON

--DECLARE @sno INT
--SET @sno=6152
--DROP TABLE #temp
--DROP TABLE #temp_moneysend

	SELECT ISNULL(month_6_amount,0) month_6_amount,ISNULL(year_1_amount,0) year_1_amount,
	ISNULL(month_6_count,0) month_6_count,ISNULL(year_1_count,0) year_1_count ,updated_date,customer_id,customer_sno  INTO #temp 
	FROM dbo.customer_limit_check WHERE customer_sno=@sno
	 declare @tranno bigint,@dot datetime ,@dottime varchar(20),@txnDate datetime,@txn_amt varchar(50)
	DECLARE @updated_date DATETIME
	SELECT @updated_date=updated_date FROM #temp
--	SELECT * FROM #temp
	 set @dot=convert(varchar,@updated_date,101)                    
	 set @dottime=convert(varchar,@updated_date,108)  

		SELECT customer_sno,c.CustomerId,COUNT(m.tranno) total_txn_send,SUM(paidAmt) total_amount 
		INTO #temp_moneysend
		FROM dbo.moneySend m WITH(NOLOCK)
		JOIN dbo.customerDetail c WITH(NOLOCK) on c.sno=m.customer_sno 
		WHERE m.TransStatus NOT IN ('Cancel') AND  DOT>=@dot AND DOtTime>@dottime
		AND customer_sno=@sno
		GROUP BY customer_sno,c.CustomerId
	--	SELECT * FROM #temp_moneysend
		
		
		create table #temp_result( txnDate datetime, txn_amt varchar(50) ,
month_6_amount varchar(50),year_1_amount varchar(50),month_6_count varchar(50),year_1_count varchar(50),customer_id varchar(50),customer_sno varchar(50))
		
insert into #temp_result(txnDate,txn_amt,customer_id,customer_sno)
select top 1 local_dot,paidamt,customerid,customer_sno from moneysend with(nolock) where customer_sno=@sno 
		and TransStatus NOT IN ('Cancel') order by local_dot desc
update #temp_result set month_6_amount= ISNULL(t.month_6_amount,0)+ISNULL(tm.total_amount,0) ,
		year_1_amount  =ISNULL(t.year_1_amount,0)+ISNULL(tm.total_amount,0) ,
		month_6_count = ISNULL(t.month_6_count,0)+ISNULL(tm.total_txn_send,0) ,
		year_1_count= ISNULL(t.year_1_count,0)+ISNULL(tm.total_txn_send,0)   
		From #temp_result te join #temp t on t.customer_sno=te.customer_sno 
		LEFT OUTER JOIN #temp_moneysend tm ON t.customer_id=tm.CustomerId 
		AND t.customer_sno=tm.customer_sno 
--		SELECT @txnDate txnDate,@txn_amt txn_amt,
--		ISNULL(month_6_amount,0)+ISNULL(total_amount,0) month_6_amount,
--		ISNULL(year_1_amount,0)+ISNULL(total_amount,0) year_1_amount,
--		ISNULL(month_6_count,0)+ISNULL(total_txn_send,0) month_6_count,
--		ISNULL(year_1_count,0)+ISNULL(total_txn_send,0) year_1_count ,t.customer_id,t.customer_sno 
--		FROM #TEMP t LEFT OUTER JOIN #temp_moneysend tm ON t.customer_id=tm.CustomerId AND t.customer_sno=tm.customer_sno 
select * from #temp_result
	
END	

