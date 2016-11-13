DROP PROC [dbo].[spa_get_montlyReport_detail]  
GO  
create PROC [dbo].[spa_get_montlyReport_detail]    
@send_agent_id varchar(50)=NULL,    
@payout_agent_id varchar(50)=NULL,    
@payout_country varchar(100)=NULL,    
@year int,    
@month int=null,    
@process_id varchar(200)=NULL,    
@login_user_id varchar(50)=NULL,    
@batch_Id varchar(100)=null  ,  
@sendercountry VARCHAR(50)=NULL,  
@sender_state VARCHAR(50)=NULL   
    
as    
--BEGIN try    
DECLARE @temptablename varchar(200),@sql_table varchar(500)    
  set @temptablename=dbo.FNAProcessTBl(@batch_Id, @login_user_id, @process_id)    
  set @sql_table='create table '+@temptablename+'(    
  AgentName varchar(150),    
  TotTRN int,    
  SendTot int,    
  SENDAMT money,    
  SENDUSD money,    
  CANCELTot int,    
  CANCELAMT  Money,    
  CANCELUSD Money,    
  UNPAID int,    
  PAID int,    
  TRN_Paid_Current int,    
  Service_USD Money,    
  HO_Servic_USD money,    
  Paid_NPR money,    
  Total_Paid_NPR_Current money,    
  BLOCKEDTRN int    
  )'    
  exec(@sql_table)    
    
DECLARE @sql varchar(5000),@from_date varchar(20),@to_date varchar(50),@sel_Label varchar(100)    
IF @month IS NULL    
BEGIN    
 SET @from_date=cast(@year AS varchar)+'-01-01'    
 SET @to_date=cast(@year AS varchar)+'-12-31'    
 SET @sel_Label=cast(@year AS varchar)    
END     
else    
BEGIN    
 SET @from_date=cast(@year AS varchar)+'-'+cast(@month AS varchar)+'-01'    
 SET @to_date=cast(@year AS varchar)+'-'+cast(@month AS varchar)+'-'+ cast(dbo.FNALastDayInMonth(@from_date) as varchar)    
 SET @sel_Label=datename(mm,@from_date)    
END     
SET @sql='    
insert '+ @temptablename +'(AgentName,TotTRN ,SendTot , SENDAMT ,SENDUSD ,CANCELTot ,CANCELAMT  ,CANCELUSD ,    
UNPAID ,PAID ,TRN_Paid_Current ,Service_USD ,HO_Servic_USD ,Paid_NPR ,Total_Paid_NPR_Current ,BLOCKEDTRN )    
SELECT agentname,count(*) TotTRN,    
count(case WHEN transStatus=''Payment'' THEN tranno ELSE NULL end) SendTot,    
sum(case WHEN transStatus=''Payment'' THEN paidAmt ELSE 0 end) SENDAMT,    
sum(case WHEN transStatus=''Payment'' THEN Dollar_amt ELSE 0 end) SENDUSD,    
count(case WHEN transStatus=''Cancel'' THEN tranno ELSE NULL end) CANCELTot,    
sum(case WHEN transStatus=''Cancel'' THEN paidAmt ELSE 0 end) CANCELAMT,    
sum(case WHEN transStatus=''Cancel'' THEN Dollar_amt ELSE 0 end) CANCELUSD,    
count(case WHEN status=''Un-Paid'' AND transStatus=''Payment'' THEN tranno ELSE NULL end) UNPAID,    
count(case WHEN status IN (''Paid'',''Post'') THEN tranno ELSE NULL end) PAID,    
count(case WHEN status IN (''Paid'',''Post'')     
AND paidDate between '''+@from_date+''' and '''+@to_date+' 23:59:59'' THEN tranno ELSE NULL end) TRN_Paid_Current,    
sum(case WHEN transStatus=''Payment'' THEN (SCharge/exchangeRate) ELSE 0 end) Service_USD,    
sum(case WHEN transStatus=''Payment'' THEN ((SCharge-sendercommission)/exchangeRate) ELSE 0 end) HO_Servic_USD,    
sum(case WHEN transStatus=''Payment'' THEN TotalRoundAmt ELSE 0 end) Paid_NPR,    
sum(case WHEN status IN (''Paid'',''Post'')     
AND paidDate between '''+@from_date+''' and '''+@to_date+' 23:59:59'' THEN TotalRoundAmt ELSE 0 end) Total_Paid_Current,    
count(case WHEN transStatus=''Block'' THEN Tranno ELSE NULL end) BLOCKEDTRN    
FROM     
(    
select tranno,agentname,status,transStatus,TotalRoundAmt,SCharge,    
exchangeRate,Dollar_amt,paidAmt,sendercommission,paidDate FROM     
moneysend m with (nolock)   
join agentdetail s with (nolock) on m.agentid=s.agentcode   
WHERE confirmdate BETWEEN '''+@from_date+''' AND '''+@to_date+' 23:59:59'''    
IF @send_agent_id IS NOT NULL    
 SET @sql=@sql+ ' and agentid='''+ @send_agent_id +''''    
if @sendercountry IS NOT NULL        
  SET @sql= @sql+' and  m.sendercountry='''+ @sendercountry +''''  
if @sender_state IS NOT NULL      
  SET @sql= @sql+' and s.state='''+ @sender_state +''''   
IF @payout_agent_id IS NOT NULL    
 SET @sql=@sql+ ' and expected_payoutagentid='''+ @payout_agent_id +''''    
IF @payout_country IS NOT NULL    
 SET @sql=@sql+ ' and receiverCountry='''+ @payout_country +''''    
SET @sql=@sql+ '    
UNION ALL     
    
SELECT tranno,agentname,status,transStatus,TotalRoundAmt,SCharge,    
exchangeRate,Dollar_amt,paidAmt,sendercommission,paidDate FROM moneysend_arch1 m with (nolock)   
join agentdetail s with (nolock) on m.agentid=s.agentcode  
WHERE confirmdate BETWEEN '''+@from_date+''' AND '''+@to_date+' 23:59:59'''    
IF @send_agent_id IS NOT NULL    
 SET @sql=@sql+ ' and agentid='''+ @send_agent_id +''''  
if @sendercountry IS NOT NULL        
  SET @sql= @sql+' and  m.sendercountry='''+ @sendercountry +''''  
if @sender_state IS NOT NULL      
  SET @sql= @sql+' and s.state='''+ @sender_state +''''     
IF @payout_agent_id IS NOT NULL    
 SET @sql=@sql+ ' and expected_payoutagentid='''+ @payout_agent_id +''''    
IF @payout_country IS NOT NULL    
 SET @sql=@sql+ ' and receiverCountry='''+ @payout_country +''''    
SET @sql=@sql+ '    
) l    
GROUP BY agentname'    
print @sql    
exec(@sql)    
    
declare @msg_agenttype varchar(100),@url_desc varchar(200),    
@sender_agentname varchar(150),@payout_agentname varchar(150),@desc varchar(1000)    
    
set @msg_agenttype=''    
IF @send_agent_id IS NOT null    
BEGIN    
 SELECT @sender_agentname=companyName FROM agentdetail  WHERE agentcode=@send_agent_id    
 SET @msg_agenttype=' <b>Detail</b> Send Agent:'+ @sender_agentname    
END     
else    
BEGIN    
 SET @msg_agenttype=' <b>Detail</b> Send Agent:ALL'     
end    
IF @sendercountry  IS NOT NULL    
 SET @msg_agenttype=@msg_agenttype+ '/ sender Country: ' + @sendercountry    
IF @sender_state  IS NOT NULL    
 SELECT  @msg_agenttype=@msg_agenttype+ '/ sender state: ' + isNull(static_value,'') FROM dbo.static_values   
 WHERE sno=100 AND static_data= @sender_state  
  
IF @payout_agent_id IS NOT null    
BEGIN    
 SELECT @payout_agentname=companyName FROM agentdetail  WHERE agentcode=@payout_agent_id    
 SET @msg_agenttype=@msg_agenttype+ '/ Payout Agent:'+ @payout_agentname    
END     
else    
BEGIN    
 SET @msg_agenttype=@msg_agenttype+ '/ Payout Agent: ALL'    
end    
  
IF @payout_country  IS NOT NULL    
 SET @msg_agenttype=@msg_agenttype+ '/ payout Country: ' + @payout_country    
     
set @url_desc='year='+cast(@year  AS varchar)+'&month='+isNUll(cast(@month AS varchar),'ALL')    
set @url_desc=@url_desc+'&msg='+@msg_agenttype+'&ReportType=d'    
    
 set @desc =upper(@batch_id)+' '+ @msg_agenttype +' is completed for Year:' + cast(@year  AS varchar)     
 if @month is not null    
 begin    
 set @desc=@desc+ ' Month:'+cast(@month AS varchar)    
  end     
 EXEC  spa_message_board 'u', @login_user_id,    
    NULL, @batch_id,    
    @desc, 'c', @process_id,null,@url_desc    
    
    
--end try    
--begin catch    
--     
-- set @desc='Technical Error:  (' + ERROR_MESSAGE() + ')'    
--     
-- EXEC  spa_message_board 'u', @login_user_id,    
--    NULL,@batch_id,    
--    @desc, 'c', @process_id,null,null    
-- PRINT @desc    
--end catch    