/****** Object:  StoredProcedure [dbo].[spa_super_compliance]    Script Date: 09/15/2014 13:20:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_super_compliance]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_super_compliance]
GO


/****** Object:  StoredProcedure [dbo].[spa_super_compliance]    Script Date: 09/15/2014 13:20:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





--spa_super_compliance 's','20100040',NULL,'Bangladesh',NULL,NULL,NULL,NULL,'ConfirmDate','1/20/2010','11/20/2010'
CREATE PROCEDURE [dbo].[spa_super_compliance]
	@flag char(1),
@superAgent varchar(50)=NULL,
	@senderAgent varchar(50)=NULL,
	@receiveCountry varchar(100)=NULL,
	@payoutAgent varchar(50)=NULL,
	@payoutBranch varchar(50)=NULL,
	@paymentType varchar(100)=NULL,
	@statusType varchar(100)=NULL,
	@dateType varchar(50)=NULL,
	@fromDate varchar(50)=NULL,
	@toDate varchar(50)=NULL,
	@senderAgentName varchar(200)=NULL,
	@senderBranch varchar(200)=NULL
AS
DECLARE @sql varchar(8000)
if @dateType is NULL
	set @dateType='PaidDate'
IF @flag='s'
BEGIN
SET @sql='select case when status='''' then NULL else agentname end agent_name,* from (
	SELECT CASE WHEN (GROUPING(pa.CompanyName) = 1) THEN '''' 
	ELSE ISNULL( pa.country, ''UNKNOWN'')  END AS receiverCountry,
	CASE WHEN (GROUPING(pa.CompanyName) = 1) THEN upper(status) 
	ELSE ISNULL(pa.CompanyName, ''UNKNOWN'')  END AS agentName,isnull(status,'''') status,
	CASE WHEN (GROUPING( pa.country) = 1) THEN ''GrandTotal''
	WHEN (GROUPING(receiveCtype) = 1) THEN ''Total''
	ELSE ''ALL'' END AS branch, isnull(receiveCtype,'''') receiveCtype,
	count(*) TotNos,min(Agentid) Agentid,min(expected_payoutagentid) payoutAgent,
	SUM(totalroundamt) AS totalroundamt,
	SUM(totalroundamt/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end) AS totalroundamtusd,
	sum(isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' 
	then isNull(agent_receiverCommission,0) else 
	isNull(agent_receiverCommission,0)* case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end end ,0))
	total_pc_flat_comm_local,
	sum(isNull(case when isNull(agent_receiverComm_Currency,''l'')=''d'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0) / case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end end,0)) 
	total_pc_flat_comm_usd,
	sum((agent_settlement_rate * isNull(agent_receiverSCommission,0))) pc_comm_charge,
	sum((agent_settlement_rate * isNull(agent_receiverSCommission,0))/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end) pc_comm_charge_usd,
	sum(isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0)* case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end end 
+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)),0)) total_pc_gain,
	sum(isNull(round((case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0) * case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end end 
+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)))/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end ,4),0)) 
total_pc_gain_usd,
sum(totalroundamt+isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0)* case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end end 
+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)),0)) settlement_local,
	sum(isNull(round((totalroundamt+case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0) * case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end end 
+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)))/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end ,4),0)) 
	settlement_usd
	FROM moneysend m join agentdetail pa on m.expected_payoutagentid=pa.agentcode
	where '+@dateType+' between '''+ @fromDate +''' and '''+ @toDate +' 23:59:59''
	and transStatus in (''Payment'',''Block'') and isNull(pa.non_IRH_Agent,''n'')=''n''
'

SET @sql= @sql+' and (pa.agentcode ='''+ @superAgent +''' or pa.super_agent_id='''+ @superAgent +''') '

if @statusType is not null
set @sql=@sql+' and status='''+@statusType+''''
if @paymentType is not null
set @sql=@sql+' and paymentType='''+@paymentType+''''

if @payoutAgent IS NOT NULL
	SET @sql= @sql+' and expected_payoutagentid='''+ @payoutAgent +''''
if @receiveCountry IS NOT NULL
	SET @sql= @sql+' and  pa.country='''+ @receiveCountry +''''
if @senderAgent IS NOT NULL
	SET @sql= @sql+' and agentid='''+ @senderAgent +''''
SET @sql= @sql+' GROUP BY pa.country,pa.CompanyName,receivectype,status WITH ROLLUP'
SET @sql= @sql+') s where   branch<>''Total'' '
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
	SUM(totalroundamt/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end) AS totalroundamtusd,
	sum(isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' 
	then isNull(agent_receiverCommission,0) else 
	isNull(agent_receiverCommission,0)* case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end end ,0))
	total_pc_flat_comm_local,
	sum(isNull(case when isNull(agent_receiverComm_Currency,''l'')=''d'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0) / case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end end,0)) 
	total_pc_flat_comm_usd,
	sum((agent_settlement_rate * isNull(agent_receiverSCommission,0))) pc_comm_charge,
	sum((agent_settlement_rate * isNull(agent_receiverSCommission,0))/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end) pc_comm_charge_usd,
	sum(isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0)* case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end end 
+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)),0)) total_pc_gain,
	sum(isNull(round((case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0) * case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end 
+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)))/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end ,4),0)) 
total_pc_gain_usd,
sum(totalroundamt+isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0)* case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end 
+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)),0)) settlement_local,
	sum(isNull(round((totalroundamt+case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0) * case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end 
+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)))/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end ,4),0)) 
	settlement_usd,
avg(case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end) Settlement_Rate
	FROM moneysend m join agentdetail pa on m.expected_payoutagentid=pa.agentcode
	where '+@dateType+' between '''+ @fromDate +''' and '''+ @toDate +' 23:59:59''
	and transStatus in (''Payment'',''Block'')
	
'
if @statusType is not null
set @sql=@sql+' and status='''+@statusType+''''
if @paymentType is not null
set @sql=@sql+' and paymentType='''+@paymentType+''''

if @payoutAgent IS NOT NULL
	SET @sql= @sql+' and expected_payoutagentid='''+ @payoutAgent +''''
if @receiveCountry IS NOT NULL
	SET @sql= @sql+' and pa.country='''+ @receiveCountry +''''
if @senderAgent IS NOT NULL
	SET @sql= @sql+' and agentid='''+ @senderAgent +''''
SET @sql= @sql+' 	GROUP BY pa.CompanyName,agentName WITH ROLLUP'
--PRINT @sql
EXEC (@sql)
END
IF @flag='d'
BEGIN
SET @sql='SELECT convert(varchar,'+@dateType+',102) as dot,
	CASE WHEN (GROUPING(pa.CompanyName) = 1) THEN ''''
	ELSE ISNULL(pa.CompanyName, ''UNKNOWN'')  END AS agentName,
	max(expected_payoutagentid) AS senderAgent,
	CASE WHEN (GROUPING(pa.CompanyName) = 1) THEN ''GrandTotal''
	WHEN (GROUPING(agentName) = 1) THEN ''Total''
	ELSE ''ALL'' END AS branch,
	CASE WHEN (GROUPING(agentname) = 1) THEN ''''
	ELSE isNULL(agentname,''UNKNOWN'') END AS receiverCountry,
	count(*) TotNos,min(receiveCtype) receiveCtype,
	min(agentid) Agentid,
	SUM(totalroundamt) AS totalroundamt,
	SUM(totalroundamt/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end) AS totalroundamtusd,
	sum(isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' 
	then isNull(agent_receiverCommission,0) else 
	isNull(agent_receiverCommission,0)* case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end ,0))
	total_pc_flat_comm_local,
	sum(isNull(case when isNull(agent_receiverComm_Currency,''l'')=''d'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0) / case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end,0)) 
	total_pc_flat_comm_usd,
	sum((agent_settlement_rate * isNull(agent_receiverSCommission,0))) pc_comm_charge,
	sum((agent_settlement_rate * isNull(agent_receiverSCommission,0))/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end) pc_comm_charge_usd,
	sum(isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0)* case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end 
+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)),0)) total_pc_gain,
	sum(isNull(round((case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0) * case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end 
+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)))/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end ,4),0)) 
total_pc_gain_usd,
sum(totalroundamt+isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0)* case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end 
+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)),0)) settlement_local,
	sum(isNull(round((totalroundamt+case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0) * case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end 
+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)))/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end ,4),0)) 
	settlement_usd,
avg(case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end) Settlement_Rate
	FROM moneysend m join agentdetail pa on m.expected_payoutagentid=pa.agentcode
	where '+@dateType+' between '''+ @fromDate +''' and '''+ @toDate +' 23:59:59''
	and transStatus in (''Payment'',''Block'')'

if @statusType is not null
set @sql=@sql+' and status='''+@statusType+''''
if @paymentType is not null
set @sql=@sql+' and paymentType='''+@paymentType+''''

if @payoutAgent IS NOT NULL
	SET @sql= @sql+' and expected_payoutagentid ='''+ @payoutAgent +''''
if @receiveCountry IS NOT NULL
	SET @sql= @sql+' and pa.country='''+ @receiveCountry +''''
if @senderAgent IS NOT NULL
	SET @sql= @sql+' and agentid='''+ @senderAgent +''''
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
	isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' 
	then isNull(agent_receiverCommission,0) else 
	isNull(agent_receiverCommission,0)* case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end ,0)
	total_pc_flat_comm_local,
	isNull(case when isNull(agent_receiverComm_Currency,''l'')=''d'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0) / case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end,0)
	total_pc_flat_comm_usd,
	(agent_settlement_rate * isNull(agent_receiverSCommission,0)) pc_comm_charge,
	(agent_settlement_rate * isNull(agent_receiverSCommission,0))/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end pc_comm_charge_usd,
	isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0)* case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end 
	+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)),0) total_pc_gain,
	isNull(round((case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0) * case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end 
+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)))/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end ,4),0) 
total_pc_gain_usd,
	totalroundamt+isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0)* case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end 
	+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)),0) settlement_local,
	isNull(round((totalroundamt+case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0) * case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end end 
	+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)))/case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end ,4),0)
	settlement_usd,
case when ho_dollar_rate=0 then exchangeRate * agent_settlement_rate else isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) end  Settlement_Rate
	FROM moneysend  m join agentdetail pa on m.expected_payoutagentid=pa.agentcode
	where '+@dateType+' between '''+ @fromDate +''' and '''+ @toDate +' 23:59:59''
	and transStatus in (''Payment'',''Block'')'

if @statusType is not null
set @sql=@sql+' and status='''+@statusType+''''
if @paymentType is not null
set @sql=@sql+' and paymentType='''+@paymentType+''''

if @payoutAgent IS NOT NULL
	SET @sql= @sql+' and expected_payoutagentid='''+ @payoutAgent +''''
if @receiveCountry IS NOT NULL
	SET @sql= @sql+' and pa.country='''+ @receiveCountry +''''
if @senderAgent IS NOT NULL
	SET @sql= @sql+' and agentid='''+ @senderAgent +''''
SET @sql= @sql+' order by rBankBranch,'+@dateType+''
--PRINT @sql
EXEC (@sql)
END 






GO


