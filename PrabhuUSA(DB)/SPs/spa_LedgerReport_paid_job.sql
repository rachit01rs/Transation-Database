DROP PROC spa_LedgerReport_paid_job 
GO  
CREATE proc [dbo].[spa_LedgerReport_paid_job]  
@flag char(1),  
@agent_id varchar(50),  
@branch_id varchar(50),  
@from_date varchar(20),  
@to_date varchar(20),  
@settlement_agent_id varchar(50)=null,  
@calc_opening_balance char(1)=null,  
@agent_type char(1)=null, -- NULL/a MAIN AGENT TYPE , b= Branch Type , d Bank or Deposit type  
@calc_currency char(1)=null, -- l = Local CUrrency , d - USD  
@usd_rate money=null,  
@calc_commission char(1)=null,  
@login_user_id varchar(50),  
@process_id varchar(200),  
@batch_id varchar(100)=NULL  
as  
--  
------------TEST Script  
--declare @flag char(1),@agent_id varchar(50),@branch_id varchar(50),@from_date varchar(20),  
--@to_date varchar(20),@settlement_agent_id varchar(50),@calc_opening_balance char(1),  
--@agent_type char(1), @calc_currency char(1),@usd_rate money,@calc_commission char(1),  
--@login_user_id varchar(50),@process_id varchar(200),@batch_id varchar(100)  
--set @flag='d'  
--set @agent_id='20100013'  
----set @settlement_agent_id='84600001'  
--set @from_date='2010-07-1'  
--set @to_date='2010-07-24'  
--set @calc_opening_balance='y'  
--set @agent_type='a'  
--set @login_user_id='Anoop'  
--set @process_id='222'  
--set @calc_currency='d'  
--set @batch_id='soa_ledger_paid'  
--exec('drop table iremit_process.dbo.'+@batch_id+'_Anoop_222')  
--drop table #temp  
-----TEST End  
if @batch_id is null  
 set @batch_id='soa_ledger_paid'  
declare @ledger_tabl varchar(150)  
  
declare @round_value varchar(2)  
  
declare @sql varchar(max),@rComm_clm varchar(1000), @expected_payoutagentid varchar(50),@curr_type varchar(20),  
@headoffice_commission_id varchar(50),@agent_name varchar(500),@branch_name varchar(500)  
select @headoffice_commission_id=headoffice_commission_id,@round_value=round_value from tbl_setup  
  
if @round_value is null  
set @round_value=4  
  
if @agent_id is not null  
 select @calc_commission=cal_commission_daily    
 from agentdetail where agentcode=@agent_id  
  
--set @calc_currency='d'  
if @calc_commission='y'  
 set @calc_commission=NULL  
  
declare @send_fx_clm varchar(50),@paid_fx_clm varchar(500),@balance_fx_clm varchar(50)  
  
--if @agent_type is NULL or @agent_type ='a'  
if @calc_currency='l' or @calc_currency is null  
begin  
 select @curr_type=currencyType  from agentdetail where agentcode=@agent_id  
 set @send_fx_clm='1'  
 set @paid_fx_clm='1'  
 set @balance_fx_clm='1'  
end  
else  
begin  
 set @curr_type='USD'  
 set @send_fx_clm='ExchangeRate'  
 set @paid_fx_clm=' (case when payout_settle_usd is NUll then isNull(ho_dollar_rate, exchangeRate * agent_settlement_rate)   
else payout_settle_usd end) '  
 set @balance_fx_clm=' isNUll(xRate,1) '  
end  
  
if @agent_type='d'  
  set @rComm_clm=' ReceiverCommission '    
 else  
----------------------------------------------  
begin  
--  set @rComm_clm=' (case when isNull(agent_receiverComm_Currency,''l'')=''l''   
--then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0) * '+@paid_fx_clm +' end   
--+ agent_receiverSCommission * payout_settle_usd) '  
---------------------------  
-------------------------------------------  
declare @payoutExSett_Rate varchar(500)  
--,@sql varchar(8000)  
declare @agent_settlement_date varchar(50),@payout_settle_usd varchar(50)  
--,@rComm_clm varchar(500)  
declare @totalroundamt varchar(50)  
select @agent_settlement_date=isNUll(agent_settlement_date,'confirmDate'),  
@totalroundamt=isNull(ext_settlement_clm,'totalroundamt') from agentdetail where agentcode=@agent_id  
  
if @agent_settlement_date='ConfirmDate'  
 set @payout_settle_usd='payout_settle_usd'  
else  
 set @payout_settle_usd='paid_date_usd_rate'  
  
set @payoutExSett_Rate=' isNull('+@payout_settle_usd+',isNull(ho_dollar_rate,exchangeRate *  agent_settlement_rate)) '  
  
if @calc_currency='l'  
 set @paid_fx_clm='1'  
else  
 set @paid_fx_clm=@payoutExSett_Rate  
 --set @paid_fx_clm=isNull(@payout_settle_usd,1)  
  
  
set @rComm_clm='(case when isNull(agent_receiverComm_Currency,''l'')=''l''   
 then isNull(agent_receiverCommission,0)   
 else   
  isNull(agent_receiverCommission,0) *  (  
   case when '+ @payout_settle_usd +' is NUll   
   then isNull(ho_dollar_rate,exchangeRate * agent_settlement_rate)   
   else '+@payout_settle_usd+' end)    
 end   
 + (isNull(agent_receiverSCommission,0) * agent_settlement_rate )   
 )'  
end  
--------------------------------------------  
--------------------  
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
  
select @agent_name=companyName from agentdetail where agentcode=@agent_id  
IF @branch_id IS NOT NULL
SELECT @branch_name=Branch FROM dbo.agentbranchdetail WHERE agent_branch_Code=@branch_id
ELSE
SET @branch_name='ALL' 

DECLARE @map_id varchar(1000)  
  
if @settlement_agent_id IS NOT NULL  
begin  
  
SET @map_id=''  
SELECT @map_id=@map_id + ''''+ ledger_id  +''',' FROM   
agent_mapping_ledger   
WHERE main_agent_id=@settlement_agent_id AND agent_code=@agent_id  
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
 select  dateadd(d,-1,'''+@from_date+'''),''Opening Balance'',0,0,0, sum(Settlement_Amount) open_balance from(  
 SELECT   isNULL(sum(round((('+@totalroundamt +' '  
 if @calc_commission is null   
  set @sql=@sql+' + isNUll('+@rComm_clm+',0)'  
 set @sql=@sql+') * -1)/'+@paid_fx_clm +','+@round_value+',1)),0) Settlement_Amount  
 FROM MoneySend m join agentdetail sa on sa.agentcode=m.agentid    
 where transStatus in(''Payment'',''Cancel'',''Block'')  
 and confirmDate < '''+ @from_date +''''  
 set @sql=@sql+' and expected_payoutagentid='''+ @agent_id +''''  
  
 if @settlement_agent_id is not null  
  set @sql=@sql+' and agentid='''+@settlement_agent_id +''''  
  
--Receiver Fund  
set @sql=@sql+' union all   
 SELECT sum(case when mode=''dr'' then '+   
 case when @calc_currency='d' then ' dollar_rate '  
  else ' amount ' end +' '  
 if @calc_commission is null   
  set @sql=@sql+' + round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)'  
 set @sql=@sql+' else ('+   
 case when @calc_currency='d' then ' dollar_rate '  
  else ' amount ' end +' '  
   set @sql=@sql+') * -1 end) Settlement_Amount  
 FROM  AgentBalance b join agentdetail a  
 on a.agentcode=b.agentcode where mode in (''dr'',''cr'') and approved_by is not null  
 and dot < '''+ @from_date  +''' and b.agentcode='+ @agent_id   
set @sql=@sql+' group by b.agentcode  
 Union All   
-- CANCEL Voucher Only  
 SELECT isNULL(sum(round((('+@totalroundamt +' '  
 if @calc_commission is null   
  set @sql=@sql+' + isNUll('+@rComm_clm+',0)'  
 set @sql=@sql+'))/'+@paid_fx_clm +','+@round_value+',1)),0) Settlement_Amount  
 FROM  AgentBalance b left outer join moneysend m  
 on b.tranno=m.tranno   
 where b.mode=''cancel'' and b.approved_by is not null  
 and b.dot < '''+ @from_date  +''' and m.expected_payoutagentid='+ @agent_id   
  
-----------------############ Arch1 start  
  
-----------------############ Arch1 End  
  
 set @sql=@sql+')l'  
 print @sql  
 exec(@sql)  
  
 --END OPENING BALACNE  
end  
--select * from #temp  
  
--return  
declare @send_trn_remarks varchar(500)  
set @send_trn_remarks='senderName +'',''+receiverCountry'  
  
if @flag='d'  -- DETAIL  REPORT  
begin  
 set @sql='  
 insert into #temp(Type,TranNo,DOT,Remarks,Dr,Cr,Comm,Settlement_Amount,No_TRN)  
 select * from(  
 SELECT ''TRN Received'' Type, cast(TranNo as varchar) TranNo,confirmDate DOT,cast(Tranno as varchar)+'',''+ ReceiverName ''Remarks'',0 ''DR'',   
 round('+@totalroundamt +'/'+@paid_fx_clm +','+@round_value+',1) ''CR'',  
 round(isNUll('+@rComm_clm+',0)/'+@paid_fx_clm +','+@round_value+',1) as Comm,  
 round(('+@totalroundamt +'/'+@paid_fx_clm +''  
 if @calc_commission is null   
  set @sql=@sql+' +isNUll('+@rComm_clm+',0)/'+@paid_fx_clm +''  
 set @sql=@sql+' )*-1,'+@round_value+',1) Settlement_Amount,  
 1 No_TRN  
 FROM MoneySend m join agentdetail sa on sa.agentcode=m.agentid where transStatus in(''Payment'',''Cancel'',''Block'')  
 and confirmDate between '''+ @from_date +''' and '''+@to_date+' 23:59:59'''  
 set @sql=@sql+' and expected_payoutagentid='''+ @agent_id +''''  
end  
else if @flag='s' ----------------- ################# Summary ###########-------------  
begin  
 set @sql='  
 insert into #temp(Type,TranNo,DOT,Remarks,Dr,Cr,Comm,Settlement_Amount,No_trn)  
 select * from(  
   
 SELECT ''TRN Received'' Type, NULL TranNo,convert(varchar,confirmDate,102) Dot,''Total TRN ''+ cast(count(*) as varchar) Remarks,0 DR,  
 sum(round('+@totalroundamt +'/'+@paid_fx_clm +','+@round_value+',1)) CR,  
 sum(round(isNUll('+@rComm_clm+'/'+@paid_fx_clm +',0),'+@round_value+',1)) as Comm,  
 sum(round((('+@totalroundamt +' '  
-- if @calc_commission is null   
  set @sql=@sql+'  +isNUll('+@rComm_clm+',0) '  
   
 set @sql=@sql+' )*-1)/'+@paid_fx_clm +','+@round_value+',1)) Settlement_Amount,  
 count(*) No_TRN  
 FROM   MoneySend  m join agentdetail sa on sa.agentcode=m.agentid     
 where transStatus in(''Payment'',''Cancel'',''Block'')  
 and confirmDate between '''+ @from_date +''' and '''+@to_date+' 23:59:59'''  
  
 set @sql=@sql+' and expected_payoutagentid='''+ @agent_id +''''  
 if @settlement_agent_id is not null  
  set @sql=@sql+' and agentid='''+@settlement_agent_id +''''  
 set @sql=@sql+'  
 group by convert(varchar,confirmDate,102)'  
end  
---- CANCEL TRN  
set @sql=@sql+'  
union all   
SELECT ''Cancel'',convert(varchar(50),b.InvoiceNo),convert(varchar,b.DOT,102) DOT,  
''Cancel TRN '' + isNULL(b.remarks,'''') as remarks,  
 round('+@totalroundamt +'/'+@paid_fx_clm +','+@round_value+',1)  
 DR,0 CR,'  
   
-- if @calc_commission is null   
  set @sql=@sql+' + round(isNUll('+@rComm_clm+',0)'  
 set @sql=@sql+'/'+@paid_fx_clm +','+@round_value+',1)*-1 Comm,  
  
 round(('+@totalroundamt +' '  
 if @calc_commission is null   
  set @sql=@sql+' + isNUll('+@rComm_clm+',0)'  
  
 set @sql=@sql+')/'+@paid_fx_clm +','+@round_value+',1) Settlement_Amount,  
 -1  
 FROM  AgentBalance b left outer join moneysend m  
 on b.tranno=m.tranno   
 where b.mode=''cancel'' and b.approved_by is not null  
 and b.dot between '''+ @from_date +''' and '''+@to_date+' 23:59:59''  and m.expected_payoutagentid='+ @agent_id   
  
  
-- COMMSSION SUMMARY  
if @headoffice_commission_id=@agent_id  
begin  
set @sql=@sql+'  
union all   
SELECT ''Commission'' , NULL ,convert(varchar,DOT,102) DOT,    
''Commission: '' +upper(mode)+'' '' + cast(sum(isNull(no_of_trn,1)) as varchar) as remarks,  
 case when mode=''dr'' then Sum(  
'+   
 case when @calc_currency='d' then ' dollar_rate '  
  else ' amount ' end +') else 0 end DR,  
 case when mode=''Cr'' then Sum(  
'+   
 case when @calc_currency='d' then ' dollar_rate '  
  else ' amount ' end +') else 0 end CR,  
 isNull(Sum(round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)),0)  as comm,  
 case when mode=''dr'' then Sum('+   
 case when @calc_currency='d' then ' dollar_rate '  
  else ' amount ' end +')    
  else (Sum('+   
 case when @calc_currency='d' then ' dollar_rate '  
  else ' amount ' end +')  ) * -1 end Settlement_Amount,  
  sum(isNull(no_of_trn,1)) No_TRN  
 FROM  AgentBalance b   
 where mode in (''dr'',''cr'')  and approved_by is not null  
 and dot between '''+ @from_date +''' and '''+ @to_date +' 23:59:59''    
 and b.agentcode='+ @agent_id ---@headoffice_commission_id  
 if @branch_id is not null  
  set @sql=@sql+' and b.branch_code='''+@branch_id +''''  
set @sql=@sql+'  
 group by convert(varchar,DOT,102),mode '  
end  
  
--FUND Receiving    
set @sql=@sql+'   
union all   
 SELECT  ''Fund''  , convert(varchar(50),b.InvoiceNo), b.DOT,    
 isNull(mt.moneytransfer,'''') +   
   isNUll(b.remarks,'''')  
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
 0 No_TRN  
 FROM  AgentBalance b   
 LEFT OUTER JOIN money_transfer mt  
 ON mt.money_id = b.money_id  
 where mode in (''dr'',''cr'') and approved_by is not null  
 and  b.dot between '''+ @from_date +''' and '''+ @to_date +' 23:59:59''  
 and b.agentcode='''+@agent_id +''''  
  
--- ############### Arch1 Start   
  
--- ############### Arch1 END  
-------- CHECK  Close date end  
 set @sql=@sql+') t order by t.dot'  
  
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
declare @msg_agenttype varchar(100),@url_desc varchar(1000),@desc varchar(3000)  
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
--set @url_desc='HI'  
set @url_desc='fromDate='+@from_date+'&toDate='+@to_date+'&agent_type='+isNull(@agent_type,'')  
+'&agent_detail_text='+ isNull(@agent_name,'')  
if @calc_currency is not null  
 set @url_desc=@url_desc+'&currType='+ @calc_currency  
if @branch_name is not null  
 set @url_desc=@url_desc +'&branch_detail_text=('+ [dbo].FNATrimAND(@branch_name)+')'  
set @url_desc=@url_desc +'&agentcode='+@agent_id+'&agent_branch_id='+isNull(@branch_id,'')  
set @url_desc=@url_desc +'&receive_agent_id='+isNull(@settlement_agent_id,'')  
set @url_desc=@url_desc +'&ReportType='+isNull(@flag,'')  
  
 print (@url_desc)  
 set @desc ='SOA '+ @msg_agenttype +' is completed'       
 EXEC  spa_message_board 'u', @login_user_id,  
    NULL, @batch_id,  
    @desc, 'c', @process_id,null,@url_desc  
 end  
  
  
  
  
  
  
  
  
  
  
  
  