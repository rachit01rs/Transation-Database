/****** Object:  StoredProcedure [dbo].[spa_tranglo_transaction]    Script Date: 06/22/2011 14:07:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_tranglo_transaction]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_tranglo_transaction]
GO
/****** Object:  StoredProcedure [dbo].[spa_tranglo_transaction]    Script Date: 06/22/2011 14:07:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_tranglo_transaction]
	@flag CHAR(1),
	@refno VARCHAR(50)=null,
	@tranno int,
	@SempId VARCHAR(50)=null,
	@expected_payoutagentid VARCHAR(50)=null,
	@GNT VARCHAR(80)=NULL,
	@tranglotranId VARCHAR(80)=NULL,
	@LastBal money=null,
	@DIG_INFO varchar(50)=null
	
AS
BEGIN TRY
BEGIN TRANSACTION
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
	DECLARE @rDate datetime,@rTime VARCHAR(20), @rGMTValue int
	DECLARE @sDate datetime,@sGMTValue int,@process_id varchar(500)
	DECLARE @senderAgent VARCHAR(20),@HoDollarRate MONEY,@totalroundamt money ,@agent_receiveingComm money,@agent_receiverComm_Currency char(1)
	DECLARE @rBankId VARCHAR(100),@rBankBranch VARCHAR(100), @rBankName VARCHAR(100),@sending_country varchar(200),@payment_type varchar(200)
	
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ GET GMT VALUES OF SENDER AND RECEIVER ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	SELECT @senderAgent=agentid, @HoDollarRate=ho_dollar_rate,@rGMTValue=pb.GMT_value,
	@sending_country=senderCountry,
	@payment_type=paymentType,@totalroundamt=totalroundamt,@process_id=confirm_process_id
	FROM moneysend m with (Nolock) join agentdetail a on a.agentcode=m.agentid 
	join agentdetail pb on m.expected_payoutagentid=pb.agentcode
	WHERE m.receiveAgentId=@expected_payoutagentid AND refno = @refno
	and tranno=@tranno
	
	SELECT @sGMTValue=GMT_value,
	@sDate=dateadd(mi,GMT_value,getutcdate()) FROM agentDetail a join agent_function f on agent_id=a.agentcode 
	WHERE a.agentcode=@senderAgent

	SET @rDate	= dateadd(mi,@rGMTValue,getutcdate()) 
	
	-- dbo.CTgetGMTDate( getUTCDate(),@rGMTValue,1)
	
	-- MAIN AGENT COMMISSION
	select @agent_receiveingComm=commission_value,@agent_receiverComm_Currency=comm_currency_type from agent_branch_commission 
	where agent_code=@expected_payoutagentid and country=@sending_country and @totalroundamt between min_amount and max_amount
	and payment_mode=@payment_type
	

	SET @rTime	=  dbo.CTgetGMTDate( getUTCDate(),@rGMTValue,2)
	UPDATE moneysend SET 
		refno=dbo.encryptdb(@GNT),
		status='Paid',
		transStatus='Payment',
		PodDate=cast(@rDate as varchar),
		paidDate	= cast(@rDate as varchar), 
		paidTime	= isNull(@rTime,getdate()),
		confirmDate	= cast(@sDate as varchar), 
		paidBy	= 'Tranglo',
		approve_by	= isNULL(@SempId,'Tanglo'),
		imeCommission=0, 
		bankCommission=0, 
		paid_date_usd_rate=cast(isNULL(@HoDollarRate,'') as varchar),
		TestQuestion= cast(isnULL(@GNT,'') as varchar),
		confirm_process_id= cast(isNULL(@tranglotranId,'') as varchar),
		TestAnswer	= isNULL(@LastBal,''),
		digital_id_payout=@DIG_INFO,
		lock_status='unlocked',
		agent_receiverCommission=@agent_receiveingComm,
		agent_receiverComm_Currency=@agent_receiverComm_Currency
	WHERE refno=@refno and receiveAgentId=@expected_payoutagentid and tranno=@tranno

	update agentdetail set currentBalance=@LastBal where agentcode=@expected_payoutagentid

--declare @sql varchar(1000)

--set @sql='spRemote_sendTrns ''i'','''+cast(@tranno as varchar(20))+''','''+@SempId+''','''+@senderAgent+''','''+ cast(isNULL(@tranglotranId,'') as varchar) +''',''y'''
--print @sql
--EXEC (@sql)
--set @refno=dbo.encryptdb(@GNT)

--exec ('PrabhuCash.dbo.update_slab_paidCommission '''+@refno+'''')

SELECT 'Success' status, @tranno tranno,@refno refno
END

COMMIT TRANSACTION
END TRY
BEGIN CATCH

if @@trancount>0 
	ROLLBACK TRANSACTION

	DECLARE @desc VARCHAR(1000)
	SET @desc='SQL Error found:  (' + ERROR_MESSAGE() + ')'
	
	
	INSERT INTO [error_info]
           ([ErrorNumber]
           ,[ErrorDesc]
           ,[Script]
           ,[ErrorScript]
           ,[QueryString]
           ,[ErrorCategory]
           ,[ErrorSource]
           ,[IP]
           ,[error_date])
	SELECT -1,@desc,'tranglo_transaction','SQL',@desc,'SQL','SP',@SempId,getdate()
	SELECT 'ERROR','1050','Error Please try again'

END CATCH