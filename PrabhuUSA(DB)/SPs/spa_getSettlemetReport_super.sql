DROP proc [dbo].[spa_getSettlemetReport_super]    
Go     
--spa_getSettlemetReport 's','10100000',NULL,'2009-07-20','2009-08-05',NULL,NULL,NULL,'10100000','a','l'     
CREATE proc [dbo].[spa_getSettlemetReport_super]    
@report_type char(1),    
@super_agent_id varchar(50),    
@branch_id varchar(50)= NULL,    
@from_date varchar(20),    
@to_date varchar(20),    
@receiverCountry varchar(100)=null,    
@receive_agent_id varchar(50)=null,    
@status varchar(50)=null,    
@main_agent_id varchar(50)=null,    
@agent_type char(1)='a', -- NULL/a MAIN AGENT TYPE , b= Branch Type , d Bank or Deposit type    
@currency_type char(1)=null, -- 'l',    
@grouptype char(1)='d',  
@country VARCHAR(50)=NULL,  
@sendagent VARCHAR(50)=NULL  
    
    
as    
  
if @currency_type is null    
set @currency_type='d'    
    
declare @sql varchar(5000)    
declare @total_receiver_commission varchar(500),@calc_commission char(1),@agent_settlement_paidTXN varchar(50)    
    
set @total_receiver_commission=' (case when isNull(agent_receiverComm_Currency,''l'')=''l'' then agent_receiverCommission else agent_receiverCommission*isNull(paid_date_usd_rate,exchangeRate * agent_settlement_rate) end     
+ isNull(agent_receiverSCommission,0)*agent_settlement_rate)'    
    
    
declare @agent_id varchar(1000)    
set @agent_id=''    
select @agent_id=agentCode +','+ @agent_id  from agentdetail where super_agent_id=@super_agent_id    
set @agent_id=left(@agent_id,len(@agent_id)-1)    
    
if @super_agent_id is not null    
 select @calc_commission=cal_commission_daily,@agent_settlement_paidTXN=isNULL(agent_settlement_date,'PaidDate') from agentdetail where agentcode=@super_agent_id    
    
if @calc_commission='y'    
 set @calc_commission=NULL    
    
if @calc_commission is not null    
 set @total_receiver_commission=0    
    
declare @round_value varchar(2)    
select @round_value=round_value from tbl_setup    
    
if @main_agent_id is null    
 set @main_agent_id=@super_agent_id    
    
if @grouptype='d'    
begin    
if @report_type='s' AND @currency_type='l'    
begin    
 set @sql='select  * from(     
 select convert(varchar,confirmDate,101) DOT,sum(paidAmt) PaidAmt,sum(Dollar_Amt) Dollar_Amt,    
 sum(scharge) Scharge,sum(isNUll(sendercommission,0)) sendercommission,    
sum(isNull(agent_ex_gain,0)) agent_ex_gain,count(*) totNos,    
 sum(paidAmt)-(sum(sendercommission)+sum(isNull(agent_ex_gain,0))) Settlement,    
 sum((paidAmt-(sendercommission+isNull(agent_ex_gain,0)))/ExchangeRate) DollarSettelment,    
 ''S'' TRNMode,sum(isNull(agent_receiverSCommission,0)) agent_receiverSCommission,max(paidCtype) curreny_type from moneysend with(nolock)    
 where transStatus in (''Payment'',''Cancel'',''Block'')     
 and confirmDate between '''+ @from_date +''' and '''+ @to_date +' 23:59:59''     
 and agentID in('+@agent_id+')'  
 if @country is not null    
  set @sql=@sql+' and senderCountry='''+@country  +''''   
 if @sendagent is not null    
  set @sql=@sql+' and agentId='''+@sendagent  +''''    
       
 if @branch_id is not null    
  set @sql=@sql+' and branch_code='+@branch_id    
 if @receiverCountry is not null    
  set @sql=@sql+' and receiverCountry='''+@receiverCountry  +''''    
 if @receive_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' group by convert(varchar,confirmDate,101)'    
 set @sql=@sql+' union all     
    
 select convert(varchar,'+ @agent_settlement_paidTXN +',101) confirmDate,sum(totalRoundAmt) PaidAmt,sum(Dollar_Amt) Dollar_Amt,    
 0 Scharge,sum('+@total_receiver_commission+') receivercommission,0 agent_ex_gain,count(*) totNos,    
 sum(totalRoundAmt)+sum('+@total_receiver_commission+') Settlement,    
 sum((totalRoundAmt+'+@total_receiver_commission+')/isNull(paid_date_usd_rate,exchangeRate * today_dollar_rate)) DollarSettelment,    
 ''P'' TRNMode,0,max(receiveCtype) paidCtype from moneysend with(nolock)    
 where '+ @agent_settlement_paidTXN +' between '''+ @from_date +''' and '''+ @to_date +' 23:59:59'''    
 if @agent_id is not null and @agent_type='d'    
  set @sql=@sql+' and receiveAgentid in('+@agent_id+')'    
 if @country is not null    
  set @sql=@sql+' and receiverCountry='''+@country+''''   
 if @sendagent is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@sendagent+''''    
 --if @main_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid in('+@agent_id+')'    
 if @branch_id is not null    
  set @sql=@sql+' and rBankid='+@branch_id    
 if @receiverCountry is not null    
  set @sql=@sql+' and senderCountry='''+@receiverCountry  +''''    
 if @receive_agent_id is not null    
  set @sql=@sql+' and agentid='''+ @receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' group by convert(varchar,'+ @agent_settlement_paidTXN +',101)'    
 set @sql=@sql+' union all     
 select convert(varchar,cancel_Date,101) DOT,sum(paidAmt) PaidAmt,sum(Dollar_Amt) Dollar_Amt,    
 sum(scharge) Scharge,sum(sendercommission) sendercommission,sum(isNull(agent_ex_gain,0)) agent_ex_gain,count(*) totNos,    
 sum(paidAmt)-(sum(sendercommission)+sum(isNull(agent_ex_gain,0))) Settlement,    
 sum((paidAmt-(sendercommission+isNull(agent_ex_gain,0)))/ExchangeRate) DollarSettelment,    
 ''C'' TRNMode ,sum(isNull(agent_receiverSCommission,0)) agent_receiverSCommission,max(paidCtype) paidCtype    
 from moneysend with(nolock) where transStatus=''Cancel'' and cancel_date between '''+ @from_date +''' and '''+ @to_date +' 23:59:59''     
 and agentID in('+@agent_id+')'    
   if @country is not null    
  set @sql=@sql+' and senderCountry='''+@country+''''   
 if @sendagent is not null    
  set @sql=@sql+' and agentID='''+@sendagent+''''    
 if @branch_id is not null    
  set @sql=@sql+' and branch_code='+@branch_id    
 if @receiverCountry is not null    
  set @sql=@sql+' and receiverCountry='''+@receiverCountry  +''''    
 if @receive_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' group by convert(varchar,cancel_Date,101)) f order by TRNMode desc,DOT'    
    
-- print @sql    
 exec(@sql)    
end    
-------------- SUMARY DOLLAR REPORT -----------------------    
ELSE if @report_type='s' AND @currency_type='d'    
begin    
 set @sql='select  * from(    
 select convert(varchar,confirmDate,101) DOT,sum(paidAmt/ExchangeRate) PaidAmt,sum(Dollar_Amt) Dollar_Amt,    
 sum(scharge/ExchangeRate) Scharge,sum(isNUll(sendercommission,0)/ExchangeRate) sendercommission,sum(isNull(agent_ex_gain,0)/ExchangeRate) agent_ex_gain,    
 count(*) totNos,    
 sum(paidAmt)-(sum(sendercommission)+sum(isNull(agent_ex_gain,0))) Settlement,    
sum((paidAmt-(sendercommission+isNull(agent_ex_gain,0)))/ExchangeRate) DollarSettelment,    
 ''S'' TRNMode,sum(isNull(agent_receiverSCommission,0)) agent_receiverSCommission,''USD'' curreny_type from moneysend with(nolock)    
 where transStatus in (''Payment'',''Cancel'',''Block'') and confirmDate between '''+ @from_date +''' and '''+ @to_date +' 23:59:59''     
 and agentID in('+@agent_id+')'   
    if @country is not null    
  set @sql=@sql+' and senderCountry='''+@country+''''   
 if @sendagent is not null    
  set @sql=@sql+' and agentID='''+@sendagent+''''   
 if @branch_id is not null    
  set @sql=@sql+' and branch_code='+@branch_id    
 if @receiverCountry is not null    
  set @sql=@sql+' and receiverCountry='''+@receiverCountry  +''''    
    
 if @receive_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' group by convert(varchar,confirmDate,101)'    
 set @sql=@sql+' union all     
 select convert(varchar,'+ @agent_settlement_paidTXN +',101) confirmDate,sum(totalRoundAmt/isNull(paid_date_usd_rate,exchangeRate * today_dollar_rate)) PaidAmt,sum(Dollar_Amt) Dollar_Amt,    
 0 Scharge,sum('+@total_receiver_commission+'/isNull(paid_date_usd_rate,exchangeRate * today_dollar_rate)) receivercommission,0 agent_ex_gain,count(*) totNos,    
 sum((totalRoundAmt+'+@total_receiver_commission+')) Settlement,    
 sum((totalRoundAmt+'+@total_receiver_commission+')/isNull(paid_date_usd_rate,exchangeRate * today_dollar_rate)) DollarSettelment,    
 ''P'' TRNMode,0,''USD'' paidCtype from moneysend with(nolock)     
 where '+ @agent_settlement_paidTXN +' between '''+ @from_date +''' and '''+ @to_date +' 23:59:59'''    
 if @agent_id is not null and @agent_type='d'    
  set @sql=@sql+' and receiveAgentid in('+@agent_id+')'   
 if @country is not null    
  set @sql=@sql+' and receiverCountry='''+@country+''''   
 if @sendagent is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@sendagent+''''   
 --if @main_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid in('+@agent_id+')'    
 if @branch_id is not null    
  set @sql=@sql+' and rBankid='+@branch_id    
 if @receiverCountry is not null    
  set @sql=@sql+' and senderCountry='''+@receiverCountry  +''''    
 if @receive_agent_id is not null    
  set @sql=@sql+' and agentid='''+ @receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' group by convert(varchar,'+ @agent_settlement_paidTXN +',101)'    
 set @sql=@sql+' union all     
select convert(varchar,cancel_Date,101) DOT,sum(paidAmt/ExchangeRate) PaidAmt,sum(Dollar_Amt) Dollar_Amt,    
 sum(scharge/ExchangeRate) Scharge,sum(isNUll(sendercommission,0)/ExchangeRate) sendercommission,sum(isNull(agent_ex_gain,0)/ExchangeRate) agent_ex_gain,    
 count(*) totNos,     
 sum(paidAmt)-(sum(sendercommission)+sum(isNull(agent_ex_gain,0))) Settlement,    
sum((paidAmt-(sendercommission+isNull(agent_ex_gain,0)))/ExchangeRate) DollarSettelment,    
 ''C'' TRNMode ,sum(isNull(agent_receiverSCommission,0)) agent_receiverSCommission,''USD'' paidCtype    
 from moneysend with(nolock)    
 where transStatus=''Cancel'' and cancel_date between '''+ @from_date +''' and '''+ @to_date +' 23:59:59''     
 and agentID in('+@agent_id+')'   
if @country is not null    
  set @sql=@sql+' and senderCountry='''+@country+''''   
 if @sendagent is not null    
  set @sql=@sql+' and agentID='''+@sendagent+''''   
 if @branch_id is not null    
  set @sql=@sql+' and branch_code='+@branch_id    
 if @receiverCountry is not null    
  set @sql=@sql+' and receiverCountry='''+@receiverCountry  +''''    
 if @receive_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' group by convert(varchar,cancel_Date,101)) f order by TRNMode desc,DOT'    
    
 --print @sql    
 exec(@sql)    
end    
else if @report_type='d' AND @currency_type='l'    
begin    
    
set @sql='    
select  * from(     
 select tranno,convert(varchar,confirmDate,101) DOT,SenderName,paidAmt PaidAmt,Dollar_Amt,    
 scharge Scharge,sendercommission sendercommission,isNull(agent_ex_gain,0) agent_ex_gain,    
 paidAmt-(sendercommission+isNull(agent_ex_gain,0)) Settlement,    
 (paidAmt-(sendercommission+isNull(agent_ex_gain,0)))/ExchangeRate DollarSettelment,    
 ''S'' TRNMode,Today_Dollar_Rate,TotalRoundAmt,ReceiveCType,isNull(agent_receiverSCommission,0) agent_receiverSCommission,paidCtype curreny_type    
  from moneysend with(nolock)    
 where transStatus in (''Payment'',''Cancel'',''Block'') and confirmDate between '''+ @from_date +''' and '''+ @to_date +' 23:59:59''     
 and agentID in('+@agent_id+')'    
 if @country is not null    
  set @sql=@sql+' and senderCountry='''+@country+''''   
 if @sendagent is not null    
  set @sql=@sql+' and agentID='''+@sendagent+''''   
     
 if @branch_id is not null    
  set @sql=@sql+' and branch_code='+@branch_id     
 if @receiverCountry is not null    
  set @sql=@sql+' and receiverCountry='''+@receiverCountry  +''''    
    
 if @receive_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' union all     
 select tranno,convert(varchar,'+ @agent_settlement_paidTXN +',101) confirmDate,ReceiverName, (totalRoundAmt) PaidAmt,Dollar_Amt,    
 0 Scharge,(isNUll('+@total_receiver_commission+',0)) receivercommission,0 agent_ex_gain,    
  (totalRoundAmt)+(isNUll('+@total_receiver_commission+',0)) Settlement,    
  (totalRoundAmt+'+@total_receiver_commission+')/isNull(paid_date_usd_rate,exchangeRate * today_dollar_rate) DollarSettelment,    
 ''P'' TRNMode,0 Today_Dollar_Rate,TotalRoundAmt,ReceiveCType,0,ReceiveCType from moneysend with(nolock)     
 where '+ @agent_settlement_paidTXN +' between '''+ @from_date +''' and '''+ @to_date +' 23:59:59'''     
    
 if @agent_id is not null and @agent_type='d'    
  set @sql=@sql+' and receiveAgentid in('+@agent_id+')'    
 --if @main_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid in('+@agent_id+')'    
   if @country is not null    
  set @sql=@sql+' and receiverCountry='''+@country  +''''   
 if @sendagent is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@sendagent  +''''  
    
 if @branch_id is not null    
  set @sql=@sql+' and rBankid='+@branch_id    
 if @receiverCountry is not null    
  set @sql=@sql+' and senderCountry='''+@receiverCountry  +''''    
    
 if @receive_agent_id is not null    
  set @sql=@sql+' and agentid='''+@receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' union all     
 select tranno,convert(varchar,cancel_Date,101) DOT,SenderName,paidAmt PaidAmt,Dollar_Amt,    
 scharge Scharge,isNUll(sendercommission,0) sendercommission,isNull(agent_ex_gain,0) agent_ex_gain,    
 paidAmt- (sendercommission+isNull(agent_ex_gain,0)) Settlement,    
 (paidAmt-(sendercommission+isNull(agent_ex_gain,0))) /ExchangeRate DollarSettelment,    
 ''C'' TRNMode,Today_Dollar_Rate,TotalRoundAmt,ReceiveCType,isNull(agent_receiverSCommission,0),PaidCtype    
 from moneysend with(nolock)     
 where transStatus in (''Cancel'') and cancel_date between '''+ @from_date +''' and '''+ @to_date +' 23:59:59''    
 and agentID in('+@agent_id+')'  
  if @country is not null    
  set @sql=@sql+' and senderCountry='''+@country  +''''   
 if @sendagent is not null    
  set @sql=@sql+' and agentID='''+@sendagent  +''''  
      
 if @branch_id is not null    
  set @sql=@sql+' and branch_code='+@branch_id     
 if @receiverCountry is not null    
  set @sql=@sql+' and receiverCountry='''+@receiverCountry  +''''    
    
 if @receive_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
 set @sql=@sql+') f order by TRNMode desc,dot,ReceiveCType'    
     
 --print @sql    
 exec(@sql)    
    
end    
else if @report_type='d' AND @currency_type='d'    
begin    
    
set @sql='    
select  * from(     
 select tranno,convert(varchar,confirmDate,101) DOT,SenderName,paidAmt/ExchangeRate PaidAmt,Dollar_Amt,    
 scharge/ExchangeRate Scharge,sendercommission/ExchangeRate sendercommission,isNull(agent_ex_gain,0)/ExchangeRate agent_ex_gain,    
 paidAmt-(sendercommission+isNull(agent_ex_gain,0)) Settlement,    
 (paidAmt-(sendercommission+isNull(agent_ex_gain,0)))/ExchangeRate DollarSettelment,    
 ''S'' TRNMode,Today_Dollar_Rate,TotalRoundAmt,ReceiveCType,isNull(agent_receiverSCommission,0) agent_receiverSCommission,''USD'' curreny_type    
  from moneysend with(nolock)     
 where transStatus in (''Payment'',''Cancel'',''Block'') and confirmDate between '''+ @from_date +''' and '''+ @to_date +' 23:59:59''     
 and agentID in('+@agent_id+')'    
   if @country is not null    
  set @sql=@sql+' and senderCountry='''+@country  +''''   
 if @sendagent is not null    
  set @sql=@sql+' and agentID='''+@sendagent  +''''    
 if @branch_id is not null    
  set @sql=@sql+' and branch_code='+@branch_id     
 if @receiverCountry is not null    
  set @sql=@sql+' and receiverCountry='''+@receiverCountry  +''''    
    
 if @receive_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' union all     
 select tranno,convert(varchar,'+ @agent_settlement_paidTXN +',101) confirmDate,ReceiverName, (totalRoundAmt)/isNull(paid_date_usd_rate,exchangeRate * today_dollar_rate) PaidAmt,Dollar_Amt,    
 0 Scharge,isNUll('+@total_receiver_commission+',0)/isNull(paid_date_usd_rate,exchangeRate * today_dollar_rate) receivercommission,0 agent_ex_gain,    
  (totalRoundAmt)+(isNUll('+@total_receiver_commission+',0)) Settlement,    
  (totalRoundAmt+'+@total_receiver_commission+')/isNull(paid_date_usd_rate,exchangeRate * today_dollar_rate) DollarSettelment,    
 ''P'' TRNMode,0 Today_Dollar_Rate,TotalRoundAmt,ReceiveCType,0,''USD'' from moneysend     
 where '+ @agent_settlement_paidTXN +' between '''+ @from_date +''' and '''+ @to_date +' 23:59:59'''     
    
 if @agent_id is not null and @agent_type='d'    
  set @sql=@sql+' and receiveAgentid in('+@agent_id+')'    
 --if @main_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid in('+@agent_id+')'    
    if @country is not null    
  set @sql=@sql+' and receiverCountry='''+@country  +''''   
 if @sendagent is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@sendagent  +''''  
 if @branch_id is not null    
  set @sql=@sql+' and rBankid='+@branch_id    
 if @receiverCountry is not null    
  set @sql=@sql+' and senderCountry='''+@receiverCountry  +''''    
    
 if @receive_agent_id is not null    
  set @sql=@sql+' and agentid='''+@receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' union all     
 select tranno,convert(varchar,cancel_Date,101) DOT,SenderName,paidAmt/ExchangeRate PaidAmt,Dollar_Amt,    
 scharge/ExchangeRate Scharge,isNUll(sendercommission,0) /ExchangeRate sendercommission,isNull(agent_ex_gain,0) /ExchangeRate agent_ex_gain,    
 paidAmt-(sendercommission+isNull(agent_ex_gain,0)) Settlement,    
 (paidAmt-(sendercommission+isNull(agent_ex_gain,0)))/ExchangeRate DollarSettelment,    
 ''C'' TRNMode,Today_Dollar_Rate,TotalRoundAmt,ReceiveCType,isNull(agent_receiverSCommission,0),''USD''    
 from moneysend with(nolock)    
 where transStatus in (''Cancel'') and cancel_date between '''+ @from_date +''' and '''+ @to_date +' 23:59:59''    
 and agentID in('+@agent_id+')'   
   if @country is not null    
  set @sql=@sql+' and senderCountry='''+@country  +''''   
 if @sendagent is not null    
  set @sql=@sql+' and agentID='''+@sendagent  +''''   
 if @branch_id is not null    
  set @sql=@sql+' and branch_code='+@branch_id     
 if @receiverCountry is not null    
  set @sql=@sql+' and receiverCountry='''+@receiverCountry  +''''    
    
 if @receive_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
 set @sql=@sql+') f order by TRNMode desc,DOT,ReceiveCType'    
     
 --print @sql    
 exec(@sql)    
end    
end    
if @grouptype='b'    
begin    
if @report_type='s' AND @currency_type='l'    
begin    
 set @sql='select  * from( select Branch DOT,sum(paidAmt) PaidAmt,sum(Dollar_Amt) Dollar_Amt,    
 sum(scharge) Scharge,sum(isNUll(sendercommission,0)) sendercommission,sum(isNull(agent_ex_gain,0)) agent_ex_gain,count(*) totNos,    
 sum(paidAmt)-(sum(sendercommission)+sum(isNull(agent_ex_gain,0))) Settlement,    
 sum((paidAmt-(sendercommission+isNull(agent_ex_gain,0)))/ExchangeRate) DollarSettelment,    
 ''S'' TRNMode,sum(isNull(agent_receiverSCommission,0)) agent_receiverSCommission,max(paidCtype) curreny_type from moneysend with(nolock)     
 where transStatus in (''Payment'',''Cancel'',''Block'') and confirmDate between '''+ @from_date +''' and '''+ @to_date +' 23:59:59''     
 and agentID in('+@agent_id+')'  
  if @country is not null    
  set @sql=@sql+' and senderCountry='''+@country  +''''   
 if @sendagent is not null    
  set @sql=@sql+' and agentId='''+@sendagent  +''''      
 if @branch_id is not null    
  set @sql=@sql+' and branch_code='+@branch_id    
 if @receiverCountry is not null    
  set @sql=@sql+' and receiverCountry='''+@receiverCountry  +''''    
    
 if @receive_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' group by Branch'    
 set @sql=@sql+' union all     
 select rbankBranch confirmDate,sum(totalRoundAmt) PaidAmt,sum(Dollar_Amt) Dollar_Amt,    
 0 Scharge,sum('+@total_receiver_commission+') receivercommission,0 agent_ex_gain,count(*) totNos,    
 sum(totalRoundAmt)+sum('+@total_receiver_commission+') Settlement,    
 sum((totalRoundAmt+'+@total_receiver_commission+')/isNull(paid_date_usd_rate,exchangeRate * today_dollar_rate)) DollarSettelment,    
 ''P'' TRNMode,0,max(receiveCtype) paidCtype from moneysend with(nolock)    
 where '+ @agent_settlement_paidTXN +' between '''+ @from_date +''' and '''+ @to_date +' 23:59:59'''    
 if @agent_id is not null and @agent_type='d'    
  set @sql=@sql+' and receiveAgentid in('+@agent_id+')'    
 --if @main_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid in('+@agent_id+')'   
     if @country is not null    
  set @sql=@sql+' and receiverCountry='''+@country  +''''   
 if @sendagent is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@sendagent  +''''     
 if @branch_id is not null    
  set @sql=@sql+' and rBankid='+@branch_id    
 if @receiverCountry is not null    
  set @sql=@sql+' and senderCountry='''+@receiverCountry  +''''    
 if @receive_agent_id is not null    
  set @sql=@sql+' and agentid='''+ @receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' group by rbankBranch'    
 set @sql=@sql+' union all     
 select branch DOT,sum(paidAmt) PaidAmt,sum(Dollar_Amt) Dollar_Amt,    
 sum(scharge) Scharge,sum(sendercommission) sendercommission,sum(isNull(agent_ex_gain,0)) agent_ex_gain,count(*) totNos,    
 sum(paidAmt)-(sum(sendercommission)+sum(isNull(agent_ex_gain,0))) Settlement,    
 sum((paidAmt-(sendercommission+isNull(agent_ex_gain,0)))/ExchangeRate) DollarSettelment,    
 ''C'' TRNMode ,sum(isNull(agent_receiverSCommission,0)) agent_receiverSCommission,max(paidCtype) paidCtype    
 from moneysend with(nolock)    
 where transStatus=''Cancel'' and cancel_date between '''+ @from_date +''' and '''+ @to_date +' 23:59:59''     
 and agentID in('+@agent_id+')'   
    if @country is not null    
  set @sql=@sql+' and senderCountry='''+@country  +''''   
 if @sendagent is not null    
  set @sql=@sql+' and agentID='''+@sendagent  +''''     
 if @branch_id is not null    
  set @sql=@sql+' and branch_code='+@branch_id    
 if @receiverCountry is not null    
  set @sql=@sql+' and receiverCountry='''+@receiverCountry  +''''    
 if @receive_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' group by branch) f order by TRNMode desc,DOT'    
    
 --print @sql    
 exec(@sql)    
end    
-------------- SUMARY DOLLAR REPORT -----------------------    
ELSE if @report_type='s' AND @currency_type='d'    
begin    
 set @sql='select  * from(    
 select branch DOT,sum(paidAmt/ExchangeRate) PaidAmt,sum(Dollar_Amt) Dollar_Amt,    
 sum(scharge/ExchangeRate) Scharge,sum(isNUll(sendercommission,0)/ExchangeRate) sendercommission,sum(isNull(agent_ex_gain,0)/ExchangeRate) agent_ex_gain,    
 count(*) totNos,    
 sum(paidAmt)-(sum(sendercommission)+sum(isNull(agent_ex_gain,0))) Settlement,    
sum((paidAmt-(sendercommission+isNull(agent_ex_gain,0)))/ExchangeRate) DollarSettelment,    
 ''S'' TRNMode,sum(isNull(agent_receiverSCommission,0)) agent_receiverSCommission,''USD'' curreny_type from moneysend with(nolock)     
 where transStatus in (''Payment'',''Cancel'',''Block'') and confirmDate between '''+ @from_date +''' and '''+ @to_date +' 23:59:59''     
 and agentID in('+@agent_id+')'    
     if @country is not null    
  set @sql=@sql+' and senderCountry='''+@country  +''''   
 if @sendagent is not null    
  set @sql=@sql+' and agentID='''+@sendagent  +''''     
 if @branch_id is not null    
  set @sql=@sql+' and branch_code='+@branch_id    
 if @receiverCountry is not null    
  set @sql=@sql+' and receiverCountry='''+@receiverCountry  +''''    
    
 if @receive_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' group by branch'    
 set @sql=@sql+' union all     
 select rBankBranch confirmDate,sum(totalRoundAmt/isNull(paid_date_usd_rate,exchangeRate * today_dollar_rate)) PaidAmt,sum(Dollar_Amt) Dollar_Amt,    
 0 Scharge,sum('+@total_receiver_commission+'/isNull(paid_date_usd_rate,exchangeRate * today_dollar_rate)) receivercommission,0 agent_ex_gain,count(*) totNos,    
 sum((totalRoundAmt+'+@total_receiver_commission+')) Settlement,    
 sum((totalRoundAmt+'+@total_receiver_commission+')/isNull(paid_date_usd_rate,exchangeRate * today_dollar_rate)) DollarSettelment,    
 ''P'' TRNMode,0,''USD'' paidCtype from moneysend with(nolock)     
 where '+ @agent_settlement_paidTXN +' between '''+ @from_date +''' and '''+ @to_date +' 23:59:59'''    
 if @agent_id is not null and @agent_type='d'    
  set @sql=@sql+' and receiveAgentid in('+@agent_id+')'    
 --if @main_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid in('+@agent_id+')'   
      if @country is not null    
  set @sql=@sql+' and receiverCountry='''+@country  +''''   
 if @sendagent is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@sendagent  +''''      
 if @branch_id is not null    
  set @sql=@sql+' and rBankid='+@branch_id    
 if @receiverCountry is not null    
  set @sql=@sql+' and senderCountry='''+@receiverCountry  +''''    
 if @receive_agent_id is not null    
  set @sql=@sql+' and agentid='''+ @receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' group by rBankBranch'    
 set @sql=@sql+' union all     
select branch DOT,sum(paidAmt/ExchangeRate) PaidAmt,sum(Dollar_Amt) Dollar_Amt,    
 sum(scharge/ExchangeRate) Scharge,sum(isNUll(sendercommission,0)/ExchangeRate) sendercommission,sum(isNull(agent_ex_gain,0)/ExchangeRate) agent_ex_gain,    
 count(*) totNos,     
 sum(paidAmt)-(sum(sendercommission)+sum(isNull(agent_ex_gain,0))) Settlement,    
sum((paidAmt-(sendercommission+isNull(agent_ex_gain,0)))/ExchangeRate) DollarSettelment,    
 ''C'' TRNMode ,sum(isNull(agent_receiverSCommission,0)) agent_receiverSCommission,''USD'' paidCtype    
 from moneysend with(nolock)    
 where transStatus=''Cancel'' and cancel_date between '''+ @from_date +''' and '''+ @to_date +' 23:59:59''     
 and agentID in('+@agent_id+')'   
     if @country is not null    
  set @sql=@sql+' and senderCountry='''+@country  +''''   
 if @sendagent is not null    
  set @sql=@sql+' and agentID='''+@sendagent  +''''      
 if @branch_id is not null    
  set @sql=@sql+' and branch_code='+@branch_id    
 if @receiverCountry is not null    
  set @sql=@sql+' and receiverCountry='''+@receiverCountry  +''''    
 if @receive_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' group by branch) f order by TRNMode desc,DOT'    
    
 --print @sql    
 exec(@sql)    
end    
end   