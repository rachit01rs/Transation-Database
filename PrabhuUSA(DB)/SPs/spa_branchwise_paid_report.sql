---spa_branchwise_paid_report @expectedPayoutAgentid=NULL,@agentid=NULL,@payoutCountry='Nepal',@fromDate='2013-01-01',@todate='2013-10-13'
DROP PROC spa_branchwise_paid_report
GO
CREATE PROCEDURE spa_branchwise_paid_report
@expectedPayoutAgentid VARCHAR(50)=NULL,
@agentid  VARCHAR(50)=NULL, 
@payoutCountry VARCHAR(100)=NULL,
@fromDate VARCHAR(50)=NULL,
@todate VARCHAR(50)=NULL
AS
BEGIN
SET NOCOUNT OFF;
  DECLARE @sql VARCHAR(max)
  SET @todate= @todate +' 23:59:59:998'
  
   SET @sql=' select pa.CompanyName [Bank/Agent Name],pa.Address[Bank/Agent Address],b.Branch [Branch Name],
    b.agent_branch_Code[Branch Code],ISNULL(b.branch_group,b.City)[District Name],COUNT(m.Tranno) [No. of txn] ,SUM(m.TotalRoundAmt) [Amount] FROM
     moneysend m with(NOLOCK) JOIN agentbranchdetail b with(NOLOCK) ON b.agent_branch_code=m.rBankId 
     JOIN agentdetail pa with(NOLOCK) ON pa.agentcode=b.agentcode WHERE pa.accessed=''Granted'' and isNUll(pa.non_IRH_AGENT,''n'')=''n'' and  m.Transstatus = ''Payment'' AND m.status=''Paid'' AND m.paidDate BETWEEN '''+@fromDate+''' AND '''+@todate+'''' 
     IF @payoutCountry IS NOT NULL
		SET @sql= @sql+' AND m.ReceiverCountry='''+@payoutCountry+''''
     IF @expectedPayoutAgentid IS NOT NULL
		SET @sql= @sql+' AND m.rBankId ='''+@expectedPayoutAgentid+''''
     IF @agentid IS NOT NULL
		SET @sql= @sql+' AND b.agentcode='''+@agentid+''''
    SET @sql= @sql+' GROUP BY pa.CompanyName,pa.Address,b.Branch,b.agent_branch_Code,ISNULL(b.branch_group,b.City),pa.Address ORDER BY  pa.CompanyName,b.Branch'
 EXEC(@sql)
 --PRINT(@sql)
END

