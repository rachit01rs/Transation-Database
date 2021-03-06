DROP PROCEDURE [dbo].[update_slab_paidCommission]
GO
-- update_slab_paidCommission 'EHENEMKFKHNI'
CREATE PROCEDURE [dbo].[update_slab_paidCommission]
	@refno VARCHAR(50)	
AS
BEGIN TRY
BEGIN TRANSACTION
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @rDate datetime,@rTime VARCHAR(20), @rGMTValue VARCHAR(10)
	DECLARE @sDate datetime,@sGMTValue VARCHAR(10),@tranno varchar(50),@expected_payoutagentid varchar(50)
	DECLARE @senderAgent VARCHAR(20),@HoDollarRate MONEY,@totalroundamt money 
	declare @agent_receiveingComm money,@agent_receiverComm_Currency char(1),@SempId varchar(50) 
	DECLARE @rBankId VARCHAR(100),@rBankBranch VARCHAR(100), @rBankName VARCHAR(100),@sending_country varchar(200)
	declare @payment_type varchar(200),@payout_settle_usd MONEY
	
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ GET Transaction Detail ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	SELECT @tranno=tranno,@expected_payoutagentid=expected_payoutagentid,@sending_country=senderCountry,
	@payment_type=paymentType,@totalroundamt=totalroundamt,@SempId=paidBy,@expected_payoutagentid=expected_payoutagentid,@payout_settle_usd=m.payout_settle_usd
	FROM moneysend m with (Nolock) join agentdetail a on a.agentcode=m.agentid 
	WHERE refno = @refno
	-- MAIN AGENT COMMISSION SLAB  
	select top 1 @agent_receiveingComm=commission_value,@agent_receiverComm_Currency=comm_currency_type from agent_branch_commission 
	where agent_code=@expected_payoutagentid 
	and case when country='all' then @sending_country else country end=@sending_country   
	and case when payment_mode='default' then @payment_type else payment_mode end=@payment_type   
	and case when paidValueCCY='d' then (@totalroundamt/@payout_settle_usd) else @totalroundamt end between min_amount and max_amount 
	order by case when country='all' then 'a' else country end desc,
	case when payment_mode='default' then 'a' else payment_mode end desc 


	---- MAIN AGENT COMMISSION
	--select @agent_receiveingComm=commission_value,@agent_receiverComm_Currency=comm_currency_type from agent_branch_commission 
	--where agent_code=@expected_payoutagentid and country=@sending_country and @totalroundamt between min_amount and max_amount
	--and payment_mode=@payment_type

	--if @agent_receiveingComm is null
	--	begin
	--		select @agent_receiveingComm=commission_value,@agent_receiverComm_Currency=comm_currency_type from agent_branch_commission 
	--		where agent_code=@expected_payoutagentid and country=@sending_country and @totalroundamt between min_amount and max_amount
	--		and payment_mode='Default'
	--	end
	--if @agent_receiveingComm is null
	--	begin
	--	select @agent_receiveingComm=commission_value,@agent_receiverComm_Currency=comm_currency_type from agent_branch_commission 
	--	where agent_code=@expected_payoutagentid and country='All' and @totalroundamt between min_amount and max_amount
	--	and payment_mode=@payment_type
	--	end
	--if @agent_receiveingComm is null
	--	begin
	--		select @agent_receiveingComm=commission_value,@agent_receiverComm_Currency=comm_currency_type from agent_branch_commission 
	--		where agent_code=@expected_payoutagentid and country='All' and @totalroundamt between min_amount and max_amount
	--		and payment_mode='Default'
	--	end

	if @agent_receiveingComm is null
		set @agent_receiveingComm=0

	UPDATE moneysend SET 
		agent_receiverCommission=@agent_receiveingComm,
		agent_receiverComm_Currency=@agent_receiverComm_Currency
	WHERE refno=@refno and receiveAgentId=@expected_payoutagentid and tranno=@tranno

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
	SELECT -1,@desc,'Update_Commission','SQL',@desc,'SQL','SP',@SempId,getdate()
	SELECT 'ERROR','1050','Error Please try again'

END CATCH





