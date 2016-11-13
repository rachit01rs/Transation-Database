USE [PrabhuUsa]
GO
/****** Object:  StoredProcedure [dbo].[spa_SendRupiyaCard_TXN]    Script Date: 03/03/2015 16:32:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[spa_SendRupiyaCard_TXN]
(
	@FLAG CHAR = NULL,
	@PAYMENT_STATUS VARCHAR(50) = NULL,
	@TRAN_STATUS VARCHAR(50) = NULL,
	@REFNO VARCHAR(50) = NULL,
	@FROM_DATE VARCHAR(100) = NULL,
	@TO_DATE VARCHAR(100) = NULL,
	@BRANCH VARCHAR(50) = NULL,
	@AGENT VARCHAR(50) = NULL,
	@CONTROL_NO VARCHAR(50) = NULL
)
AS
BEGIN
	IF @FLAG = 's' --- SELECT TRANSACTION DETAIL FOR API TO SEND TRANSACTION
	BEGIN
		SELECT TOP 1 dbo.decryptDb(m.refno) CONTROL_NO, m.* INTO #temp
		FROM moneySend m
		WHERE 
		m.status = 'Un-Paid'
		AND m.TransStatus = 'Payment'
		AND m.ReceiverCountry = 'Nepal'
		AND m.paymentType = 'Remittance Card'
		AND ISNULL(is_downloaded,'n')='n'
		ORDER BY Tranno ASC
		
		UPDATE moneySend SET is_downloaded='y',downloaded_ts=GETDATE()
		FROM moneysend m JOIN #temp t
		ON m.Tranno=t.Tranno
		
		SELECT * FROM #temp 
	END
	
	IF @FLAG = 'u'
	BEGIN
		UPDATE moneysend 
		SET 
		status		=	@PAYMENT_STATUS,
		TransStatus	=	@TRAN_STATUS
		WHERE refno =	DBO.ENCRYPTDB(@REFNO) 
		AND is_downloaded = 'y'
	END
	
	IF @FLAG = 'g' -- GET UNPAID TXNS WHICH HAVE BEEN PREVIOUSLY PICKED FOR API PAYMENT
	BEGIN
		SELECT * FROM moneySend m WHERE 
		m.status = 'Un-Paid'
		AND m.TransStatus = 'Payment'
		AND m.ReceiverCountry = 'Nepal'
		AND m.paymentType = 'Remittance Card'
		AND ISNULL(is_downloaded,'n')='y'
	END
	
	IF @FLAG = 'r'
	BEGIN
		UPDATE moneySend
		SET 
		is_downloaded = 'n'
		WHERE refno =	DBO.ENCRYPTDB(@REFNO)
		AND status = 'Un-Paid'
		AND TransStatus = 'Payment'
		AND is_downloaded = 'y'
	END	
	
	IF @FLAG='v'
	BEGIN
	
	DECLARE @sql VARCHAR(5000)
		SET @sql='select m.refno,m.SenderName,m.ReceiverName,m.confirmDate,m.status,m.TotalRoundAmt 
					from moneySend m JOIN agentDetail ad
					on m.agentid=ad.agentCode JOIN agentbranchdetail abd
					on m.Branch_code=abd.agent_branch_Code
					WHERE
					m.TransStatus = ''Payment''
					AND m.paymentType=''Remittance Card''
					AND m.ReceiverCountry = ''Nepal''
					AND confirmDate between''' + @FROM_DATE+'''AND'''+@TO_DATE + ' 23:59:59'''	
		
	IF @REFNO is not null
	BEGIN
		SET @sql=@sql+'AND refno= dbo.encryptdb( '+@REFNO + ') '
	END
	
	IF @TRAN_STATUS IS NOT NULL
	BEGIN
		SET @sql=@sql+'AND status='''+ @TRAN_STATUS + ''''
	END
	
	IF @AGENT IS NOT NULL
	BEGIN
		SET @sql=@sql+'AND agentid='''+ @AGENT +''''	
	END
	
	IF @BRANCH IS NOT NULL
	BEGIN
		SET	@sql=@sql+'AND Branch_code='''+ @BRANCH+''''
	END

	print (@sql)
	EXEC(@sql)
	END
	
	IF @FLAG = 't' 
	BEGIN
		SELECT dbo.decryptDb(m.refno) CONTROL_NO, m.* INTO #temp1
		FROM moneySend m
		WHERE 
		m.status = 'Un-Paid'
		AND	m.refno= dbo.encryptDb(@CONTROL_NO)
		AND m.TransStatus = 'Payment'
		AND m.ReceiverCountry = 'Nepal'
		AND m.paymentType = 'Remittance Card'
		ORDER BY Tranno ASC
		
		SELECT * FROM #temp1 
	END

END

