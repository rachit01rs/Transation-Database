DROP procedure [dbo].[spa_monthly_soa]  
GO  
CREATE procedure [dbo].[spa_monthly_soa]  
@flag char(1)=null,  
@agentId varchar(50)=Null,  
@agentName varchar(150)=Null,  
@dateType varchar(50)=Null,  
@month varchar(50)=Null,  
@year varchar(50)=Null,  
@userId varchar(50)=Null,  
@process_id varchar(150)=NULL,  
@batch_Id varchar(50)=NULL,  
@calc_currency char(1)=null   
as   
  
  
declare @desc varchar(1000)  
declare @sql varchar(8000)  
declare @temptablename varchar(500)  
declare @process_id_new varchar(100)  
declare  @agentType varchar(50), @agent_id varchar(1000), @super varchar(50)  
  
  
  
declare @agent_settlement_date varchar(50),@payout_settle_usd varchar(50)  
declare @calc_commission  varchar(50)  
declare @super_agent_id varchar(50)  
set @super_agent_id=@agentId  
  
if @super_agent_id is not null  
 select @calc_commission=cal_commission_daily,  
 @agent_settlement_date=isNULL(agent_settlement_date,'ConfirmDate')  
 from agentdetail where agentcode=@super_agent_id   
  
if @flag='p'  
 set @calc_currency='d'  
  
if @agent_settlement_date='ConfirmDate'  
 set @payout_settle_usd='payout_settle_usd'  
else  
 set @payout_settle_usd='paid_date_usd_rate'  
  
declare @send_fx_clm varchar(50),@paid_fx_clm varchar(500),@balance_fx_clm varchar(50)  
declare @curr_type varchar(50)  
  
if @calc_currency='l' or @calc_currency is null  
begin  
   
 select @curr_type=currencyType  from agentdetail where agentcode=@super_agent_id   
 set @send_fx_clm='1'  
 set @paid_fx_clm='1'  
 set @balance_fx_clm='1'  
end  
else  
begin  
 set @curr_type='USD'  
 set @send_fx_clm='ExchangeRate'  
 set @paid_fx_clm=' (case when '+ @payout_settle_usd +' is NUll then isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate) else '+ @payout_settle_usd +' end) '  
 set @balance_fx_clm=' isNUll(xRate,1) '  
end  
  
  
begin try  
set @agent_id=@agentId  
select @agentType=agenttype from agentdetail where agentcode=@agentId  
declare @mode varchar(50)  
set @super=''  
if @flag='s'  
 set @mode='mode=''cr'''  
if @flag='r'  
 set @mode='mode=''dr'''  
if @flag='p'  
begin  
 set @mode='mode in(''cr'',''dr'')'  
 set @super='_super'  
 set @agent_id=''  
 select @agent_id=agentCode +','+ @agent_id  from agentdetail where super_agent_id=@agentId  
 set @agent_id=left(@agent_id,len(@agent_id)-1)  
 set @agent_id=@agentId+','+@agent_id  
end  
----------------------------------------  
declare @round_value varchar(2)  
select @round_value=round_value from tbl_setup  
if @round_value is null  
set @round_value=4  
--------------------------------------------  
set @process_id_new=@process_id   
set @sql='spa_LedgerReport_job'+@super+' ''d'','''+ @agentId +''',Null,  
'''+ @month +'/1/'+ @year +''','''+ @month +'/1/'+ @year +''',Null,  
''y'',''a'','''+isNUll(@calc_currency,'l')+''',NULL,Null,'''+@userId+''','''+@process_id_new+''',''soa_ledger_monthly'+@super+''''  
  
exec(@sql)  
  
set @temptablename=dbo.FNAProcessTBl(@batch_Id, @userId, @process_id)  
set @sql='create table '+ @temptablename +'(   
 [sno] [int] IDENTITY(1,1) NOT NULL,  
 [Process_id] varchar(200) NULL,  
 [agentCode] varchar(50) NULL,  
 [companyName] varchar(150) NULL,  
 [country] varchar(50) NULL,  
 [currencyType] varchar(50) NULL,  
 [tot_trns] int NULL,  
 [paid_amt] money NULL,  
 [sender_comm] money NULL,  
 [cancel_trns] int NULL,  
 [cancel_amt] money NULL,  
 [cancel_comm] money NULL,  
 [opening_balance] money NULL,  
 [soa_month] varchar(50) NULL,  
 [soa_year] varchar(50) NULL,  
 [soa_date] varchar(50) NULL,  
[tot_trns_pay] int NULL,  
[paid_amt_pay] money NULL,  
[sender_comm_pay] money NULL,  
[cancel_trns_pay] int NULL,  
[cancel_amt_pay] money NULL,  
[cancel_comm_pay] money NULL   
) ON [PRIMARY]'  
exec(@sql)  
------------------------------------------------------  
  
set @sql='insert fund_settlement (agentCode,companyName,country,local_amt,ex_rate,dollar_amt,dot,Process_id)  
select a.agentCode,a.companyName,country, (case when mode=''dr'' then isnull(amount,0)* -1   
else amount end), isNull(xRate,1), (case when mode=''dr'' then isnull(dollar_rate,0)* -1   
else dollar_rate end), convert(varchar,dot,101), '''+@process_id+'''  
from agentBalance b join agentDetail a on b.agentCode=a.agentCode  
where approved_by is not Null and '+@mode+'   
and DATEPART(month,dot)='''+ @month +'''  
and DATEPART(year,dot)='''+ @year +'''  
and b.agentCode='+ @agentId +' order by dot'  
exec(@sql)  
  
------------------------------------------------------------------------------------  
------------------------------------------------------------------------------------  
  
if @flag='s'  
begin  
set @sql='  
insert '+@temptablename+' (agentCode,companyName,country,currencyType,  
tot_trns,paid_amt,sender_comm,cancel_trns,cancel_amt,cancel_comm,  
process_id,soa_month,soa_year,soa_date)  
select agentCode,companyName,country,currencyType,  
sum(case when trnStatus=''Send'' then tot_trns else 0 end) tot_trns,  
sum(case when trnStatus=''Send'' then paidAmt else 0 end) paid_amt,  
sum(case when trnStatus=''Send'' then senderCommission else 0 end) sender_comm,  
sum(case when trnStatus=''Cancel'' then tot_trns else 0 end) cancel_trns,  
sum(case when trnStatus=''Cancel'' then paidAmt else 0 end) cancel_amt,  
sum(case when trnStatus=''Cancel'' then senderCommission else 0 end) cancel_comm,  
'''+@process_id+''','''+@month+''','''+@year+''',getDate()  
from (  
select agentCode,companyName,country,currencyType,  
count(tranno) tot_trns,  
sum(round(paidAmt/'+ @send_fx_clm +','+@round_value+')) paidAmt,  
sum(round((senderCommission+isNUll(agent_ex_gain,0))/'+ @send_fx_clm +' ,'+@round_value+')) senderCommission, ''Send'' trnStatus  
from moneysend m WITH (NOLOCK) join agentDetail a on agentId=agentCode  
where senderCountry=country and transStatus in(''Payment'',''Block'',''Cancel'')  
and agentId='''+ @agentId +''' and DATEPART(month,'+ @dateType +')='''+ @month +''' and DATEPART(year,'+ @dateType +')='''+ @year +'''  group by agentCode,companyName,country,currencyType   
union all  
select agentCode,companyName,country,currencyType,  
count(tranno),sum(round(paidAmt/'+ @send_fx_clm +','+@round_value+')),  
sum(round((senderCommission+isNUll(agent_ex_gain,0))/'+ @send_fx_clm +','+@round_value+')), ''Cancel''   
from moneysend m WITH (NOLOCK) join agentDetail a on agentId=agentCode   
where transStatus=''Cancel'' and senderCountry=country  
and agentId='''+ @agentId +''' and DATEPART(month,cancel_date)='''+ @month +''' and DATEPART(year,cancel_date)='''+ @year +'''  group by agentCode,companyName,country,currencyType ) t  
group by agentCode,companyName,country,currencyType '  
end  
------------------------------------------------------------------------  
  
declare @agent_type char(1),@rComm_clm varchar(5000)  
set @agent_type=''  
if @agent_type='d'  
 set @rComm_clm=' ReceiverCommission '    
else  
set @rComm_clm='  
(case when isNull(agent_receiverComm_Currency,''l'')=''l''   
 then isNull(agent_receiverCommission,0)   
 else   
  isNull(agent_receiverCommission,0) *  (  
   case when '+ @payout_settle_usd +' is NUll   
   then isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate)   
   else payout_settle_usd end)    
 end   
 + (agent_receiverSCommission * agent_settlement_rate )   
 )'  
  
-------------------------------------------------------------  
if @flag='r'  
begin  
set @sql='  
insert '+@temptablename+' (agentCode,companyName,country,currencyType,  
tot_trns,paid_amt,sender_comm,cancel_trns,cancel_amt,cancel_comm,  
process_id,soa_month,soa_year,soa_date)  
select agentCode,companyName,country,currencyType,  
sum(case when trnStatus=''Payout'' then tot_trns else 0 end) tot_trns,  
sum(case when trnStatus=''Payout'' then paidAmt else 0 end) paid_amt,  
sum(case when trnStatus=''Payout'' then senderCommission else 0 end) sender_comm,  
sum(case when trnStatus=''Cancel'' then tot_trns else 0 end) cancel_trns,  
sum(case when trnStatus=''Cancel'' then paidAmt else 0 end) cancel_amt,  
sum(case when trnStatus=''Cancel'' then senderCommission else 0 end) cancel_comm,  
'''+@process_id+''','''+@month+''','''+@year+''',getDate()  
from (  
select  agentCode,companyName,country,currencyType,count(tranno) tot_trns,  
sum(round(totalRoundamt/'+@paid_fx_clm +','+@round_value+')) paidAmt,  
sum(round('+@rComm_clm+'/'+@paid_fx_clm +','+@round_value+')) senderCommission, ''Payout'' trnStatus  
from moneysend m WITH (NOLOCK) join agentdetail s on s.agentcode=expected_payoutagentid  
where receiverCountry=s.country   
and transStatus in(''Payment'',''Block'',''Cancel'')  
--and transStatus=''Payment'' and status=''Paid''  
and transfertype=''CashPay'' and paymenttype=''Cash Pay''  
and expected_payoutagentid='+@agentid +' and DATEPART(month,'+ @dateType +')='''+ @month +''' and DATEPART(year,'+ @dateType +')='''+ @year +'''  group by agentCode,companyName,country,currencyType   
union all  
select  agentCode,companyName,country,currencyType,  
count(tranno),sum(round(totalRoundamt/'+@paid_fx_clm +','+@round_value+')) paidAmt,  
sum(round('+@rComm_clm+'/'+@paid_fx_clm +','+@round_value+')) senderCommission, ''Cancel'' trnStatus  
from moneysend m WITH (NOLOCK) join agentdetail s on s.agentcode=expected_payoutagentid  
where transStatus=''Cancel'' and receiverCountry=s.country   
and transfertype=''CashPay'' and paymenttype=''Cash Pay''   
and expected_payoutagentid='+ @agentid +' and DATEPART(month,cancel_date)='''+ @month +''' and DATEPART(year,cancel_date)='''+ @year +'''  group by agentCode,companyName,country,currencyType   
) t group by agentCode,companyName,country,currencyType  '  
end  
------------------------------------------------------  
------------------------------------------------------  
if @flag='p'  
begin  
----set @dateType=@agent_settlement_date  
set @sql='  
insert '+@temptablename+' (agentCode,companyName,country,  
tot_trns,paid_amt,sender_comm,cancel_trns,cancel_amt,cancel_comm,  
tot_trns_pay,paid_amt_pay,sender_comm_pay,cancel_trns_pay,cancel_amt_pay,cancel_comm_pay,  
process_id,soa_month,soa_year,soa_date, currencyType )  
select agentCode,companyName,country,  
sum(case when trnStatus=''Received'' then tot_trns else 0 end) tot_trns,  
sum(case when trnStatus=''Received'' then paidAmt else 0 end) paid_amt,  
sum(case when trnStatus=''Received'' then senderCommission else 0 end) sender_comm,  
sum(case when trnStatus=''Received Cancel'' then tot_trns else 0 end) cancel_trns,  
sum(case when trnStatus=''Received Cancel'' then paidAmt else 0 end) cancel_amt,  
sum(case when trnStatus=''Received Cancel'' then senderCommission else 0 end) cancel_comm,  
  
sum(case when trnStatus=''Payout'' then tot_trns else 0 end) tot_trns_pay,  
sum(case when trnStatus=''Payout'' then paidAmt else 0 end) paid_amt_pay,  
sum(case when trnStatus=''Payout'' then senderCommission else 0 end) sender_comm_pay,  
sum(case when trnStatus=''Payout Cancel'' then tot_trns else 0 end) cancel_trns_pay,  
sum(case when trnStatus=''Payout Cancel'' then paidAmt else 0 end) cancel_amt_pay,  
sum(case when trnStatus=''Payout Cancel'' then senderCommission else 0 end) cancel_comm_pay,  
'''+@process_id+''','''+@month+''','''+@year+''',getDate(), '''+@curr_type+'''  
from (  
select s.agentCode,s.companyName,s.country,  
count(tranno) tot_trns,  
sum(round(totalRoundamt/'+@paid_fx_clm +','+@round_value+')) paidAmt,  
sum(round((scharge - isNUll(sendercommission,0))/'+@send_fx_clm+','+@round_value+')) senderCommission, ''Received'' trnStatus  
from moneysend m WITH (NOLOCK) join agentDetail a on a.agentcode=m.agentid   
join agentdetail s on s.agentcode=a.super_agent_id  
where senderCountry=a.country  
and transStatus in(''Payment'',''Block'',''Cancel'')  
and agentId in('+ @agent_id +') and DATEPART(month,'+ @dateType +')='''+ @month +''' and DATEPART(year,'+ @dateType +')='''+ @year +'''  group by s.agentCode,s.companyName,s.country  
union all  
select s.agentCode,s.companyName,s.country,  
count(tranno), sum(round(totalRoundamt/'+@paid_fx_clm +','+@round_value+')) paidAmt,  
sum(round((scharge - isNUll(sendercommission,0))/'+@send_fx_clm+','+@round_value+')), ''Received Cancel''   
from moneysend m WITH (NOLOCK) join agentDetail a on a.agentcode=m.agentid   
join agentdetail s on s.agentcode=a.super_agent_id  
where transStatus=''Cancel'' and senderCountry=a.country  
and agentId in('+ @agent_id +') and DATEPART(month,cancel_date)='''+ @month +''' and DATEPART(year,cancel_date)='''+ @year +'''  group by s.agentCode,s.companyName,s.country  
  
union all  
  
select s.agentCode,s.companyName,s.country,  
count(tranno) tot_trns,  
sum(round(totalRoundamt/'+@paid_fx_clm +','+@round_value+')),  
sum(round('+@rComm_clm+'/'+@paid_fx_clm +','+@round_value+')), ''Payout'' trnStatus  
from moneysend m WITH (NOLOCK) join agentDetail a on a.agentcode=m.agentid   
join agentdetail p on p.agentcode=expected_payoutagentid  
join agentdetail s on s.agentcode=p.super_agent_id  
where senderCountry=a.country  
and transStatus in(''Payment'',''Block'',''Cancel'')  
and expected_payoutagentid in('+ @agent_id +') and DATEPART(month,'+ @dateType +')='''+ @month +''' and DATEPART(year,'+ @dateType +')='''+ @year +'''  group by s.agentCode,s.companyName,s.country  
union all  
select s.agentCode,s.companyName,s.country,  
count(tranno),sum(round(totalRoundamt/'+@paid_fx_clm +','+@round_value+')),  
sum(round('+@rComm_clm+'/'+@paid_fx_clm +','+@round_value+')), ''Payout Cancel'' trnStatus  
from moneysend m WITH (NOLOCK) join agentDetail a on a.agentcode=m.agentid   
join agentdetail p on p.agentcode=expected_payoutagentid  
join agentdetail s on s.agentcode=p.super_agent_id  
where transStatus=''Cancel'' and senderCountry=a.country  
and expected_payoutagentid in('+ @agent_id +') and DATEPART(month,cancel_date)='''+ @month +''' and DATEPART(year,cancel_date)='''+ @year +'''  group by s.agentCode,s.companyName,s.country ) t  
group by agentCode,companyName,country '  
  
end  
print @sql  
exec(@sql)  
  
declare @soa_table_name varchar(500), @url_desc as varchar(100)  
declare @lblDate varchar(50)   
set @lblDate=DATENAME(month,''+@month+'/1/'+@year+'')+' '+DATENAME(year,''+@month+'/1/'+@year+'')  
SET @soa_table_name='iremit_process.dbo.soa_ledger_monthly'+@super+'_'+@userId+'_'+@process_id_new  
  
set @sql='update '+ @temptablename +'  
set opening_balance=(select balance from '+@soa_table_name +'   
where tranNo is Null and remarks=''Opening Balance'')  
where process_id='''+@process_id+''' '  
exec(@sql)  
  
if @super=''   
set @super='sender'  
  
SET @desc =upper(@batch_id)+' is completed Month of '+@lblDate  
SET @url_desc=replace(@super,'_','')+'Agent='+@agentId+'&cmbMonth='+@month+'&cmbYear='+@year+'&curr='+isNUll(@calc_currency,'l')+'&rDate='+@dateType  
set @desc = @desc +'<BR><b>('+@agentName+')</b> Currency in <b>'+case when @calc_currency='d' then 'USD' else 'Local' end+'</b>'  
  
EXEC  spa_message_board 'u', @userId,NULL,   
'MonthlySOA',@desc, 'c', @process_id,null,@url_desc  
  
end try  
  
  
begin catch  
if @@trancount>0   
 rollback transaction  
  
   
 set @desc='SQL Error found:  (' + ERROR_MESSAGE() + ')'  
 declare @err_msg varchar(1000)  
set @err_msg='<font color=blue>'+@desc +'</font>'  
 EXEC  spa_message_board 'u', @userId,  
    NULL, 'MonthlySOA',  
    @err_msg, 'c', @process_id,null,null  
 INSERT INTO [error_info]  
           ([ErrorNumber]  
           ,[ErrorDesc]  
           ,[Script]  
           ,[ErrorScript]  
           ,[QueryString]  
           ,[ErrorCategory]  
           ,[ErrorSource]  
           ,[IP]  
           ,[error_date])  
 select -1,@desc,'MonthlySOA','SQL',@desc,'SQL','SP','127.0.0.1',getdate()  
  
 select 'ERROR','1012','Error Please try again'  
  
end catch  