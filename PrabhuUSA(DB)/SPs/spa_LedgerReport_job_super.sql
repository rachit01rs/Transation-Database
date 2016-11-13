--drop proc [dbo].[spa_LedgerReport_job_super]        
--go   
--create proc [dbo].[spa_LedgerReport_job_super]        
--@flag char(1),        
--@super_agent_id varchar(50),        
--@branch_id varchar(50),        
--@from_date varchar(20),        
--@to_date varchar(20),        
--@settlement_agent_id varchar(50)=null,        
--@calc_opening_balance char(1)=null,        
--@agent_type char(1)=null, -- NULL/a MAIN AGENT TYPE , b= Branch Type , d Bank or Deposit type        
--@calc_currency char(1)=null, -- l = Local CUrrency , d - USD        
--@usd_rate money=null,        
--@calc_commission char(1)=null,        
--@login_user_id varchar(50),        
--@process_id varchar(200),        
--@batch_id varchar(100)=NULL,      
--@country varchar(50)=NULL,      
--@sendAgent varchar(50)=NULL        
--as     

declare 
@flag char(1),        
@super_agent_id varchar(50),        
@branch_id varchar(50),        
@from_date varchar(20),        
@to_date varchar(20),        
@settlement_agent_id varchar(50),        
@calc_opening_balance char(1),        
@agent_type char(1), -- NULL/a MAIN AGENT TYPE , b= Branch Type , d Bank or Deposit type        
@calc_currency char(1), -- l = Local CUrrency , d - USD        
@usd_rate money,        
@calc_commission char(1),        
@login_user_id varchar(50),        
@process_id varchar(200),        
@batch_id varchar(100),      
@country varchar(50),  @sendAgent varchar(50)
set @flag='d'
set @super_agent_id='20100219'
set @from_date='8/3/2014'
set @to_date='8/3/2014'
set @calc_opening_balance='y'
set @agent_type='a'
set @calc_commission='n'
set @login_user_id='saKapil'
set @process_id='123331'
set @batch_id='soa_ledger_super'
set @country='United Arab Emirates'
set @sendAgent='20100111'
drop table #temp
drop table iremit_process.dbo.soa_ledger_super_saKapil_123331
--EXEC PrabhuUsa.dbo.spa_LedgerReport_job_super  'd','20100219', Null ,    
-- '8/3/2014','8/3/2014', Null ,'y','a', Null ,1.00,'n',      
-- 'sa_KAPIL','23333','soa_ledger_super','United Arab Emirates','20100111'  
-- 
 print @country        
 print @sendAgent       
if @batch_id is null        
 set @batch_id='soa_ledger_super'        
declare @ledger_tabl varchar(150)        
        
declare @round_value varchar(2)        
        
declare @sql varchar(max),@rComm_clm varchar(1000), @expected_payoutagentid varchar(50),@curr_type varchar(20),        
@headoffice_commission_id varchar(50),@agent_name varchar(500),@branch_name varchar(500)        
select @headoffice_commission_id=headoffice_commission_id,@round_value=round_value from tbl_setup        
        
if @round_value is null        
set @round_value=4        
        
declare @agent_id varchar(1000)        
set @agent_id=''        
select @agent_id=agentCode +','+ @agent_id  from agentdetail where super_agent_id=@super_agent_id        
set @agent_id=left(@agent_id,len(@agent_id)-1)        
set @agent_id=@super_agent_id+','+@agent_id        
        
declare @agent_settlement_date varchar(50),@payout_settle_usd varchar(50)        
if @super_agent_id is not null        
 select @calc_commission=cal_commission_daily,@calc_currency=isNUll(settlement_type,'d'),        
 @agent_settlement_date=isNULL(agent_settlement_date,'ConfirmDate')        
 from agentdetail where agentcode=@super_agent_id         
if @agent_settlement_date='ConfirmDate'        
 set @payout_settle_usd='payout_settle_usd'        
else        
 set @payout_settle_usd='paid_date_usd_rate'        
        
set @calc_currency='d'        
if @calc_commission='y'        
 set @calc_commission=NULL        
        
declare @send_fx_clm varchar(50),@paid_fx_clm varchar(500),@balance_fx_clm varchar(50),@comm_fx_clm varchar(500)        
        
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
 set @comm_fx_clm='(case when PaidCtype=''USD'' then ''1'' else agent_settlement_rate/'+@paid_fx_clm+' end)'        
         
set @balance_fx_clm=' isNUll(xRate,1) '        
end        
        
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
 + (agent_receiverSCommission * (case when PaidCtype=''USD'' then '+@paid_fx_clm+' else agent_settlement_rate end) )         
 )'        
        
        
if @calc_commission is not null        
 set @rComm_clm='0'        
        
        
if @usd_rate is null        
 set @usd_rate=1        
        
CREATE TABLE [#temp] (        
 [sno] int identity(1,1) ,        
 [DOT] [datetime] NULL ,        
 [TranNo] varchar(50) NULL ,        
 [Type] varchar(20) NULL,        
 [Remarks] [varchar] (6000)  NULL ,        
 [DR] [money] NULL ,        
 [CR] [money] NULL ,        
 [Comm] [money] NULL ,        
 [Settlement_Amount] [money] NULL ,        
 No_TRN int NUll        
) ON [PRIMARY]        
        
set @ledger_tabl=dbo.FNAProcessTbl(@batch_id,@login_user_id,@process_id)        
        
set @sql='        
CREATE TABLE '+ @ledger_tabl+'(        
 [sno] int identity(1,1) ,        
 [DOT] [datetime] NULL ,        
 [TranNo] varchar(50) NULL ,        
 [Type] varchar(20) NULL,        
 [Remarks] [varchar] (6000)  NULL ,        
 [DR] [money] NULL ,        
 [CR] [money] NULL ,        
 [Comm] [money] NULL ,        
 [Settlement_Amount] [money] NULL ,        
 Balance money,        
 Currency varchar(50),        
 NO_TRN int NUll        
) ON [PRIMARY]'        
exec (@sql)        
        
        
select @agent_name=companyName from agentdetail where agentcode=@super_agent_id    
IF @sendAgent IS NOT NULL      
SELECT @agent_name=@agent_name +'['+companyName+']' FROM agentDetail ad WHERE ad.agentCode=@sendAgent  
  
  
DECLARE @map_id varchar(1000)        
        
if @settlement_agent_id IS NOT NULL        
begin        
        
SET @map_id=''        
SELECT @map_id=@map_id + ''''+ ledger_id  +''',' FROM         
agent_mapping_ledger         
WHERE main_agent_id=@settlement_agent_id AND agent_code=@super_agent_id         
IF len(@map_id) > 8        
 SET @map_id=left(@map_id,len(@map_id)-1)        
ELSE        
 SET @map_id='-9'        
end        
        
        
if @calc_opening_balance='y'         
begin        
 --GET OPENING BALANCE        
 set @sql='        
 insert #temp(dot,remarks,DR,cr,comm,Settlement_Amount)        
 select  dateadd(d,-1,'''+@from_date+'''),''Opening Balance'',0,0,0, isNULL(sum(Settlement_Amount),0) open_balance from(        
        
 SELECT sum('+             
  case when @calc_currency='d' then ' dollar_amt '            
   else ' paidAmt ' end +'- round((senderCommission+isNUll(agent_ex_gain,0))/'+@send_fx_clm +','+ @round_value +',1))      
 Settlement_Amount        
 FROM MoneySend m with (nolock) join agentdetail sa on sa.agentcode=m.agentid          
 where transStatus in(''Payment'',''Cancel'',''Block'')        
 and '+@agent_settlement_date +' < '''+ @from_date +''''        
 set @sql=@sql+' and agentid in('+ @agent_id +')'       
 IF @country IS NOT NULL       
 set @sql=@sql+' and senderCountry='''+@country+''''         
 IF @sendAgent IS NOT NULL       
 set @sql=@sql+' and agentid='''+ @sendAgent +''''        
     
 set @sql=@sql+' union all        
 SELECT sum(round(totalRoundamt/'+@paid_fx_clm +','+@round_value+'))*-1'        
 if @calc_commission is null         
  set @sql=@sql+' -isNULL(sum(round('+@rComm_clm+'/'+@paid_fx_clm +','+@round_value+')),0)'        
 set @sql=@sql+' Settlement_Amount        
 FROM MoneySend m with (nolock) join agentdetail sa on sa.agentcode=m.agentid          
 where transStatus in(''Payment'',''Cancel'',''Block'')        
 and '+@agent_settlement_date +' < '''+ @from_date +''''        
 set @sql=@sql+' and expected_payoutagentid in('+ @agent_id +')'       
  IF @country IS NOT NULL       
 set @sql=@sql+' and receiverCountry='''+@country+''''         
 IF @sendAgent IS NOT NULL       
 set @sql=@sql+' and expected_payoutagentid='''+ @sendAgent +''''          
--Receiver Fund        
set @sql=@sql+' union all         
 SELECT isNULL(sum(case when mode=''dr'' then '+         
 case when @calc_currency='d' then ' dollar_rate '        
  else ' amount ' end +' '        
 if @calc_commission is null         
  set @sql=@sql+' + round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+')'        
 set @sql=@sql+' else ('+         
 case when @calc_currency='d' then ' dollar_rate '        
  else ' amount ' end +' '        
   set @sql=@sql+') * -1 end),0) Settlement_Amount        
 FROM  AgentBalance b join agentdetail a        
 on a.agentcode=b.agentcode where mode in (''dr'',''cr'') and approved_by is not null        
 and dot < '''+ @from_date  +''' and b.agentcode in('+ @agent_id +')'    
 IF @country IS NOT NULL       
 set @sql=@sql+' and a.Country='''+@country+''''         
 IF @sendAgent IS NOT NULL       
 set @sql=@sql+' and b.agentcode='''+ @sendAgent +''''          
set @sql=@sql+' group by b.agentcode '        
-- CANCEL Voucher Only PAYOUT AGENT        
if @agent_settlement_date='confirmDate'        
begin        
set @sql=@sql+' union all        
 SELECT sum(round(totalRoundamt/'+@paid_fx_clm +','+@round_value+'))'        
 if @calc_commission is null         
  set @sql=@sql+'  +isNULL(sum(round('+@rComm_clm+'/'+@paid_fx_clm +','+@round_value+')),0)'      
 set @sql=@sql+' Settlement_Amount        
 FROM   MoneySend  m  where transStatus=''Cancel''        
 and cancel_date < '''+ @from_date +''''        
 set @sql=@sql+' and expected_payoutagentid in('+ @agent_id +')'        
IF @country IS NOT NULL       
 set @sql=@sql+' and receiverCountry='''+@country+''''         
 IF @sendAgent IS NOT NULL       
 set @sql=@sql+' and expected_payoutagentid='''+ @sendAgent +''''            
-- CANCEL Voucher Only SEND AGENT        
set @sql=@sql+' union all        
SELECT sum('+             
  case when @calc_currency='d' then ' dollar_rate '            
   else ' amount ' end +'  - round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)) * -1 Settlement_Amount            
  FROM  AgentBalance b with (nolock) left outer join moneysend m    with (nolock)         
  on b.tranno=m.tranno             
  where transStatus=''Cancel''        
 and cancel_date < '''+ @from_date +''''        
 set @sql=@sql+' and agentid in('+ @agent_id +')'      
 IF @country IS NOT NULL       
 set @sql=@sql+' and senderCountry='''+@country+''''         
 IF @sendAgent IS NOT NULL       
 set @sql=@sql+' and agentid='''+ @sendAgent +''''          
end        
 set @sql=@sql+')l'        
 print @sql        
 exec(@sql)        
 --END OPENING BALACNE        
end        
        
declare @send_trn_remarks varchar(500)        
set @send_trn_remarks='senderName +'',''+receiverCountry'        
        
if @flag='d'  -- DETAIL  REPORT        
begin        
 set @sql='        
 insert into #temp(Type,TranNo,DOT,Remarks,Dr,Cr,Comm,Settlement_Amount,No_TRN)        
     
  SELECT ''Paid'', cast(TranNo as varchar),PaidDate,receiverName +'',''+senderCountry ''Remarks'',0 ''DR'',             
  round(totalRoundAmt/'+@paid_fx_clm+','+@round_value+',1) ''CR'',round(isNUll('+@rComm_clm+',0)/'+@paid_fx_clm+','+@round_value+',1) as Comm,            
  round((totalRoundAmt/'+@paid_fx_clm            
  if @calc_commission is null             
   set @sql=@sql+' +isNUll('+@rComm_clm+',0)/'+@paid_fx_clm+''            
  set @sql=@sql+' )*-1,'+@round_value+',1) Settlement_Amount,        
 1 No_TRN        
 FROM MoneySend m WITH (NOLOCK) join agentdetail sa on sa.agentcode=m.agentid where transStatus in(''Payment'',''Cancel'',''Block'')        
 and '+@agent_settlement_date +' between '''+ @from_date +''' and '''+@to_date+' 23:59:59'''        
 set @sql=@sql+' and expected_payoutagentid in('+ @agent_id +')'        
 set @sql=@sql+' union all        
 SELECT ''Send'' Type, cast(TranNo as varchar) Tranno,'+@agent_settlement_date +' as DOT,cast(Tranno as varchar)+'':''+ senderName +'',''+receiverCountry ''Remarks'',            
   '+             
  case when @calc_currency='d' then ' dollar_amt '            
   else ' paidAmt ' end +' ''DR'',0 ''CR'',round((isNUll(senderCommission,0)+isNUll(agent_ex_gain,0))/'+@send_fx_clm +','+@round_value+',1) as Comm,            
  '+            
  case when @calc_currency='d' then ' dollar_amt '            
   else ' paidAmt ' end +'-round(((isNUll(senderCommission,0)+isNUll(agent_ex_gain,0))/'+@send_fx_clm +'),'+@round_value+',1) Settlement_Amount,  
 1 No_TRN        
 FROM MoneySend m WITH (NOLOCK) join agentdetail sa on sa.agentcode=m.agentid where transStatus in(''Payment'',''Cancel'',''Block'')        
 and '+@agent_settlement_date +' between '''+ @from_date +''' and '''+@to_date+' 23:59:59'''        
 set @sql=@sql+' and agentid in('+ @agent_id +')'       
  IF @country IS NOT NULL       
 set @sql=@sql+' and senderCountry='''+@country+''''         
 IF @sendAgent IS NOT NULL       
 set @sql=@sql+' and agentid='''+ @sendAgent +''''          
end        
--------------------------------------------------------------------------------------        
else if @flag='s' ----------------- ################# Summary ###########-------------        
begin        
 set @sql='        
 insert into #temp(Type,TranNo,DOT,Remarks,Dr,Cr,Comm,Settlement_Amount,No_trn)        
 select * from(        
 SELECT ''Paid'' Type, NULL Tranno,convert(varchar,PaidDate,102) DOT,''Total TRN ''+ cast(count(*) as varchar) Remarks,0 DR,            
  sum(round(totalRoundAmt/'+@paid_fx_clm +','+@round_value+',1)) CR,            
  sum(round(isNUll('+@rComm_clm+'/'+@paid_fx_clm +',0),'+@round_value+',1)) as Comm,            
  sum(round(((totalRoundAmt '            
 if @calc_commission is null             
  set @sql=@sql+'  +isNUll('+@rComm_clm+',0) '            
             
   set @sql=@sql+' )*-1)/'+@paid_fx_clm +','+@round_value+',1)) Settlement_Amount,        
 count(*) No_TRN        
 FROM   MoneySend  m with (nolock) join agentdetail sa on sa.agentcode=m.agentid           
 where transStatus in(''Payment'',''Cancel'',''Block'')        
 and PaidDate between '''+ @from_date +''' and '''+@to_date+' 23:59:59'''        
 set @sql=@sql+' and expected_payoutagentid in('+ @agent_id +')'       
  IF @country IS NOT NULL       
 set @sql=@sql+' and receiverCountry='''+@country+''''         
 IF @sendAgent IS NOT NULL       
 set @sql=@sql+' and expected_payoutagentid='''+ @sendAgent +''''          
       
 set @sql=@sql+'  group by convert(varchar,PaidDate,102)'        
print 'xxxxxxxxxxxxx'        
--print @sql        
        
set @sql=@sql+' union all     
 SELECT ''Send'' Type, NULL Tranno,convert(varchar,confirmDate,102) as DOT,''Total TRN ''+ cast(count(*) as varchar) Remarks,            
   sum('+             
  case when @calc_currency='d' then ' dollar_amt '            
   else ' paidAmt ' end +') DR,0 CR,            
  sum(round(isNUll(senderCommission/'+@send_fx_clm +',0)+isNUll(agent_ex_gain/'+@send_fx_clm +',0),'+@round_value+',1)) as Comm,            
  sum('+             
  case when @calc_currency='d' then ' dollar_amt '            
   else ' paidAmt ' end +'-round(((isNUll(senderCommission,0)+isNUll(agent_ex_gain,0))/'+@send_fx_clm +'),'+@round_value+',1)) Settlement_Amount,  
 count(*) No_TRN        
 FROM   MoneySend  m  with (nolock)  join agentdetail sa on sa.agentcode=m.agentid           
 where transStatus in(''Payment'',''Cancel'',''Block'')        
 and '+@agent_settlement_date +' between '''+ @from_date +''' and '''+@to_date+' 23:59:59'''        
 set @sql=@sql+' and agentid in ('+ @agent_id +')'      
 IF @country IS NOT NULL       
 set @sql=@sql+' and senderCountry='''+@country+''''         
 IF @sendAgent IS NOT NULL       
 set @sql=@sql+' and agentid='''+ @sendAgent +''''          
 set @sql=@sql+'        
 group by convert(varchar,'+@agent_settlement_date +',102)'        
end   
exec(@sql)
set @sql='insert into #temp(Type,TranNo,DOT,Remarks,Dr,Cr,Comm,Settlement_Amount,No_TRN) '
----------------------------------------------------------------------        
if @agent_settlement_date='confirmDate'        
begin        
---- CANCEL TXN        
set @sql=@sql+'        
 SELECT ''Payout Cancel'' Type,  cast(Tranno as varchar)  TranNo,convert(varchar,cancel_date,102) Dot,''TXN:''+ dbo.decryptDB(refno) Remarks,        
 round(totalRoundamt/'+@paid_fx_clm +','+@round_value+') DR,0 CR,        
 isNULL(round('+@rComm_clm+'/'+@paid_fx_clm +','+@round_value+'),0) * -1 as Comm,        
 round(totalRoundamt/'+@paid_fx_clm +','+@round_value+')'        
 if @calc_commission is null         
  set @sql=@sql+'  +isNULL(round('+@rComm_clm+'/'+@paid_fx_clm +','+@round_value+'),0)'        
 set @sql=@sql+' Settlement_Amount,        
 -1 No_TRN        
 FROM   MoneySend  m  with (nolock)        
 where transStatus=''Cancel''        
 and cancel_date between '''+ @from_date +''' and '''+@to_date+' 23:59:59'''        
 set @sql=@sql+' and expected_payoutagentid in('+ @agent_id +')'       
  IF @country IS NOT NULL       
 set @sql=@sql+' and receiverCountry='''+@country+''''         
 IF @sendAgent IS NOT NULL       
 set @sql=@sql+' and expected_payoutagentid='''+ @sendAgent +''''         
 set @sql=@sql+' union all        
 SELECT ''Cancel'',convert(varchar(50),b.InvoiceNo),convert(varchar,b.DOT,102) DOT,            
 ''Cancel TRN '' + isNULL(b.remarks,'''') as remarks,            
  case when mode=''dr'' then '+             
  case when @calc_currency='d' then ' dollar_rate '            
   else ' amount ' end +' else 0 end DR,            
  case when mode in(''Cr'',''Cancel'') then '+             
  case when @calc_currency='d' then ' dollar_rate '            
   else ' amount ' end +' else 0 end CR,            
  case when mode=''cancel'' then round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) * -1             
  else  round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)  end as comm,            
  (case when mode=''dr'' then ('+             
  case when @calc_currency='d' then ' dollar_rate '            
   else ' amount ' end +')              
   else ('+             
  case when @calc_currency='d' then ' dollar_rate '            
   else ' amount ' end +'-round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1))  * -1 end ) Settlement_Amount,  
 -1 No_TRN               
  FROM  AgentBalance b with (nolock)  left outer join moneysend m            
  on b.tranno=m.tranno             
  where transStatus=''Cancel''        
 and cancel_date between '''+ @from_date +''' and '''+@to_date+' 23:59:59'''        
 set @sql=@sql+' and agentid in('+ @agent_id +')'       
   IF @country IS NOT NULL       
 set @sql=@sql+' and senderCountry='''+@country+''''         
 IF @sendAgent IS NOT NULL       
 set @sql=@sql+' and agentid='''+ @sendAgent +''''          
end      
exec(@sql)
set @sql='insert into #temp(Type,TranNo,DOT,Remarks,Dr,Cr,Comm,Settlement_Amount,No_TRN) '  
--FUND Receiving          
set @sql=@sql+'         
 SELECT  ''Fund''  , convert(varchar(50),b.InvoiceNo), b.DOT,          
 isNull(mt.moneytransfer,'''') +         
   CASE WHEN no_of_trn IS NOT NULL THEN '' TXN:''+ cast(no_of_trn AS varchar)        
    ELSE ''''        
 end  + isNUll(b.remarks,'''')        
 as remarks,        
 case when b.mode=''dr'' then '+         
 case when @calc_currency='d' then ' dollar_rate '        
  else ' amount ' end +' else 0 end DR,        
 case when b.mode =''Cr'' then '+         
 case when @calc_currency='d' then ' dollar_rate '        
  else ' amount ' end +' else 0 end CR,        
 0 as comm,        
 (case when b.mode=''dr'' then '+         
 case when @calc_currency='d' then ' dollar_rate '        
  else ' amount ' end +''        
 set @sql=@sql+' else ('+         
 case when @calc_currency='d' then ' dollar_rate '        
  else ' amount ' end +' '           
 set @sql=@sql+' ) * -1 end) Settlement_Amount,        
 isNUll(No_of_TRn,0) No_TRN        
 FROM  AgentBalance b         
 LEFT OUTER JOIN money_transfer mt        
 ON mt.money_id = b.money_id  JOIN agentdetail a        
 ON a.agentcode = b.agentcode        
 where mode in (''dr'',''cr'') and b.approved_by is not null        
 and  b.dot between '''+ @from_date +''' and '''+ @to_date +' 23:59:59''        
 and b.agentcode in('+ @agent_id +')'       
  IF @country IS NOT NULL       
 set @sql=@sql+' and a.country='''+@country+''''         
 IF @sendAgent IS NOT NULL       
 set @sql=@sql+' and  b.agentcode='''+ @sendAgent +''''         
 --set @sql=@sql+') t order by t.dot'        
        
 print(@sql)        
 exec(@sql)        
        
set @sql='insert into '+ @ledger_tabl +'(Type,TranNo,DOT,Remarks,Dr,Cr,Comm,Settlement_Amount,Balance,Currency,No_TRN)        
select Type,TranNo,DOT,Remarks, Dr ,Cr   ,Comm ,        
Settlement_Amount  as Settlement_Amount,(select sum(Settlement_Amount) from #temp        
where sno<= t.sno) Balance,'''+ @curr_type +''' Currency,No_TRN from #temp t'        
print @sql        
exec(@sql)        
        
if @process_id is not null        
begin        
declare @msg_agenttype varchar(200),@url_desc varchar(1000),@desc varchar(3000)        
if @agent_type='a'         
 set @msg_agenttype='(Main Agent) '        
else if @agent_type='b'         
 set @msg_agenttype='(Branch Wise) '        
else if @agent_type='d'         
 set @msg_agenttype='(Bank/District Wise)'        
else        
 set @msg_agenttype=''         
set @msg_agenttype=@msg_agenttype +' '+ @agent_name        
if @branch_name is not null        
 set @msg_agenttype=@msg_agenttype +' ('+ @branch_name+')'        
set @msg_agenttype=@msg_agenttype +' from :'+@from_date +' and to:'+@to_date        
set @url_desc='fromDate='+@from_date+'&toDate='+@to_date+'&agent_type='+isNull(@agent_type,'')        
+'&agent_detail_text='+ isNull(@agent_name,'')        
if @calc_currency is not null        
 set @url_desc=@url_desc+'&currType='+ @calc_currency        
if @branch_name is not null        
 set @url_desc=@url_desc +'&branch_detail_text=('+ [dbo].FNATrimAND(@branch_name)+')'        
set @url_desc=@url_desc +'&agentcode='+@super_agent_id+'&agent_branch_id='+isNull(@branch_id,'')        
set @url_desc=@url_desc +'&receive_agent_id='+isNull(@settlement_agent_id,'')        
set @url_desc=@url_desc +'&ReportType='+isNull(@flag,'')        
set @url_desc=@url_desc +'&sendCountry='+isNull(@country,'')     
set @url_desc=@url_desc +'&sendAgent='+isNull(@sendAgent,'')         
 print (@url_desc)        
print @msg_agenttype  
 set @desc ='SOA '+ @msg_agenttype +' is completed'             
 EXEC  spa_message_board 'u', @login_user_id,        
    NULL, @batch_id,        
    @desc, 'c', @process_id,null,@url_desc        
 end