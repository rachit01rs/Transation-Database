 DROP PROC [dbo].[spa_transaction_summary_report]  
go
--spa_transaction_summary_report 'a','local_dot','06/21/2009','06/21/2009'  
create PROC [dbo].[spa_transaction_summary_report]  
 @flag char(1),  
 @dateType varchar(50)=NULL,  
 @fromDaTe varchar(50)=NULL,  
 @toDate varchar(50)=NULL,  
 @branch_code varchar(50)=NULL,  
 @agentCode varchar(50)=NULL,  
 @receiveCountry varchar(50)=NULL,  
 @receive_agent_id varchar(50)=NULL,  
 @trn_status varchar(50)=NULL,  
-- @order_table char(1)=NULL,  
 @order_by varchar(100)=NULL  
  
AS  
DECLARE @sql varchar(8000),@order_by_tot varchar(3),@default_order varchar(50)  
SET @default_order=upper('agentName')  
--PRINT LEFT(@order_by,len(@default_order))  
--PRINT @default_order  
IF @order_by IS NOT NULL AND upper(LEFT(@order_by,len(@default_order)))<>upper(@default_order)  
BEGIN  
SET @order_by='ORDER BY '+ @default_order +','+ @order_by  
--SET @order_by_tot='ZZZ'  
END  
ELSE  
BEGIN  
SET @order_by= 'ORDER BY '+ @default_order  
--SET @order_by_tot='000'  
END  
IF RIGHT(@order_by,4)='desc'  
SET @order_by_tot='000'  
ELSE  
SET @order_by_tot='ZZZ'  
  
IF @flag='c'  
 SET @dateType='cancel_date'  
SET @sql='SELECT CASE WHEN (GROUPING(agentName) = 1) THEN ''ZZZZZ'' WHEN (GROUPING(branch) = 1) THEN ISNULL(agentName, ''UNKNOWN'')+'' (Total)''  
 ELSE ISNULL(agentName, ''UNKNOWN'') END AS agentName,  
 CASE WHEN (GROUPING(branch) = 1) THEN '''+@order_by_tot+'Total'' ELSE ISNULL(branch, ''UNKNOWN'') END AS branch,  
 min(paidCtype) paidCtype,sum(paidAmt) paidAmt,sum(Sender_Charge) Sender_Charge,sum(SCharge) SCharge,  
 sum(dollar_amt) dollar_amt,sum(NPR_Amt) NPR_Amt,sum(TotNos) TotNos,sum(SCommDollar) SCommDollar,  
 sum(SChargeDollar) SChargeDollar FROM   
 (  
 SELECT a.companyname agentName,b.branch,  
 min(paidCtype) paidCtype, SUM(paidAmt) AS paidAmt,sum(senderCommission) Sender_Charge,  
 sum(sCharge) SCharge,sum(dollar_amt) dollar_amt,sum(TotalRoundAmt) NPR_Amt,count(tranno) TotNos,  
 sum(senderCommission/exchangeRate) SCommDollar, sum((sCharge)/exchangeRate) SChargeDollar FROM moneysend m  
 JOIN agentbranchdetail b on m.branch_code=b.agent_branch_code  
join agentdetail a on a.agentcode=m.agentid
 where '+@dateType+' between '''+@fromDate+''' and '''+@toDate+' 23:59:59'''  
 IF @agentCode IS NOT NULL  
 SET @sql=@sql +' and agentid='''+@agentCode+''''  
 IF @flag='n'  
 SET @sql=@sql +' and TransStatus not in (''Cancel'')'  
 IF @branch_code IS NOT NULL  
 SET @sql=@sql +' and branch_code='''+ @branch_code +''''  
 IF @agentCode  IS NOT NULL  
 SET @sql=@sql +' and agentid='''+ @agentCode +''''  
 IF @receiveCountry IS NOT NULL  
 SET @sql=@sql +' and receiverCountry='''+ @receiveCountry +''''  
 IF @receive_agent_id IS NOT NULL  
 SET @sql=@sql +' and expected_payoutagentid='''+ @receive_agent_id +''''  
 if @trn_status IS NOT NULL   
 SET @sql=@sql +' and status='''+@trn_status+''''  
 SET @sql=@sql +' GROUP BY b.branch,a.companyname'  
IF @flag='a'  
begin  
 SET @sql=@sql +'  UNION ALL   
 SELECT a.companyName agentName,branch,  
 a.currencyType paidCtype, 0 AS paidAmt,0 Sender_Charge,  
 0 SCharge,0 dollar_amt,0 NPR_Amt,0 TotNos,  
 0 SCommDollar, 0 SChargeDollar FROM agentbranchdetail b JOIN agentdetail a ON a.agentCode=b.agentCode  
 WHERE 1=1'  
 IF @agentCode IS NOT NULL  
 SET @sql=@sql +' AND b.agentcode='''+@agentCode+''''  
 IF @branch_code IS NOT NULL  
 SET @sql=@sql +' and agent_branch_code='''+ @branch_code +''''  
 SET @sql=@sql +' AND a.agentType in (''Send and Pay'',''Sender Agent'') and   
 a.agentcan in (''SenderReceiver'',''Sender'')'  
 SET @sql=@sql +' GROUP BY branch,companyName,a.currencyType '  
end  
SET @sql=@sql +'  )l  
  GROUP BY branch,agentName WITH ROLLUP '+ @order_by  
  
--PRINT @sql  
EXEC (@sql)  
  
  
  