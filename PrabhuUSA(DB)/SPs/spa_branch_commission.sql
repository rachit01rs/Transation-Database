
/****** Object:  StoredProcedure [dbo].[spa_branch_commission]    Script Date: 04/28/2014 13:46:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_branch_commission]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_branch_commission]
GO


/****** Object:  StoredProcedure [dbo].[spa_branch_commission]    Script Date: 04/28/2014 13:46:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*  
** Database    : PrabhuUsa
** Object      : spa_branch_commission
** Purpose     : defined commission
** 
** Modification:
**	modified by : Sunita Shrestha
**	Date        : 23rd May 2014
**	modified    : filtered for  Amount Currency by  Country and Payment Type
** 
*/ 
--spa_search_agent 's','Nepal',NULL
create PROCEDURE [dbo].[spa_branch_commission]
@flag char(1),
@sno int=NULL,
@branch_code varchar(50)=NULL,
@country varchar(100)=NULL,
@commission_value float=0,
@commission_type  char(1)='p',
@updated_by varchar(50)=NULL,
@updated_date datetime=NULL,
@lb_agent varchar(50)=NULL,
@comm_currency char(1)=NULL,
@min_amount money=NULL,
@max_amount money=NULL,
@payment_mode varchar(50)=NULL,
@sendAgentCode varchar(50)=NULL,
@amt_currency CHAR(1)=NULL ----for  MIn and Max CCY Type 
as
BEGIN
	SET NOCOUNT ON
if @country is NULL
	set @country='All'

declare @sql_stat varchar(5000)

declare @agent_code varchar(50)
SET @agent_code=@branch_code

if @flag='s'
begin

	if UPPER(@country)='AGENT'
	begin
		SELECT  sno,c.country,commission_value, upper(commission_type) commission_type,comm_currency_Type,
		min_amount,max_amount,payment_mode,sendAgentCode,isNULL(s.CompanyName,'ALL') agentName,paidValueCCY FROM  agent_branch_commission c left outer join agentdetail s on c.sendAgentCode=s.agentcode
		where agent_code=@agent_code order by payment_mode,min_amount,c.country
	end
	else
	begin
		SELECT  sno,c.country,commission_value, upper(commission_type) commission_type,comm_currency_Type,
		min_amount,max_amount,payment_mode,sendAgentCode,isNULL(s.CompanyName,'ALL') agentName,paidValueCCY FROM  agent_branch_commission c left outer join agentdetail s on c.sendAgentCode=s.agentcode
		where agent_branch_code=@branch_code order by payment_mode,min_amount,c.country
	end
end
else if @flag='i'
begin

if UPPER(@lb_agent)='AGENT'
	set @branch_code=Null
else
	set @agent_code=Null

	if exists (SELECT 'x' FROM  agent_branch_commission WITH(nolock) where payment_mode=@payment_mode  and country=@country AND agent_code=@agent_code )
		begin
			IF NOT EXISTS (SELECT 'x' FROM  agent_branch_commission WITH(nolock) where payment_mode=@payment_mode  AND
			 country=@country AND agent_code=@agent_code AND paidValueCCY=@amt_currency)
			 BEGIN
			 	 SELECT 'Error' STATUS, 'The amount currency should not be different for same Country and same Payment Type' msg
			 RETURN
			 END
			
		end
	if exists (SELECT 'x' FROM  agent_branch_commission WITH(nolock) where agent_branch_code=@branch_code and country=@country)
	begin
		IF NOT EXISTS (SELECT 'x' FROM  agent_branch_commission WITH(nolock) where payment_mode=@payment_mode  AND
			 country=@country AND agent_branch_code=@branch_code AND paidValueCCY=@amt_currency)
			 BEGIN
			 	 SELECT 'Error' STATUS, 'The amount currency should not be different for same Country and same Payment Type' msg
			 RETURN
			 END
	end
	IF  @min_amount > @max_amount
	begin
		select 'Error' status,'The Max Amt. Should be greater than Min Amt' msg
		return
	end	
	else if exists (SELECT * FROM  agent_branch_commission WITH(nolock) where agent_code=@agent_code and country=@country and payment_mode=@payment_mode 
	and isNULL(sendAgentCode,'All')=isNULL(@sendAgentCode,'All'))
	begin 	

		Declare @maxamtpp money
		set	@maxamtpp=(select max([max_amount])from [agent_branch_commission] WITH(nolock) where [agent_code]=@agent_code and [payment_mode]=@payment_mode and [country]=@country and isNULL(sendAgentCode,'All')=isNULL(@sendAgentCode,'All'))+0.01 
        
	IF @min_amount <> @maxamtpp
			begin
				select 'Error' status,'The Amount range is already defined, Please Redefine Min. Amt. from...'+cast(@maxamtpp as varchar)+'!!!' msg
				return
	
		END
	
	end


	begin

	select 'Success' status
		insert agent_branch_commission(
		agent_branch_code,
		country,
		commission_value,
		commission_type,
		updated_by,
		updated_date,
		agent_code,
		comm_currency_Type,
        min_amount,
		max_amount,
        payment_mode,
		sendAgentCode,
		paidValueCCY)
		values(
		@branch_code,
		@country,
		@commission_value,
		@commission_type,
		@updated_by,
		@updated_date,
		@agent_code,
		@comm_currency,
        @min_amount,
        @max_amount,
        @payment_mode,
		@sendAgentCode,
		@amt_currency)
		
	end
end
else if @flag='d'
begin
	delete agent_branch_commission where sno=@sno
	if @@error <> 0 
		select 'Error' status
	else
		select 'Success' status
end
end



GO


