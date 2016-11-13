drop PROCEDURE [dbo].[spa_drildownpayoutreport]   
go
--spa_drildownpayoutreport 's',NULL,NULL,NULL,NULL,NULL,NULL,'confirmDate','6/1/2009','11/1/2009'        
--spa_drildownpayoutreport 'c','-1',NULL,NULL,NULL,NULL,NULL,'confirmDate','6/1/2009','8/1/2009','IME Nepal'        
--spa_drildownpayoutreport 'd','-1',NULL,'10100000',NULL,NULL,NULL,'confirmDate','5/1/2009','8/1/2009','IME Nepal'        
--spa_drildownpayoutreport 't','-1',NULL,'10100000',NULL,NULL,NULL,'confirmDate','2009.07.21','2009.07.21',NULL,NULL        
CREATE PROCEDURE [dbo].[spa_drildownpayoutreport]        
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
 @sendCountry varchar(50)= NULL,  
 @senderAgent_state  varchar(50)=NULL,  
 @payoutAgent_state  varchar(50)=NULL       
AS        
DECLARE @sql varchar(8000)        
if @dateType is NULL        
 set @dateType='PaidDate'        
IF @flag='s'        
BEGIN        
SET @sql='        
 SELECT CASE WHEN (GROUPING(pa.CompanyName) = 1) THEN ''''         
 ELSE ISNULL( pa.country, ''UNKNOWN'')  END AS receiverCountry,        
 CASE WHEN (GROUPING(pa.CompanyName) = 1) THEN ''''        
 ELSE ISNULL(pa.CompanyName, ''UNKNOWN'')  END AS agentName,        
 CASE WHEN (GROUPING( pa.country) = 1) THEN ''GrandTotal''        
 WHEN (GROUPING(pa.CompanyName) = 1) THEN ''Total''        
 ELSE ''ALL'' END AS branch,        
 count(*) TotNos,min(receiveCtype) receiveCtype,        
 min(expected_payoutagentid) payoutAgentid,        
 SUM(totalroundamt) AS totalroundamt,        
 SUM(totalroundamt/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case       
when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate       
else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end) AS totalroundamtusd,        
 sum(isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else         
 isNull(agent_receiverCommission,0)* case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case       
when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate       
else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end end ,0))  total_pc_flat_comm_local,        
 sum(isNull(case when isNull(agent_receiverComm_Currency,''l'')=''d'' then isNull(agent_receiverCommission,0)       
else isNull(agent_receiverCommission,0) / case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case when ho_dollar_rate=0       
then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end end,0))   total_pc_flat_comm_usd,        
 sum((agent_settlement_rate * isNull(agent_receiverSCommission,0))) pc_comm_charge,        
 sum((agent_settlement_rate * isNull(agent_receiverSCommission,0))/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else       
case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end) pc_comm_charge_usd,        
 sum(isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0)*       
case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate       
else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end end  + (agent_settlement_rate * isNull(agent_receiverSCommission,0)),0)) total_pc_gain,        
sum(isNull(round((case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0)       
else isNull(agent_receiverCommission,0) * case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case when ho_dollar_rate=0       
then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end end         
+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)))/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case when ho_dollar_rate=0       
then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end ,4),0))  total_pc_gain_usd,        
sum(totalroundamt+isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0)       
else isNull(agent_receiverCommission,0)* case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case       
when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end end         
+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)),0)) settlement_local,  sum(isNull(round((totalroundamt+case when isNull(agent_receiverComm_Currency,''l'')=''l''       
then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0) * case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate       
else case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate       
else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end end         
+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)))/case when ho_dollar_rate=0       
then exchangeRate * agent_settlement_rate else case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate       
else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end ,4),0)) settlement_usd        
 FROM moneysend m with (nolock)  
 join agentdetail pa with (nolock) on m.expected_payoutagentid=pa.agentcode   
 join agentdetail sa with (nolock) on m.agentid=sa.agentcode         
 where '+@dateType+' between '''+ @fromDate +''' and '''+ @toDate +' 23:59:59''        
 and transStatus not in (''Hold'',''Cancel'') and isNull(pa.non_IRH_Agent,''n'')=''n''        
'         
if @sendCountry IS NOT NULL        
 SET @sql= @sql+' and  m.sendercountry='''+ @sendCountry +''''   
if @senderAgent IS NOT NULL        
 SET @sql= @sql+' and m.agentid='''+ @senderAgent +''''          
if @receiveCountry IS NOT NULL        
 SET @sql= @sql+' and  pa.country='''+ @receiveCountry +''''    
if @payoutAgent IS NOT NULL        
 SET @sql= @sql+' and m.expected_payoutagentid='''+ @payoutAgent +''''         
if @paymentType IS NOT NULL        
 SET @sql= @sql+' and m.paymentType='''+ @paymentType +''''        
if @statusType IS NOT NULL        
 SET @sql= @sql+' and m.status='''+ @statusType +''''     
if @senderAgent_state IS NOT NULL      
 SET @sql= @sql+' and sa.state='''+ @senderAgent_state +''''   
if @payoutAgent_state IS NOT NULL      
 SET @sql= @sql+' and pa.state='''+ @payoutAgent_state +''''    
      
SET @sql= @sql+' GROUP BY pa.country,pa.CompanyName WITH ROLLUP'        
--PRINT @sql        
EXEC (@sql)        
END        
IF @flag='c'        
BEGIN        
SET @sql='SELECT         
 CASE WHEN (GROUPING(pa.CompanyName) = 1) THEN ''''        
 ELSE ISNULL(pa.CompanyName, ''UNKNOWN'')  END AS agentName,        
 CASE WHEN (GROUPING(pa.CompanyName) = 1) THEN ''GrandTotal''        
 WHEN (GROUPING(agentName) = 1) THEN ''Total''        
 ELSE ''ALL'' END AS branch,        
 CASE WHEN (GROUPING(agentName) = 1) THEN ''''        
 ELSE isNULL(agentName,''UNKNOWN'') END AS receiverCountry,        
 count(*) TotNos,min(receiveCtype) receiveCtype,        
 min(agentid) Agentid,        
 SUM(totalroundamt) AS totalroundamt,        
 SUM(totalroundamt/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case when ho_dollar_rate=0 then exchangeRate *       
agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end) AS totalroundamtusd,        
 sum(isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l''   then isNull(agent_receiverCommission,0) else         
 isNull(agent_receiverCommission,0)* case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate       
else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end end ,0))  total_pc_flat_comm_local,        
 sum(isNull(case when isNull(agent_receiverComm_Currency,''l'')=''d'' then isNull(agent_receiverCommission,0)       
else isNull(agent_receiverCommission,0) / case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else       
case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end end,0))  total_pc_flat_comm_usd,        
 sum((agent_settlement_rate * isNull(agent_receiverSCommission,0))) pc_comm_charge,       
 sum((agent_settlement_rate * isNull(agent_receiverSCommission,0))/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else       
case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end) pc_comm_charge_usd,        
 sum(isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0)*       
case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate       
else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end end   + (agent_settlement_rate * isNull(agent_receiverSCommission,0)),0)) total_pc_gain,        
 sum(isNull(round((case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0)       
else isNull(agent_receiverCommission,0) * case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate       
else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end         
+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)))/case when ho_dollar_rate=0       
then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end ,4),0))  total_pc_gain_usd,        
sum(totalroundamt+isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0)       
else isNull(agent_receiverCommission,0)* case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate       
else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end         
+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)),0)) settlement_local,        
 sum(isNull(round((totalroundamt+case when isNull(agent_receiverComm_Currency,''l'')=''l''       
then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0) * case when ho_dollar_rate=0       
then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end         
+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)))/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate       
else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end ,4),0))    settlement_usd,        
avg(case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate       
else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end) Settlement_Rate        
 FROM moneysend m with (nolock)  
 join agentdetail pa with (nolock) on m.expected_payoutagentid=pa.agentcode   
 join agentdetail sa with (nolock) on m.agentid=sa.agentcode         
 where '+@dateType+' between '''+ @fromDate +''' and '''+ @toDate +' 23:59:59''        
 and transStatus not in (''Hold'',''Cancel'')       
         
'        
if @sendCountry IS NOT NULL        
 SET @sql= @sql+' and  m.sendercountry='''+ @sendCountry +''''      
if @senderAgent IS NOT NULL        
 SET @sql= @sql+' and m.agentid='''+ @senderAgent +''''           
if @receiveCountry IS NOT NULL        
 SET @sql= @sql+' and pa.country='''+ @receiveCountry +''''        
if @payoutAgent IS NOT NULL        
 SET @sql= @sql+' and m.expected_payoutagentid='''+ @payoutAgent +''''        
if @paymentType IS NOT NULL        
 SET @sql= @sql+' and m.paymentType='''+ @paymentType +''''        
if @statusType IS NOT NULL        
 SET @sql= @sql+' and m.status='''+ @statusType +''''  
if @senderAgent_state IS NOT NULL      
 SET @sql= @sql+' and sa.state='''+ @senderAgent_state +''''   
if @payoutAgent_state IS NOT NULL      
 SET @sql= @sql+' and pa.state='''+ @payoutAgent_state +''''    
         
SET @sql= @sql+'  GROUP BY pa.CompanyName,agentName WITH ROLLUP'        
--PRINT @sql        
EXEC (@sql)        
END        
IF @flag='d'        
BEGIN        
SET @sql='SELECT convert(varchar,'+@dateType+',102) as dot,        
 CASE WHEN (GROUPING(pa.CompanyName) = 1) THEN ''''        
 ELSE ISNULL(pa.CompanyName, ''UNKNOWN'')  END AS agentName,        
 max(expected_payoutagentid) AS PayoutAgent,        
 CASE WHEN (GROUPING(pa.CompanyName) = 1) THEN ''GrandTotal''        
 WHEN (GROUPING(agentName) = 1) THEN ''Total''        
 ELSE ''ALL'' END AS branch,        
 CASE WHEN (GROUPING(agentname) = 1) THEN ''''        
 ELSE isNULL(agentname,''UNKNOWN'') END AS receiverCountry,        
 count(*) TotNos,min(receiveCtype) receiveCtype,        
 min(agentid) Agentid,        
 SUM(totalroundamt) AS totalroundamt,        
 SUM(totalroundamt/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate *       
agent_settlement_rate) end) AS totalroundamtusd,   sum(isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l''         
 then isNull(agent_receiverCommission,0) else  isNull(agent_receiverCommission,0)* case when ho_dollar_rate=0 then exchangeRate *       
agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end ,0))   total_pc_flat_comm_local,        
 sum(isNull(case when isNull(agent_receiverComm_Currency,''l'')=''d'' then isNull(agent_receiverCommission,0)       
else isNull(agent_receiverCommission,0) / case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate       
else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end,0))    total_pc_flat_comm_usd,        
 sum((agent_settlement_rate * isNull(agent_receiverSCommission,0))) pc_comm_charge,        
 sum((agent_settlement_rate * isNull(agent_receiverSCommission,0))/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate       
else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end) pc_comm_charge_usd,        
 sum(isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0)       
else isNull(agent_receiverCommission,0)* case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate       
else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end   + (agent_settlement_rate * isNull(agent_receiverSCommission,0)),0)) total_pc_gain,        
 sum(isNull(round((case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0)       
else isNull(agent_receiverCommission,0) * case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,      
exchangeRate * agent_settlement_rate) end end   + (agent_settlement_rate * isNull(agent_receiverSCommission,0)))/case when ho_dollar_rate=0       
then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end ,4),0))   total_pc_gain_usd,        
sum(totalroundamt+isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0)       
else isNull(agent_receiverCommission,0)* case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate       
else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end   + (agent_settlement_rate * isNull(agent_receiverSCommission,0)),0)) settlement_local,        
 sum(isNull(round((totalroundamt+case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0)       
else isNull(agent_receiverCommission,0) * case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate *       
agent_settlement_rate) end end   + (agent_settlement_rate * isNull(agent_receiverSCommission,0)))/case when ho_dollar_rate=0 then exchangeRate *       
agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end ,4),0))    settlement_usd,        
avg(case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate *       
agent_settlement_rate) end) Settlement_Rate     
 FROM moneysend m with (nolock)  
 join agentdetail pa with (nolock) on m.expected_payoutagentid=pa.agentcode   
 join agentdetail sa with (nolock) on m.agentid=sa.agentcode   
 where '+@dateType+' between '''+ @fromDate +''' and '''+ @toDate +' 23:59:59''        
 and transStatus not in (''Hold'',''Cancel'')'       
 if @sendCountry IS NOT NULL        
 SET @sql= @sql+' and  m.sendercountry='''+ @sendCountry +''''       
if @payoutAgent IS NOT NULL        
 SET @sql= @sql+' and m.expected_payoutagentid='''+ @payoutAgent +''''       
if @receiveCountry IS NOT NULL        
 SET @sql= @sql+' and pa.country='''+ @receiveCountry +''''        
if @senderAgent IS NOT NULL        
 SET @sql= @sql+' and m.agentid='''+ @senderAgent +''''         
if @paymentType IS NOT NULL        
 SET @sql= @sql+' and m.paymentType='''+ @paymentType +''''        
if @statusType IS NOT NULL        
 SET @sql= @sql+' and m.status='''+ @statusType +''''  
if @senderAgent_state IS NOT NULL      
 SET @sql= @sql+' and sa.state='''+ @senderAgent_state +''''   
if @payoutAgent_state IS NOT NULL      
 SET @sql= @sql+' and pa.state='''+ @payoutAgent_state +''''      
    
SET @sql= @sql+' GROUP BY pa.CompanyName,agentName,convert(varchar,'+@dateType+',102) WITH ROLLUP'        
--PRINT @sql        
EXEC (@sql)        
END        
IF @flag='t'        
BEGIN        
SET @sql='SELECT tranno,rBankBranch,receiverName,confirmDate dot,paidDate,        
 receiveCtype receiveCtype,        
 totalroundamt AS totalroundamt,        
 totalroundamt/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end AS totalroundamtusd,        
 isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else         
 isNull(agent_receiverCommission,0)* case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate       
else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end ,0)   total_pc_flat_comm_local,        
 isNull(case when isNull(agent_receiverComm_Currency,''l'')=''d'' then isNull(agent_receiverCommission,0)       
else isNull(agent_receiverCommission,0) / case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,      
exchangeRate * agent_settlement_rate) end end,0)   total_pc_flat_comm_usd,        
 (agent_settlement_rate * isNull(agent_receiverSCommission,0)) pc_comm_charge,        
 (agent_settlement_rate * isNull(agent_receiverSCommission,0))/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate      
 else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end pc_comm_charge_usd,        
 isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0)*       
case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end         
 + (agent_settlement_rate * isNull(agent_receiverSCommission,0)),0) total_pc_gain,        
 isNull(round((case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0)       
else isNull(agent_receiverCommission,0) * case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate       
else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end         
+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)))/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate       
else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end ,4),0)   total_pc_gain_usd,        
 totalroundamt+isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0)       
else isNull(agent_receiverCommission,0)* case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end         
 + (agent_settlement_rate * isNull(agent_receiverSCommission,0)),0) settlement_local,        
 isNull(round((totalroundamt+case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0)       
else isNull(agent_receiverCommission,0) * case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end         
 + (agent_settlement_rate * isNull(agent_receiverSCommission,0)))/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate       
else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end ,4),0)   settlement_usd,        
case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate *       
agent_settlement_rate) end  Settlement_Rate     
 FROM moneysend m with (nolock)  
 join agentdetail pa with (nolock) on m.expected_payoutagentid=pa.agentcode   
 join agentdetail sa with (nolock) on m.agentid=sa.agentcode   
 where '+@dateType+' between '''+ @fromDate +''' and '''+ @toDate +' 23:59:59''        
 and transStatus not in (''Hold'',''Cancel'') '        
 if @sendCountry IS NOT NULL        
 SET @sql= @sql+' and  m.sendercountry='''+ @sendCountry +''''       
if @payoutAgent IS NOT NULL        
 SET @sql= @sql+' and m.expected_payoutagentid='''+ @payoutAgent +''''          
if @receiveCountry IS NOT NULL        
 SET @sql= @sql+' and pa.country='''+ @receiveCountry +''''        
if @senderAgent IS NOT NULL        
 SET @sql= @sql+' and m.agentid='''+ @senderAgent +''''           
if @paymentType IS NOT NULL        
 SET @sql= @sql+' and paymentType='''+ @paymentType +''''        
if @statusType IS NOT NULL        
 SET @sql= @sql+' and status='''+ @statusType +''''  
if @senderAgent_state IS NOT NULL      
 SET @sql= @sql+' and sa.state='''+ @senderAgent_state +''''   
if @payoutAgent_state IS NOT NULL      
 SET @sql= @sql+' and pa.state='''+ @payoutAgent_state +''''          
SET @sql= @sql+' order by rBankBranch,'+@dateType+''        
--PRINT @sql        
EXEC (@sql)        
END 