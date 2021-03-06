GO
/****** Object:  StoredProcedure [dbo].[spa_customer_category_report]    Script Date: 06/13/2013 15:22:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_customer_category_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_customer_category_report]SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_customer_category_report](
	@flag			VARCHAR(1)		= NULL,
	@sendAgent		VARCHAR(50)		= NULL,
    @receivingCountry VARCHAR(50)	= NULL,
    @payoutAgent	VARCHAR(50)		= NULL,
    @custCategory	VARCHAR(10)		= NULL,
    @fromDate		VARCHAR(50)		= NULL,
    @toDate			VARCHAR(50)		= NULL,
    @dateType		varchar(50)		= NULL
)
AS
BEGIN
	DECLARE @sqlstmt VARCHAR(5000)      
	DECLARE @clm_name VARCHAR(5000) 
	
	SET @clm_name='m.tranno,m.refno,m.branch,sendername,senderphoneno,receivername,receiverphone,rbankid,a.companyname							rbankname,rbankbranch,local_dot,paiddate,paidamt,totalroundamt,sempid,senderbankvoucherno,transstatus,						m.status,rbankactype,rbankacno,paymenttype,senderCompany,scharge,receiveCType,a.agent_short_code,m.							today_dollar_rate,exchangeRate,paidby,request_for_new_account,PaidcType,expected_payoutagentid								receiveAgentID,receiverCommission,SCharge ' 

	IF @flag = 'd'---detail report
	BEGIN
		SET @sqlstmt = 'select ' + @clm_name + 'from moneysend as m join agentdetail a      
					on a.agentcode=m.expected_payoutagentid JOIN customer_category_setup ccs 
					ON m.customer_category_id=ccs.id WHERE 1=1' 
					
--		SET @sqlstmt = 'select ' + @clm_name + 'from moneysend as m join agentdetail a      
--					on a.agentcode=m.expected_payoutagentid WHERE 1=1' 
					
		IF @sendAgent is NOT NULL
		BEGIN
			SET @sqlstmt = @sqlstmt+' and m.agentid='+@sendAgent 
		END
		IF @receivingCountry is NOT NULL
		BEGIN
			SET @sqlstmt = @sqlstmt+' and m.receiverCountry='''+@receivingCountry+'''' 
		END
		IF @payoutAgent is NOT NULL
		BEGIN
			SET @sqlstmt = @sqlstmt+' and m.expected_payoutagentid='+@payoutAgent 
		END
		IF @custCategory is NOT NULL
		BEGIN
			SET @sqlstmt = @sqlstmt+' and m.customer_category_id='+@custCategory 
		END
		IF @fromDate is NOT NULL
		BEGIN
			SET @sqlstmt = @sqlstmt+' and m.'+@dateType+' between '''+ @fromDate +''' and '''+ @toDate +' 23:59:59''' 
		END
		
		EXEC(@sqlstmt)
		PRINT @sqlstmt
	END
	
	IF @flag = 's' ----summary report
	BEGIN
		SET @sqlstmt='select convert(varchar,'+@dateType+',101) dot,count(*) as No_of_Tran, r.CompanyName,receivectype,  
sum(SCharge) as sCharge, sum(totalRoundAmt)as TotalRoundAmt from moneysend m join agentdetail r on r.agentcode=m.expected_payoutagentid   
where m.transStatus<>''Cancel'' and '+ @dateType +' between '''+ @fromDate +''' and '''+ @toDate +' 23:59:59 ''' 

		IF @sendAgent is NOT NULL
		BEGIN
			SET @sqlstmt = @sqlstmt+' and m.agentid='+@sendAgent 
		END
		IF @receivingCountry is NOT NULL
		BEGIN
			SET @sqlstmt = @sqlstmt+' and m.receiverCountry='''+@receivingCountry+'''' 
		END
		IF @payoutAgent is NOT NULL
		BEGIN
			SET @sqlstmt = @sqlstmt+' and m.expected_payoutagentid='+@payoutAgent 
		END
			IF @custCategory is NOT NULL
			BEGIN
				SET @sqlstmt = @sqlstmt+' and m.customer_category_id='+@custCategory 
			END
		IF @fromDate is NOT NULL
		BEGIN
			SET @sqlstmt = @sqlstmt+' and m.confirmDate between '''+ @fromDate +''' and '''+ @toDate +' 23:59:59''' 
		END
	
		set @sqlstmt=@sqlstmt+ ' group by convert(varchar,'+@dateType+',101),r.CompanyName,receivectype '    
		set @sqlstmt=@sqlstmt+ ' order by convert(varchar,'+@dateType+',101),r.CompanyName '
		
		print @sqlstmt        
		exec(@sqlstmt) 
	END
END