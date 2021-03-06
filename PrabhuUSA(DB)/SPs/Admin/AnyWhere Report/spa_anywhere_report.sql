IF OBJECT_ID('[spa_anywhere_report]', 'P') IS NOT NULL 
    DROP PROC dbo.spa_anywhere_report
GO
/*
** Database : PrabhuUSA
** Object : [spa_anywhere_report]
**
** Purpose : 
** @flag='a'--count data with respect to companyName  and country
** @flag='s'--select detail report form the moneysend table and agentdetail
**  
** Author: Kanchan Dahal 
** Date:    30th jan 2012
**
** Modifications:
**		
**	
**		
** Execute Examples :
**  

*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_anywhere_report] 
	-- Add the parameters for the stored procedure here
	@flag VARCHAR(1) = NULL ,
	@agentId VARCHAR(50) = NULL ,
    @fromDate VARCHAR(50) = NULL ,
    @toDate VARCHAR(50) = NULL,
    @expectedPayoutAgentId VARCHAR(50)= NULL,
    @receivingCountry VARCHAR(50)= NULL
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @sql VARCHAR(MAX)

	IF @flag='a'--count data with respect to companyName  and country
	BEGIN
		set @sql='SELECT m.expected_payoutagentid,ag.companyName paidBy,a.companyName,m.payout_send_agent_id,
		COUNT(*) AS Total_txn,a.country AS country ,sum(m.TotalRoundAmt) TotalRoundAmt
		FROM moneysend m WITH(NOLOCK) JOIN
		agentdetail a WITH(NOLOCK) ON m.payout_send_agent_id=a.agentcode JOIN
		agentdetail ag WITH(NOLOCK) ON m.expected_payoutagentid=ag.agentcode
		WHERE
		m.paidDate IS NOT NULL AND   
		m.transstatus in (''Payment'') AND 
		m.status in (''Paid'') AND
		--isnull(a.restrict_anywhere_payment,''n'') IN (''x'',''n'') AND 
		m.paidDate between '''+@fromDate+''' and '''+@toDate+''''
		IF @agentId IS NOT NULL
			set @sql= @sql +' AND m.payout_send_agent_id='''+@agentId +''''
		IF @receivingCountry IS NOT NULL
			set @sql= @sql +' AND m.ReceiverCountry='''+@receivingCountry +''''
		set @sql= @sql +'   
		          GROUP BY 
		m.expected_payoutagentid,ag.companyName,a.companyName,m.payout_send_agent_id,a.country
		ORDER BY a.country,a.companyName'
		PRINT(@sql)
		EXEC(@sql)
	END
	
	IF @flag='s'--select detail report form the moneysend table and agentdetail   
	BEGIN
		set @sql='SELECT * 
		FROM moneysend m WITH(NOLOCK) JOIN
		agentdetail a WITH(NOLOCK) ON m.payout_send_agent_id=a.agentcode JOIN
		agentdetail ag WITH(NOLOCK) ON m.expected_payoutagentid=ag.agentcode
		WHERE
		m.paidDate IS NOT NULL AND   
		m.transstatus in (''Payment'') AND 
		m.status in (''Paid'') AND
		--isnull(a.restrict_anywhere_payment,''n'') IN (''x'',''n'') AND 
		m.paidDate between '''+@fromDate+''' and '''+@toDate+''''
		set @sql= @sql +' AND m.payout_send_agent_id='''+@agentId +''''
		IF @agentId IS NOT NULL
			set @sql= @sql +' AND m.expected_payoutagentid='''+@expectedPayoutAgentId +''''
		IF @receivingCountry IS NOT NULL
			set @sql= @sql +' AND m.ReceiverCountry='''+@receivingCountry +''''
		set @sql= @sql +'ORDER BY a.country,a.companyName'
		--PRINT(@sql)
		EXEC(@sql)
	END	
END
