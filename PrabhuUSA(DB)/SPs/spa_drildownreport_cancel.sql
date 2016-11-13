 DROP PROCEDURE [dbo].[spa_drildownreport_cancel]    
GO   
  
CREATE PROCEDURE [dbo].[spa_drildownreport_cancel]            
 @flag char(1),            
 @senderAgent varchar(50)=NULL,            
 @receiveCountry varchar(100)=NULL,            
 @payoutAgent varchar(50)=NULL,            
 @payoutBranch varchar(50)=NULL,            
 @statusType varchar(100)=NULL,            
 @paymentType varchar(100)=NULL,            
 @dateType varchar(50)=NULL,            
 @fromDate varchar(50)=NULL,            
 @toDate varchar(50)=NULL,          
 @senderAgentName varchar(200)=NULL,            
 @senderBranch varchar(200)=NULL,            
 @senderCountry varchar(200)=NULL,            
 @sendCountry varchar(50)= NULL,    
  @senderAgent_state  varchar(50)=NULL              
AS            
DECLARE @sql varchar(8000) , @send_fx_clm VARCHAR(5000),  
@collected_dollar_amount VARCHAR(5000),@SC_Dollar_amount VARCHAR(5000),  
@SC_Settlement_USD VARCHAR(5000),@SCommDollar VARCHAR(5000)  
  
set @send_fx_clm=' (case when ho_dollar_rate is NUll then exchangeRate * agent_settlement_rate else ho_dollar_rate end) '  
  
set @collected_dollar_amount=' case when a.ext_settlement_clm=''totalroundamt'' then  
    totalroundamt/'+@send_fx_clm+'  
   else   
    dollar_amt  
  end '  
 SET @SC_Dollar_amount='case when a.ext_settlement_clm=''totalroundamt'' then   
   (sCharge-(senderCommission))/exchangeRate  
  else  
  Scharge/exchangeRate   
  end '   
 SET @SC_Settlement_USD='case when a.ext_settlement_clm=''totalroundamt'' then   
   ('+@collected_dollar_amount+') + ('+@SC_Dollar_amount+')  
  else  
   dollar_amt-round((senderCommission+isNull(agent_ex_gain,0))/exchangeRate,4,1)  
  end '   
    
 SET @SCommDollar='case when a.ext_settlement_clm=''totalroundamt'' then  0 else   
 (senderCommission+isNull(agent_ex_gain,0))/exchangeRate end '   
            
IF @flag='s'            
BEGIN            
SET @sql='SELECT CASE WHEN (GROUPING(companyname) = 1) THEN ''''             
 ELSE ISNULL(senderCountry, ''UNKNOWN'')  END AS senderCountry,            
 CASE WHEN (GROUPING(companyname) = 1) THEN ''''            
 ELSE ISNULL(companyname, ''UNKNOWN'')  END AS agentName,            
 CASE WHEN (GROUPING(senderCountry) = 1) THEN ''GrandTotal''            
 WHEN (GROUPING(companyname) = 1) THEN ''Total''            
 ELSE ''ALL'' END AS branch,            
 CASE WHEN (GROUPING(companyname) = 1) THEN ''''            
 ELSE ''ALL'' END AS receiverCountry,            
 count(*) TotNos,min(paidCtype) paidCtype,min(Agentid) Agentid,            
 SUM(paidAmt) AS paidAmt,            
 SUM(Scharge) AS totalScharge,            
  SUM('+@SC_Dollar_amount+') AS totalSchargeUSD,               
 sum(senderCommission+isNull(agent_ex_gain,0)) Sender_Charge ,            
 sum(sCharge-(senderCommission)) HO_Charge,  
  sum('+@collected_dollar_amount+') dollar_amt,              
  sum('+@SCommDollar+') SCommDollar,             
 sum((sCharge-(senderCommission))/exchangeRate) HOCommDollar,            
 sum(paidAmt-(senderCommission+isNull(agent_ex_gain,0))) settlement_local,             
  sum('+@SC_Settlement_USD+')settlement_usd,            
 avg(exchangeRate) as Settlement_Rate            
 FROM moneysend m join agentdetail a on m.agentid=a.agentcode            
 where isNull(a.non_IRH_Agent,''n'')=''n'' and '+ @dateType +' between '''+ @fromDate +''' and '''+ @toDate +' 23:59:59''            
 and Transstatus in (''Cancel'')'            
if @sendCountry IS NOT NULL            
 SET @sql= @sql+' and  sendercountry='''+ @sendCountry +''''          
if @senderAgent IS NOT NULL            
 SET @sql= @sql+' and agentid='''+ @senderAgent +''''            
if @receiveCountry IS NOT NULL            
 SET @sql= @sql+' and receiverCountry='''+ @receiveCountry +''''            
if @payoutAgent IS NOT NULL            
 SET @sql= @sql+' and expected_payoutagentid='''+ @payoutAgent +''''            
if @payoutBranch IS NOT NULL            
 SET @sql= @sql+' and rBankId='''+ @payoutBranch +''''            
if @statusType IS NOT NULL            
 SET @sql= @sql+' and status='''+ @statusType +''''            
if @paymentType IS NOT NULL            
 SET @sql= @sql+' and paymentType='''+ @paymentType +''''            
if @senderAgent_state IS NOT NULL        
 SET @sql= @sql+' and a.state='''+ @senderAgent_state +''''    
           
SET @sql= @sql+' GROUP BY senderCountry,companyname WITH ROLLUP'            
--PRINT @sql            
EXEC (@sql)            
END            
IF @flag='c'            
BEGIN            
SET @sql='SELECT             
 CASE WHEN (GROUPING(a.companyname) = 1) THEN ''''            
 ELSE ISNULL(a.companyname, ''UNKNOWN'')  END AS agentName,            
 CASE WHEN (GROUPING(a.companyname) = 1) THEN ''GrandTotal''            
 WHEN (GROUPING(pa.CompanyName) = 1) THEN ''Total''            
 ELSE ''ALL'' END AS branch,            
 CASE WHEN (GROUPING(pa.CompanyName) = 1) THEN ''''            
 ELSE isNULL(pa.CompanyName,''UNKNOWN'') END AS receiverCountry,            
 count(*) TotNos,min(paidCtype) paidCtype,            
 SUM(paidAmt) AS paidAmt,            
 SUM(Scharge) AS totalScharge,            
  SUM('+@SC_Dollar_amount+') AS totalSchargeUSD,            
 sum(senderCommission+isNull(agent_ex_gain,0)) Sender_Charge ,            
 sum(sCharge-(senderCommission)) HO_Charge,  
  sum('+@collected_dollar_amount+') dollar_amt,               
  sum('+@SCommDollar+') SCommDollar,              
 sum((sCharge-(senderCommission))/exchangeRate) HOCommDollar,            
 sum(paidAmt-(senderCommission+isNull(agent_ex_gain,0))) settlement_local,             
  sum('+@SC_Settlement_USD+')settlement_usd,              
 sum(TotalRoundAmt) Payout_Amt,min(receiveCtype) receiveCtype,            
 min(expected_payoutagentid) expected_payoutagentid,            
 avg(exchangeRate) as Settlement_Rate            
 FROM moneysend m join agentdetail pa on m.expected_payoutagentid=pa.agentcode      
join agentdetail a on a.agentcode=m.agentid            
 where '+ @dateType +' between '''+ @fromDate +''' and '''+ @toDate +' 23:59:59''            
 and Transstatus in (''Cancel'')'            
 if @sendCountry IS NOT NULL            
 SET @sql= @sql+' and  sendercountry='''+ @sendCountry +''''            
if @senderAgent IS NOT NULL            
 SET @sql= @sql+' and agentid='''+ @senderAgent +''''            
if @receiveCountry IS NOT NULL            
 SET @sql= @sql+' and receiverCountry='''+ @receiveCountry +''''            
if @payoutAgent IS NOT NULL            
 SET @sql= @sql+' and expected_payoutagentid='''+ @payoutAgent +''''            
if @payoutBranch IS NOT NULL            
 SET @sql= @sql+' and rBankId='''+ @payoutBranch +''''            
if @statusType IS NOT NULL            
 SET @sql= @sql+' and status='''+ @statusType +''''            
if @paymentType IS NOT NULL            
 SET @sql= @sql+' and paymentType='''+ @paymentType +''''            
if @senderAgentName IS NOT NULL            
 SET @sql= @sql+' and agentName='''+ @senderAgentName +''''            
if @senderCountry IS NOT NULL and @senderCountry<>'UNKNOWN'            
 SET @sql= @sql+' and senderCountry='''+ @senderCountry +''''            
if @senderCountry IS NOT NULL and @senderCountry='UNKNOWN'            
 SET @sql= @sql+' and senderCountry is null'       
 if @senderAgent_state IS NOT NULL        
 SET @sql= @sql+' and a.state='''+ @senderAgent_state +''''    
          
SET @sql= @sql+' GROUP BY a.companyname,pa.CompanyName WITH ROLLUP'            
--PRINT @sql            
EXEC (@sql)            
END            
IF @flag='d'            
BEGIN            
SET @sql='SELECT convert(varchar,'+@dateType+',102) as dot,            
 CASE WHEN (GROUPING(agentName) = 1) THEN ''''            
 ELSE ISNULL(agentName, ''UNKNOWN'')  END AS agentName,            
 max(agentid) AS senderAgent,            
 CASE WHEN (GROUPING(agentName) = 1) THEN ''GrandTotal''            
 WHEN (GROUPING(pa.CompanyName) = 1) THEN ''Total''            
 ELSE ''ALL'' END AS branch,            
 CASE WHEN (GROUPING(pa.CompanyName) = 1) THEN ''''            
 ELSE isNULL(pa.CompanyName,''UNKNOWN'') END AS receiverCountry,            
 count(*) TotNos,min(paidCtype) paidCtype,            
 SUM(paidAmt) AS paidAmt,            
 SUM(Scharge) AS totalScharge,            
 SUM(Scharge/exchangeRate) AS totalSchargeUSD,            
 sum(senderCommission+isNull(agent_ex_gain,0)) Sender_Charge ,            
 sum(sCharge-(senderCommission)) HO_Charge,sum(dollar_amt) dollar_amt,            
 sum((senderCommission+isNull(agent_ex_gain,0))/exchangeRate) SCommDollar,            
 sum((sCharge-(senderCommission))/exchangeRate) HOCommDollar,            
 sum(paidAmt-(senderCommission+isNull(agent_ex_gain,0))) settlement_local,             
 sum(dollar_amt-round((senderCommission+isNull(agent_ex_gain,0))/exchangeRate,4,1)) settlement_usd,            
 sum(TotalRoundAmt) Payout_Amt,min(receiveCtype) receiveCtype,            
 min(expected_payoutagentid) expected_payoutagentid,            
avg(exchangeRate) as Settlement_Rate            
 FROM moneysend m join agentdetail pa on m.expected_payoutagentid=pa.agentcode        
 join agentdetail a on a.agentcode=m.agentid         
 where '+ @dateType +' between '''+ @fromDate +''' and '''+ @toDate +' 23:59:59''            
 and Transstatus in (''Cancel'')'            
 if @sendCountry IS NOT NULL            
 SET @sql= @sql+' and  sendercountry='''+ @sendCountry +''''            
if @senderAgent IS NOT NULL            
 SET @sql= @sql+' and agentid='''+ @senderAgent +''''            
if @receiveCountry IS NOT NULL            
 SET @sql= @sql+' and receiverCountry='''+ @receiveCountry +''''            
if @payoutAgent IS NOT NULL            
 SET @sql= @sql+' and expected_payoutagentid='''+ @payoutAgent +''''            
if @payoutBranch IS NOT NULL            
 SET @sql= @sql+' and rBankId='''+ @payoutBranch +''''            
if @statusType IS NOT NULL            
 SET @sql= @sql+' and status='''+ @statusType +''''            
if @paymentType IS NOT NULL            
 SET @sql= @sql+' and paymentType='''+ @paymentType +''''            
if @senderAgentName IS NOT NULL            
 SET @sql= @sql+' and agentName='''+ @senderAgentName +''''            
if @senderCountry IS NOT NULL and @senderCountry<>'UNKNOWN'            
 SET @sql= @sql+' and senderCountry='''+ @senderCountry +''''            
if @senderCountry IS NOT NULL and @senderCountry='UNKNOWN'            
 SET @sql= @sql+' and senderCountry is null'            
if @senderAgent_state IS NOT NULL        
 SET @sql= @sql+' and a.state='''+ @senderAgent_state +''''    
             
SET @sql= @sql+' GROUP BY agentName,pa.CompanyName,convert(varchar,'+@dateType+',102) WITH ROLLUP'            
--PRINT @sql            
EXEC (@sql)            
END            
IF @flag='b'            
BEGIN            
SET @sql='SELECT             
 CASE WHEN (GROUPING(a.companyname) = 1) THEN ''''            
 ELSE ISNULL(a.companyname, ''UNKNOWN'')  END AS agentName,            
 max(agentid) AS senderAgent,            
 CASE WHEN (GROUPING(a.companyname) = 1) THEN ''GrandTotal''            
 WHEN (GROUPING(pa.companyName) = 1) THEN ''Total''            
 ELSE isNULL(branch,'''') END AS branch,            
 CASE WHEN (GROUPING(pa.companyName) = 1) THEN ''''            
 ELSE isNULL(pa.companyName,''UNKNOWN'') END AS receiverCountry,            
 count(*) TotNos,min(paidCtype) paidCtype,            
 SUM(paidAmt) AS paidAmt,            
 SUM(Scharge) AS totalScharge,            
 SUM(Scharge/exchangeRate) AS totalSchargeUSD,            
 sum(senderCommission+isNull(agent_ex_gain,0)) Sender_Charge ,            
 sum(sCharge-(senderCommission)) HO_Charge,sum(dollar_amt) dollar_amt,            
 sum((senderCommission+isNull(agent_ex_gain,0))/exchangeRate) SCommDollar,            
 sum((sCharge-(senderCommission))/exchangeRate) HOCommDollar,            
 sum(paidAmt-(senderCommission+isNull(agent_ex_gain,0))) settlement_local,             
 sum(dollar_amt-round((senderCommission+isNull(agent_ex_gain,0))/exchangeRate,4,1))settlement_usd,            
 sum(TotalRoundAmt) Payout_Amt,min(receiveCtype) receiveCtype,            
 min(expected_payoutagentid) expected_payoutagentid,            
avg(exchangeRate) as Settlement_Rate            
 FROM moneysend m join agentdetail pa on m.expected_payoutagentid=pa.agentcode       
join agentdetail a on a.agentcode=m.agentid           
 where '+ @dateType +' between '''+ @fromDate +''' and '''+ @toDate +' 23:59:59''            
 and Transstatus in (''Cancel'')'            
  if @sendCountry IS NOT NULL            
 SET @sql= @sql+' and  sendercountry='''+ @sendCountry +''''           
if @senderAgent IS NOT NULL            
 SET @sql= @sql+' and agentid='''+ @senderAgent +''''            
if @receiveCountry IS NOT NULL            
 SET @sql= @sql+' and receiverCountry='''+ @receiveCountry +''''            
if @payoutAgent IS NOT NULL            
 SET @sql= @sql+' and expected_payoutagentid='''+ @payoutAgent +''''            
if @payoutBranch IS NOT NULL            
 SET @sql= @sql+' and rBankId='''+ @payoutBranch +''''            
if @statusType IS NOT NULL            
 SET @sql= @sql+' and status='''+ @statusType +''''            
if @paymentType IS NOT NULL            
 SET @sql= @sql+' and paymentType='''+ @paymentType +''''            
if @senderAgentName IS NOT NULL            
 SET @sql= @sql+' and a.companyname='''+ @senderAgentName +''''            
if @senderCountry IS NOT NULL and @senderCountry<>'UNKNOWN'            
 SET @sql= @sql+' and senderCountry='''+ @senderCountry +''''        
if @senderCountry IS NOT NULL and @senderCountry='UNKNOWN'            
 SET @sql= @sql+' and senderCountry is null'            
if @senderAgent_state IS NOT NULL        
 SET @sql= @sql+' and a.state='''+ @senderAgent_state +''''    
            
SET @sql= @sql+' GROUP BY a.companyname,pa.companyName,branch WITH ROLLUP'            
--PRINT @sql            
EXEC (@sql)            
END            
IF @flag='t'            
BEGIN            
SET @sql='SELECT tranno,senderName,receiverName,local_dot dot,paidDate,            
 paidCtype,            
 paidAmt AS paidAmt,            
 Scharge AS totalScharge,            
 Scharge/exchangeRate AS totalSchargeUSD,            
 senderCommission+isNull(agent_ex_gain,0) Sender_Charge ,            
 sCharge-(senderCommission) HO_Charge,            
 dollar_amt dollar_amt,            
 (senderCommission+isNull(agent_ex_gain,0))/exchangeRate SCommDollar,            
 (sCharge-(senderCommission))/exchangeRate HOCommDollar,            
 paidAmt-(senderCommission+isNull(agent_ex_gain,0)) settlement_local,             
 dollar_amt-round((senderCommission+isNull(agent_ex_gain,0))/exchangeRate,4,1) settlement_usd,            
 TotalRoundAmt Payout_Amt,receiveCtype receiveCtype,            
 exchangeRate as Settlement_Rate            
-- paidAmt,senderCommission+isNull(agent_ex_gain,0) Sender_Charge ,            
-- (sCharge-(senderCommission+isNull(agent_ex_gain,0))) HO_Charge,dollar_amt,            
-- TotalRoundAmt NPR_Amt,((senderCommission+isNull(agent_ex_gain,0))/exchangeRate) SCommDollar,            
-- ((sCharge-(senderCommission+isNull(agent_ex_gain,0)))/exchangeRate) HOCommDollar            
 FROM moneysend m with (nolock) join agentdetail a on a.agentcode=m.agentid         
 where '+ @dateType +' between '''+ @fromDate +''' and '''+ @toDate +' 23:59:59''            
 and Transstatus in (''Cancel'')'            
  if @sendCountry IS NOT NULL            
 SET @sql= @sql+' and  sendercountry='''+ @sendCountry +''''           
if @senderAgent IS NOT NULL            
 SET @sql= @sql+' and agentid='''+ @senderAgent +''''            
if @receiveCountry IS NOT NULL            
 SET @sql= @sql+' and receiverCountry='''+ @receiveCountry +''''            
if @payoutAgent IS NOT NULL            
 SET @sql= @sql+' and expected_payoutagentid='''+ @payoutAgent +''''            
if @payoutBranch IS NOT NULL            
 SET @sql= @sql+' and rBankId='''+ @payoutBranch +''''            
if @statusType IS NOT NULL            
 SET @sql= @sql+' and status='''+ @statusType +''''            
if @paymentType IS NOT NULL            
 SET @sql= @sql+' and paymentType='''+ @paymentType +''''            
if @senderAgentName IS NOT NULL            
 SET @sql= @sql+' and agentName='''+ @senderAgentName +''''            
if @senderBranch IS NOT NULL            
 SET @sql= @sql+' and branch='''+ @senderBranch +''''            
if @senderCountry IS NOT NULL and @senderCountry<>'UNKNOWN'            
 SET @sql= @sql+' and senderCountry='''+ @senderCountry +''''            
if @senderCountry IS NOT NULL and @senderCountry='UNKNOWN'            
 SET @sql= @sql+' and senderCountry is null'        
if @senderAgent_state IS NOT NULL        
 SET @sql= @sql+' and a.state='''+ @senderAgent_state +''''    
         
SET @sql= @sql+' order by tranno'            
--PRINT @sql            
EXEC (@sql)            
END               