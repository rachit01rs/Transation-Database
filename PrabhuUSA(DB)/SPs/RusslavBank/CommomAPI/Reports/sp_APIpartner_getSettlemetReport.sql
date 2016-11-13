    
CREATE proc [dbo].[sp_APIpartner_getSettlemetReport]    
@report_type char(1),    
@agent_id varchar(50),    
@branch_id varchar(50)= NULL,    
@from_date varchar(20),    
@to_date varchar(20),    
@receiverCountry varchar(100)=null,    
@receive_agent_id varchar(50)=null,    
@status varchar(50)=null,    
@main_agent_id varchar(50)=null,    
@agent_type char(1)='a', -- NULL/a MAIN AGENT TYPE , b= Branch Type , d Bank or Deposit type    
@currency_type char(1)='l',    
@grouptype char(1)='d'    
    
as    
declare @sql varchar(5000)    
declare @total_receiver_commission varchar(500),@calc_commission char(1)    
    
set @total_receiver_commission=' (case when isNull(agent_receiverComm_Currency,''l'')=''l'' then agent_receiverCommission else agent_receiverCommission*isNull(paid_date_usd_rate,exchangeRate * agent_settlement_rate) end     
+ isNull(agent_receiverSCommission,0)*agent_settlement_rate)'    
    
if @agent_id is not null    
 select @calc_commission=cal_commission_daily from agentdetail where agentcode=@agent_id    
if @calc_commission='y'    
 set @calc_commission=NULL    
    
if @calc_commission is not null    
 set @total_receiver_commission=0    
    
declare @round_value varchar(2)    
select @round_value=round_value from tbl_setup    
    
if @main_agent_id is null    
 set @main_agent_id=@agent_id    
IF @currency_type IS NULL    
 SET @currency_type='d'    
if @grouptype='d'    
begin    
if @report_type='s' AND @currency_type='d'    
begin    
 set @sql='select  * from(    
 select ReceiverCountry country,NULL branch,convert(varchar,confirmDate,101) DOT,sum(paidAmt/ExchangeRate) PaidAmt,sum(Dollar_Amt) Dollar_Amt,    
 sum(scharge/ExchangeRate) Scharge,sum(isNUll(sendercommission,0)/ExchangeRate) sendercommission,sum(isNull(agent_ex_gain,0)/ExchangeRate) agent_ex_gain,    
 count(*) totNos,    
 sum(paidAmt)-(sum(sendercommission)+sum(isNull(agent_ex_gain,0))) Settlement,    
 sum((paidAmt-(sendercommission+isNull(agent_ex_gain,0)))/ExchangeRate) DollarSettelment,    
 ''S'' TRNMode,sum(isNull(agent_receiverSCommission,0)/ExchangeRate) agent_receiverSCommission,''USD'' curreny_type    
 ,sum(isNULL(Ho_ex_gain,0)) Ho_ex_gain     
,sum(paidAmt) PaidAmt_local, sum(scharge) scharge_local    
,sum(sendercommission) sComm_local, sum(agent_receiverSCommission) rComm_local    
,sum(ext_payout_amount) payoutAmount,max(right(PNBReferenceNo,3)) payoutccycode    
from moneysend with (nolock)    
 where transStatus in (''Payment'',''Cancel'',''Block'') and confirmDate between '''+ @from_date +''' and '''+ @to_date +' 23:59:59''     
 '    
 if @agent_id is not null     
  set @sql=@sql+' and agentID='+@agent_id     
 if @branch_id is not null    
  set @sql=@sql+' and branch_code='+@branch_id    
 if @receiverCountry is not null    
  set @sql=@sql+' and receiverCountry='''+@receiverCountry  +''''    
    
 if @receive_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' group by convert(varchar,confirmDate,101),ReceiverCountry '    
 set @sql=@sql+' union all     
 select m.senderCountry country,NULL branch,convert(varchar,paidDate,101) confirmDate,    
 sum(totalRoundAmt/isNull(paid_date_usd_rate,exchangeRate * today_dollar_rate)) PaidAmt,sum(Dollar_Amt) Dollar_Amt,    
 0 Scharge,sum('+@total_receiver_commission+'/isNull(paid_date_usd_rate,exchangeRate * today_dollar_rate)) receivercommission,    
 0 agent_ex_gain,count(*) totNos,    
 sum((totalRoundAmt+'+@total_receiver_commission+')) Settlement,    
 sum((totalRoundAmt+'+@total_receiver_commission+')/isNull(paid_date_usd_rate,exchangeRate * today_dollar_rate)) DollarSettelment,   ''P'' TRNMode,0,''USD'' paidCtype,sum(isNULL(Ho_ex_gain,0)) Ho_ex_gain     
,sum(totalRoundAmt) PaidAmt_local, 0 scharge_local    
,sum('+@total_receiver_commission+') sComm_local, 0 rComm_local    
,sum(totalroundAmt) payoutAmount,max(receiveCType) payoutccycode    
from moneysend m with (nolock)     
 where status=''Paid'' and paidDate between '''+ @from_date +''' and '''+ @to_date +' 23:59:59'''    
 if @agent_id is not null and @agent_type='d'    
  set @sql=@sql+' and receiveAgentid='''+@agent_id+''''    
 if @main_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@main_agent_id+''''    
 if @branch_id is not null    
  set @sql=@sql+' and rBankid='+@branch_id    
 if @receiverCountry is not null    
  set @sql=@sql+' and m.senderCountry='''+@receiverCountry  +''''    
 if @receive_agent_id is not null    
  set @sql=@sql+' and agentid='''+ @receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' group by convert(varchar,paidDate,101),m.senderCountry'    
 set @sql=@sql+' union all     
select ReceiverCountry country,NULL branch,convert(varchar,cancel_Date,101) DOT,sum(paidAmt/ExchangeRate) PaidAmt,sum(Dollar_Amt) Dollar_Amt,    
 sum(scharge/ExchangeRate) Scharge,sum(isNUll(sendercommission,0)/ExchangeRate) sendercommission,sum(isNull(agent_ex_gain,0)/ExchangeRate) agent_ex_gain,    
 count(*) totNos,     
 sum(paidAmt)-(sum(sendercommission)+sum(isNull(agent_ex_gain,0))) Settlement,    
 sum((paidAmt-(sendercommission+isNull(agent_ex_gain,0)))/ExchangeRate) DollarSettelment,    
 ''C'' TRNMode ,sum(isNull(agent_receiverSCommission,0)/ExchangeRate) agent_receiverSCommission,''USD'' paidCtype    
 ,sum(isNULL(Ho_ex_gain,0)) Ho_ex_gain     
,sum(paidAmt) PaidAmt_local, sum(scharge) scharge_local    
,sum(sendercommission) sComm_local, sum(agent_receiverSCommission) rComm_local    
,sum(ext_payout_amount) payoutAmount,max(right(PNBReferenceNo,3)) payoutccycode    
from moneysend with (nolock)    
 where transStatus=''Cancel'' and cancel_date between '''+ @from_date +''' and '''+ @to_date +' 23:59:59'' '    
 if @agent_id is not null     
  set @sql=@sql+' and agentID='+@agent_id     
 if @branch_id is not null    
  set @sql=@sql+' and branch_code='+@branch_id    
 if @receiverCountry is not null    
  set @sql=@sql+' and receiverCountry='''+@receiverCountry  +''''    
 if @receive_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' group by convert(varchar,cancel_Date,101),ReceiverCountry) f order by TRNMode desc,DOT'    
    
 --print @sql    
 exec(@sql)    
end    
end    
if @grouptype='b'    
begin    
    
-------------- SUMARY DOLLAR REPORT -----------------------    
---- Done    
if @report_type='s' AND @currency_type='d'    
begin    
 set @sql='select  * from(    
 select ReceiverCountry country,branch_code branch,isNull(a.agent_short_code,companyname)+'' - ''+branch  DOT,sum(paidAmt/ExchangeRate) PaidAmt,sum(Dollar_Amt) Dollar_Amt,    
 sum(scharge/ExchangeRate) Scharge,sum(isNUll(sendercommission,0)/ExchangeRate) sendercommission,sum(isNull(agent_ex_gain,0)/ExchangeRate) agent_ex_gain,    
 count(*) totNos,    
 sum(paidAmt)-(sum(sendercommission)+sum(isNull(agent_ex_gain,0))) Settlement,    
 sum((paidAmt-(sendercommission+isNull(agent_ex_gain,0)))/ExchangeRate) DollarSettelment,    
 ''S'' TRNMode,sum(isNull(agent_receiverSCommission,0)) agent_receiverSCommission,''USD'' curreny_type    
 ,sum(isNULL(Ho_ex_gain,0)) Ho_ex_gain     
,sum(paidAmt) PaidAmt_local, sum(scharge) scharge_local    
,sum(sendercommission) sComm_local, sum(agent_receiverSCommission) rComm_local    
,sum(ext_payout_amount) payoutAmount,max(right(PNBReferenceNo,3)) payoutccycode    
from moneysend m with (nolock)     
join agentdetail a with (nolock) on m.agentid=a.agentcode     
 where transStatus in (''Payment'',''Cancel'',''Block'') and confirmDate between '''+ @from_date +''' and '''+ @to_date +' 23:59:59''     
 '    
 if @agent_id is not null     
  set @sql=@sql+' and agentID='+@agent_id     
 if @branch_id is not null    
  set @sql=@sql+' and branch_code='+@branch_id    
 if @receiverCountry is not null    
  set @sql=@sql+' and receiverCountry='''+@receiverCountry  +''''    
    
 if @receive_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' group by isNull(a.agent_short_code,companyname)+'' - ''+branch,branch_code,ReceiverCountry'    
---- for paid txn    
 set @sql=@sql+' union all    
 select m.senderCountry country,rBankID branch,isNull(a.agent_short_code,companyname)+'' - ''+rBankBranch  DOT    
 ,sum(paidAmt/ExchangeRate) PaidAmt,sum(Dollar_Amt) Dollar_Amt,    
 sum(scharge/ExchangeRate) Scharge,sum(isNUll(sendercommission,0)/ExchangeRate) sendercommission,sum(isNull(agent_ex_gain,0)/ExchangeRate) agent_ex_gain,    
 count(*) totNos,    
 sum(paidAmt)-(sum(sendercommission)+sum(isNull(agent_ex_gain,0))) Settlement,    
 sum((paidAmt-(sendercommission+isNull(agent_ex_gain,0)))/ExchangeRate) DollarSettelment,    
 ''P'' TRNMode,sum(isNull(agent_receiverSCommission,0)) agent_receiverSCommission,''USD'' curreny_type    
 ,sum(isNULL(Ho_ex_gain,0)) Ho_ex_gain     
,sum(paidAmt) PaidAmt_local, sum(scharge) scharge_local    
,sum(sendercommission) sComm_local, sum(agent_receiverSCommission) rComm_local    
,sum(totalroundAmt) payoutAmount,max(receiveCType) payoutccycode    
from moneysend m with (nolock)     
join agentdetail a with (nolock) on m.expected_payoutagentid=a.agentcode     
 where status=''Paid'' and paidDate between '''+ @from_date +''' and '''+ @to_date +' 23:59:59''     
 '    
 if @agent_id is not null     
  set @sql=@sql+' and expected_payoutagentid='+@agent_id     
 if @branch_id is not null    
  set @sql=@sql+' and rBankID='+@branch_id    
 if @receiverCountry is not null    
  set @sql=@sql+' and m.senderCountry='''+@receiverCountry  +''''    
 if @receive_agent_id is not null    
  set @sql=@sql+' and agentID='''+@receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' group by isNull(a.agent_short_code,companyname)+'' - ''+rBankBranch,rBankID,m.senderCountry '    
    
 set @sql=@sql+' union all     
 select ReceiverCountry country,branch_code branch,isNull(a.agent_short_code,companyname)+'' - ''+branch DOT,sum(paidAmt/ExchangeRate) PaidAmt,sum(Dollar_Amt) Dollar_Amt,    
 sum(scharge/ExchangeRate) Scharge,sum(isNUll(sendercommission,0)/ExchangeRate) sendercommission,sum(isNull(agent_ex_gain,0)/ExchangeRate) agent_ex_gain,    
 count(*) totNos,     
 sum(paidAmt)-(sum(sendercommission)+sum(isNull(agent_ex_gain,0))) Settlement,    
 sum((paidAmt-(sendercommission+isNull(agent_ex_gain,0)))/ExchangeRate) DollarSettelment,    
 ''C'' TRNMode ,sum(isNull(agent_receiverSCommission,0)/ExchangeRate) agent_receiverSCommission,''USD'' paidCtype    
 ,sum(isNULL(Ho_ex_gain,0)) Ho_ex_gain     
,sum(paidAmt) PaidAmt_local, sum(scharge) scharge_local    
,sum(sendercommission) sComm_local, sum(agent_receiverSCommission) rComm_local    
,sum(ext_payout_amount) payoutAmount,max(right(PNBReferenceNo,3)) payoutccycode    
from moneysend m with (nolock)     
join agentdetail a with (nolock) on m.agentid=a.agentcode     
 where transStatus=''Cancel'' and cancel_date between '''+ @from_date +''' and '''+ @to_date +' 23:59:59''     
 '    
 if @agent_id is not null     
  set @sql=@sql+' and agentID='+@agent_id     
 if @branch_id is not null    
  set @sql=@sql+' and branch_code='+@branch_id    
 if @receiverCountry is not null    
  set @sql=@sql+' and receiverCountry='''+@receiverCountry  +''''    
 if @receive_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' group by isNull(a.agent_short_code,companyname)+'' - ''+branch,branch_code,ReceiverCountry    
) f order by TRNMode desc,DOT'    
    
 --print @sql    
 exec(@sql)    
end    
end    
if @grouptype='a'    
begin    
    
-------------- SUMARY DOLLAR REPORT -----------------------    
---- Done    
if @report_type='s' AND @currency_type='d'    
begin    
 set @sql='select  * from(    
 select ReceiverCountry country,agentid branch,isNull(a.agent_short_code,companyname)  DOT,sum(paidAmt/ExchangeRate) PaidAmt,sum(Dollar_Amt) Dollar_Amt,    
 sum(scharge/ExchangeRate) Scharge,sum(isNUll(sendercommission,0)/ExchangeRate) sendercommission,sum(isNull(agent_ex_gain,0)/ExchangeRate) agent_ex_gain,    
 count(*) totNos,    
 sum(paidAmt)-(sum(sendercommission)+sum(isNull(agent_ex_gain,0))) Settlement,    
 sum((paidAmt-(sendercommission+isNull(agent_ex_gain,0)))/ExchangeRate) DollarSettelment,    
 ''S'' TRNMode,sum(isNull(agent_receiverSCommission,0)) agent_receiverSCommission,''USD'' curreny_type    
 ,sum(isNULL(Ho_ex_gain,0)) Ho_ex_gain     
,sum(paidAmt) PaidAmt_local, sum(scharge) scharge_local    
,sum(sendercommission) sComm_local, sum(agent_receiverSCommission) rComm_local    
,sum(ext_payout_amount) payoutAmount,max(right(PNBReferenceNo,3)) payoutccycode    
from moneysend m with (nolock)     
join agentdetail a with (nolock) on m.agentid=a.agentcode     
 where transStatus in (''Payment'',''Cancel'',''Block'') and confirmDate between '''+ @from_date +''' and '''+ @to_date +' 23:59:59''     
 '    
 if @agent_id is not null     
  set @sql=@sql+' and agentID='+@agent_id     
 if @branch_id is not null    
  set @sql=@sql+' and branch_code='+@branch_id    
 if @receiverCountry is not null    
  set @sql=@sql+' and receiverCountry='''+@receiverCountry  +''''    
    
 if @receive_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' group by isNull(a.agent_short_code,companyname),agentid,ReceiverCountry'    
---- for paid txn    
 set @sql=@sql+' union all    
 select xm.country country,expected_payoutagentid branch,isNull(a.agent_short_code,companyname)  DOT    
 ,sum(paidAmt/ExchangeRate) PaidAmt,sum(Dollar_Amt) Dollar_Amt,    
 sum(scharge/ExchangeRate) Scharge,sum(isNUll(sendercommission,0)/ExchangeRate) sendercommission,sum(isNull(agent_ex_gain,0)/ExchangeRate) agent_ex_gain,    
 count(*) totNos,    
 sum(paidAmt)-(sum(sendercommission)+sum(isNull(agent_ex_gain,0))) Settlement,    
 sum((paidAmt-(sendercommission+isNull(agent_ex_gain,0)))/ExchangeRate) DollarSettelment,    
 ''P'' TRNMode,sum(isNull(agent_receiverSCommission,0)) agent_receiverSCommission,''USD'' curreny_type    
 ,sum(isNULL(Ho_ex_gain,0)) Ho_ex_gain     
,sum(paidAmt) PaidAmt_local, sum(scharge) scharge_local    
,sum(sendercommission) sComm_local, sum(agent_receiverSCommission) rComm_local    
,sum(totalroundAmt) payoutAmount,max(receiveCType) payoutccycode    
from moneysend m with (nolock)     
join agentdetail a with (nolock) on m.expected_payoutagentid=a.agentcode     
join xpressMoney_country xm  with (nolock) on xm.country_code=m.senderCountry    
 where status=''Paid'' and paidDate between '''+ @from_date +''' and '''+ @to_date +' 23:59:59''     
 '    
 if @agent_id is not null     
  set @sql=@sql+' and expected_payoutagentid='+@agent_id     
 if @branch_id is not null    
  set @sql=@sql+' and rBankID='+@branch_id    
 if @receiverCountry is not null    
  set @sql=@sql+' and xm.country='''+@receiverCountry  +''''    
 if @receive_agent_id is not null    
  set @sql=@sql+' and agentID='''+@receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' group by isNull(a.agent_short_code,companyname),expected_payoutagentid,xm.country '    
  
 set @sql=@sql+' union all     
 select ReceiverCountry country,agentid branch,isNull(a.agent_short_code,companyname) DOT,sum(paidAmt/ExchangeRate) PaidAmt,sum(Dollar_Amt) Dollar_Amt,    
 sum(scharge/ExchangeRate) Scharge,sum(isNUll(sendercommission,0)/ExchangeRate) sendercommission,sum(isNull(agent_ex_gain,0)/ExchangeRate) agent_ex_gain,    
 count(*) totNos,     
 sum(paidAmt)-(sum(sendercommission)+sum(isNull(agent_ex_gain,0))) Settlement,    
 sum((paidAmt-(sendercommission+isNull(agent_ex_gain,0)))/ExchangeRate) DollarSettelment,    
 ''C'' TRNMode ,sum(isNull(agent_receiverSCommission,0)/ExchangeRate) agent_receiverSCommission,''USD'' paidCtype    
 ,sum(isNULL(Ho_ex_gain,0)) Ho_ex_gain     
,sum(paidAmt) PaidAmt_local, sum(scharge) scharge_local    
,sum(sendercommission) sComm_local, sum(agent_receiverSCommission) rComm_local    
,sum(ext_payout_amount) payoutAmount,max(right(PNBReferenceNo,3)) payoutccycode    
from moneysend m with (nolock)     
join agentdetail a with (nolock) on m.agentid=a.agentcode     
 where transStatus=''Cancel'' and cancel_date between '''+ @from_date +''' and '''+ @to_date +' 23:59:59''     
 '    
 if @agent_id is not null     
  set @sql=@sql+' and agentID='+@agent_id     
 if @branch_id is not null    
  set @sql=@sql+' and branch_code='+@branch_id    
 if @receiverCountry is not null    
  set @sql=@sql+' and receiverCountry='''+@receiverCountry  +''''    
 if @receive_agent_id is not null    
  set @sql=@sql+' and expected_payoutagentid='''+@receive_agent_id  +''''    
 if @status is not null    
  set @sql=@sql+' and status='''+@status  +''''    
    
 set @sql=@sql+' group by isNull(a.agent_short_code,companyname),agentid,ReceiverCountry    
) f order by TRNMode desc,DOT'    
    
 --print @sql    
 exec(@sql)    
end    
end    
    
    
    