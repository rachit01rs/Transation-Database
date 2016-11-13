drop  proc [dbo].[get_all_agentbalance_process]
go 
CREATE  proc [dbo].[get_all_agentbalance_process]    
@date_type char(1), -- c Current Balance, d Date wise    
@agent_type char(1), -- a MAIN AGent, b Branch Wise, d Bank/District Wise, f FUND TRANSFER IN EXCEL, l Ledger Report    
@country varchar(100)=null,    
@hide_nil char(1)=null,    
@as_of_date varchar(20)=null,    
@process_id varchar(200)=NULL,    
@login_user_id varchar(50)=NULL,    
@batch_Id varchar(100)=null  ,  
@state varchar(50)=null    
    
as    
---- Test    
--get_all_agentbalance 'd','b',NULL,'y','8/17/2008'    
--declare @date_type char(1), -- c Current Balance, d Date wise    
--@agent_type char(1), -- a MAIN AGent, b Branch Wise, d Bank/District Wise, f FUND TRANSFER IN EXCEL, l Ledger Report    
--@country varchar(100),    
--@hide_nil char(1),    
--@as_of_date varchar(20),    
--@process_id varchar(200),    
--@login_user_id varchar(50),    
--@batch_Id varchar(100)    
--set @date_type='d'    
--set @agent_type='a'    
--set @hide_nil='y'    
--set @as_of_date='9/17/2009'    
--set @process_id='123221'    
--set @login_user_id='Anoop'    
--set @batch_Id='SummaryBalance'    
--drop table iremit_process.dbo.SummaryBalance_Anoop_123221    
--- END TEST    
declare @sql varchar(max),@commission_agent_id varchar(50),@desc varchar(1000),@temptablename varchar(150),    
@headoffice_agent_id varchar(20),@payout_agent_commission_id varchar(50)    
--select @commission_agent_id=headoffice_commission_id,@headoffice_agent_id=headoffice_agent_id from tbl_setup    
select @commission_agent_id=headoffice_commission_id,@payout_agent_commission_id=payout_commission_id,    
@headoffice_agent_id=headoffice_agent_id from tbl_setup    
if @agent_type='e'    
 set @commission_agent_id=@payout_agent_commission_id    
     
    
-- from Job these parameter it will come ''    
if @hide_nil='-'     
 set @hide_nil=NULL    
    
if @country='-'     
 set @country=NULL    
-- Job End    
declare @rComm_clm varchar(500),@paid_fx_clm varchar(500)    
    
set @rComm_clm=' case when isNull(a.cal_commission_daily,''y'')=''y'' then (case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNULL(agent_receiverCommission,0) else isNULL(agent_receiverCommission,0)*isNull(paid_date_usd_rate,exchangeRate * 
  
agent_settlement_rate) end     
+ isNULL(agent_receiverSCommission,0)*agent_settlement_rate) else 0 end'    
    
set @paid_fx_clm='isNull(paid_date_usd_rate,exchangeRate * agent_settlement_rate)'    
    
set @sql=''    
 if @process_id is not null    
 begin    
  set @temptablename=dbo.FNAProcessTBl(@batch_Id, @login_user_id, @process_id)    
  set @sql='create table '+@temptablename+'(    
  Branch varchar(150),    
  bankName varchar(150),    
  BankBranch varchar(150),    
  Account_no varchar(100),    
  stotCollect Money,    
  Bank_Id  varchar(100),    
  Agent_Id varchar(20),    
  Agent_Name varchar(200),            
  AgentType varchar(150),    
  CurrencyType varchar(20),    
        settlement_type char(1),    
  Dr Money,    
  CR Money,    
  isBlock char(1),    
  USD_Detail money,    
  USD_Amt money,    
  UnPaidAmt money,    
  Prefund_Dr Money,    
  Prefund_CR Money,    
  )'    
     
 end    
     
if @date_type='d'    
begin    
 if @agent_type in('a')     
 begin    
  if @process_id is not null    
  begin    
 exec(@sql)  
   set @sql='insert into '+ @temptablename +'(agent_id,agent_name,AgentType,Dr,Cr,     
   CurrencyType,settlement_type,isBlock,USD_Detail,USD_Amt,UnPaidAmt,Prefund_Dr,Prefund_CR)'    
  end    
 set @sql=@sql+'    
  select agentcode agent_id, a.CompanyName agent_name,    
  CASE WHEN a.agentCan IN (''Receiver'',''Both'',''None'') THEN ''Receiving Agent'' ELSE ''Sending Agent'' END AgentType,    
  case when open_balance  >=0 then open_balance else 0 end DR,    
  case when open_balance < 0 then open_balance else 0 end CR,a.CurrencyType,a.settlement_type settlement_type,    
  case when accessed=''Blocked'' then ''y'' else ''n'' end isBlock ,    
  case when a.agentType in (''Sender Agent'',''Send and Pay'') then    
   case when open_USD  >=0 then open_USD else 0 end       else    
   case when isNUll(cast(open_balance/isNUll(c.usdRate,r.usdRRate) as money),0)  >=0 then isNUll(cast(open_balance/isNUll(c.usdRate,r.usdRRate) as money),0) else 0 end     
  end USD_Detail,    
  case when agentType in(''Sender Agent'',''Send and Pay'') then    
   case when open_USD  < 0 then open_USD else 0 end    
  else    
   case when isNUll(cast(open_balance/isNUll(c.usdRate,r.usdRRate) as money),0)  < 0 then isNUll(cast(open_balance/isNUll(c.usdRate,r.usdRRate) as money),0) else 0 end     
  end USD_AMT,    
  UnPaidAmt,    
  case when a.alert_balance_enable=''y'' then    
    case when open_balance_Prefun  >=0 then open_balance_Prefun else 0 end     
   else NULL end Prefund_Dr,    
  case when a.alert_balance_enable=''y'' then    
    case when open_balance_Prefun  < 0 then open_balance_Prefun else 0 end     
   else NULL end Prefund_Cr    
  from (    
  select  agentid, sum(Settlement_Amount) open_balance,sum(Settlement_USD) open_USD,sum(Prefund_Amt) UnPaidAmt,    
  sum(Settlement_Amount-Prefund_Amt) open_balance_Prefun    
  from(    
  SELECT agentid,isNull(sum(paidAmt-(senderCommission+isNUll(agent_ex_gain,0))),0) Settlement_Amount,    
  sum((paidAmt-(senderCommission+ isNUll(agent_ex_gain,0) ))/exchangeRate) Settlement_USD,0 Prefund_Amt    
  FROM MoneySend where transStatus not in(''Hold'')    
  and confirmDate  <= '''+@as_of_date +' 23:59:59''    
  group by agentid    
  UNION ALL    
  SELECT  expected_payoutagentid,     
  isNULL(sum((totalRoundAmt + isNUll('+@rComm_clm+' ,0))  * -1),0) Settlement_Amount,    
  isNULL(sum((totalRoundAmt + isNUll('+@rComm_clm+' ,0))/'+@paid_fx_clm+' * -1),0) Settlement_USD,0 Prefund_Amt    
  FROM   MoneySend m join agentdetail a on m.expected_payoutagentid=a.agentcode     
  where transStatus=''Payment'' and status in(''Paid'',''Post'')    
  and paidDate   <= '''+@as_of_date +' 23:59:59''     
  and expected_payoutagentid <> '''+ @headoffice_agent_id +'''    
  group by expected_payoutagentid    
  UNION ALL    
  SELECT  expected_payoutagentid, 0,0,    
  isNULL(sum(totalRoundAmt + isNUll('+@rComm_clm+' ,0)),0) Prefund_Amt    
  FROM   MoneySend m join agentdetail a on m.expected_payoutagentid=a.agentcode     
  where transStatus in (''Payment'',''Block'')     
  and status=''Un-Paid''    
  and confirmDate   <= '''+@as_of_date +' 23:59:59''     
  and expected_payoutagentid <> '''+ @headoffice_agent_id +'''    
  group by expected_payoutagentid    
  UNION ALL    
  SELECT b.agentcode,    
   sum(case when mode=''dr'' then Amount    
   WHEN mode=''cr'' THEN (amount - isNUll(abs(other_commission),0)) * -1     
   WHEN mode=''cancel'' THEN (amount - isNUll(other_commission,0)) * -1    
   ELSE 0    
   end)  Settlement_Amount,    
  sum(case when mode=''dr'' then Amount    
   WHEN mode=''cr'' THEN (amount - isNUll(abs(other_commission),0)) * -1     
   WHEN mode=''cancel'' THEN (amount - isNUll(other_commission,0)) * -1    
   ELSE 0    
   end/xRate) Settlement_USD,0 Prefund_Amt    
  FROM  AgentBalance b join agentdetail a on b.agentcode=a.agentcode    
  where b.approved_by is not null    
  and dot   <= '''+@as_of_date +' 23:59:59''    
  and b.agentcode not in('''+ @commission_agent_id +''') and a.agentCan not in (''Fund Account'')    
  group by b.agentcode    
  --Arch Union Start    
  union all    
  SELECT agentid,isNull(sum(paidAmt-(senderCommission+isNUll(agent_ex_gain,0))),0) Settlement_Amount,    
  sum((paidAmt-(senderCommission+ isNUll(agent_ex_gain,0) ))/exchangeRate) Settlement_USD,0 Prefund_Amt    
  FROM MoneySend_Arch1 where transStatus in(''Payment'',''Cancel'',''Block'')    
  and confirmDate  <= '''+@as_of_date +' 23:59:59''    
  group by agentid    
  UNION ALL    
  SELECT  expected_payoutagentid, isNULL(sum((totalRoundAmt + isNUll('+@rComm_clm+' ,0))  * -1),0) Settlement_Amount,    
  isNULL(sum((totalRoundAmt + isNUll('+@rComm_clm+' ,0))/'+@paid_fx_clm+' * -1),0) Settlement_USD,0 Prefund_Amt     
  FROM   MoneySend_Arch1 m join agentdetail a on m.expected_payoutagentid=a.agentcode     
  where transStatus=''Payment'' and status in(''Paid'',''Post'')    
  and paidDate   <= '''+@as_of_date +' 23:59:59''  and expected_payoutagentid <> '''+ @headoffice_agent_id +'''    
  group by expected_payoutagentid    
  UNION ALL    
  SELECT b.agentcode,    
   sum(case when mode=''dr'' then Amount    
   WHEN mode=''cr'' THEN (amount - isNUll(abs(other_commission),0)) * -1      
   WHEN mode=''cancel'' THEN (amount - isNUll(other_commission,0)) * -1    
   ELSE 0    
   end)  Settlement_Amount,    
  sum(case when mode=''dr'' then Amount    
   WHEN mode=''cr'' THEN (amount - isNUll(abs(other_commission),0)) * -1     
   WHEN mode=''cancel'' THEN (amount - isNUll(other_commission,0)) * -1    
   ELSE 0    
   end/xRate) Settlement_USD,0 Prefund_Amt     
  FROM  AgentBalance_arch1 b join agentdetail a on b.agentcode=a.agentcode    
  where b.approved_by is not null    
  and dot   <= '''+@as_of_date +' 23:59:59''    
  and b.agentcode not in('''+ @commission_agent_id +''') and a.agentCan not in (''Fund Account'')    
  group by b.agentcode    
 --Arch Union End    
  )l    
  group by agentid    
   ) s join agentdetail a on s.agentid=a.agentcode     
  left outer join (select avg(exchangeRate) usdRate,agentid from agentCurrencyRate group by agentid ) c    
  on a.agentcode=c.agentid left outer join (select cast(avg(DollarRate) as money) usdRRate,receivecountry     
  from CurrencyRate group by receivecountry ) r    
  on a.country=r.receivecountry    
  where a.accessed not in (''Cancel'')     
  and a.agentcode not in('''+ @commission_agent_id +''','''+ @headoffice_agent_id +''')'    
  if @country is not null    
   set @sql=@sql+' and a.country='''+@country+''''    
  if @hide_nil='y'     
   set @sql=@sql+' and s.open_balance <> 0 '    
  if @agent_type='a'    
   set @sql=@sql+' and agentType in(''Sender Agent'',''Send and Pay'',''ExtAgent'',''HORemit'') '    
  if @agent_type='d'    
   set @sql=@sql+' and agentType in(''Commercial Bank'',''External Bank'') '    
    
  set @sql=@sql+' order by a.country,a.companyname'    
  print @sql    
  exec(@sql)    
 end     
 if @agent_type in('d')     
 begin    
  if @process_id is not null    
  begin    
   set @sql=@sql+'insert into '+ @temptablename +'(agent_id,agent_name,Dr,Cr,     
   CurrencyType, isBlock,USD_Detail,USD_Amt)'    
  end    
 set @sql=@sql+'    
  select agentcode agent_id, a.CompanyName agent_name,    
  case when open_balance  >=0 then open_balance else 0 end DR,    
  case when open_balance < 0 then open_balance else 0 end CR,a.CurrencyType,    
  case when accessed=''Blocked'' then ''y'' else ''n'' end isBlock ,cast(isNUll(c.usdRate,r.usdRRate) as money) USD_Detail,    
  isNUll(cast(currentBalance/isNUll(c.usdRate,r.usdRRate) as money),0)  USD_Amt from (    
    
  select  agentid, sum(Settlement_Amount) open_balance from(    
  SELECT agentid,isNull(sum(paidAmt-(senderCommission+isNUll(agent_ex_gain,0))),0) Settlement_Amount    
  FROM MoneySend where transStatus not in(''Hold'')      
  and confirmDate  < '''+@as_of_date +' 23:59:59''    
  group by agentid    
  UNION ALL    
  SELECT  receiveAgentid, isNULL(sum((totalRoundAmt + isNUll('+@rComm_clm+' ,0))  * -1),0) Settlement_Amount    
  FROM   MoneySend m join agentdetail a on m.expected_payoutagentid=a.agentcode     
    where transStatus=''Payment'' and status in(''Paid'',''Post'')    
  and paidDate   < '''+@as_of_date +' 23:59:59''    
  group by receiveAgentid    
  UNION ALL    
  SELECT b.agentcode,sum(case when mode=''dr'' then Amount + isNUll(other_commission,0)     
   else (Amount  -(case when mode=''cancel'' then     
    isNUll(other_commission,0) * -1 else isNUll(other_commission,0) end * -1 )) * -1 end) Settlement_Amount    
  FROM  AgentBalance b join agentdetail a on b.agentcode=a.agentcode    
  where mode not in (''FundPending'',''FundPendingDr'',''comdr'',''comcr'') and b.approved_by is not null    
  and dot   < '''+@as_of_date +' 23:59:59''    
  and b.agentcode not in('''+ @commission_agent_id +''') and a.agentCan not in (''Fund Account'')    
  group by b.agentcode    
    
  ---Arch Table Start    
  select  agentid, sum(Settlement_Amount) open_balance from(    
  SELECT agentid,isNull(sum(paidAmt-(senderCommission+isNUll(agent_ex_gain,0))),0) Settlement_Amount    
  FROM MoneySend_arch1 where transStatus not in(''Hold'')      
  and confirmDate  < '''+@as_of_date +' 23:59:59''    
  group by agentid    
  UNION ALL    
  SELECT  receiveAgentid, isNULL(sum((totalRoundAmt + isNUll('+@rComm_clm+' ,0))  * -1),0) Settlement_Amount    
  FROM   MoneySend_arch1 m join agentdetail a on m.expected_payoutagentid=a.agentcode     
  where transStatus=''Payment'' and status in(''Paid'',''Post'')    
  and paidDate   < '''+@as_of_date +' 23:59:59''    
  group by receiveAgentid    
  UNION ALL    
  SELECT b.agentcode,sum(case when mode=''dr'' then Amount + isNUll(other_commission,0)     
   else (Amount  -(case when mode=''cancel'' then     
    isNUll(other_commission,0) * -1 else isNUll(other_commission,0) end * -1 )) * -1 end) Settlement_Amount    
  FROM  AgentBalance_arch1 b join agentdetail a on b.agentcode=a.agentcode    
  where b.approved_by is not null    
  and dot   < '''+@as_of_date +' 23:59:59''    
  and b.agentcode not in('''+ @commission_agent_id +''') and a.agentCan not in (''Fund Account'')    
  group by b.agentcode    
  ---Arch Table End    
  )l    
  group by agentid    
   ) s join agentdetail a on s.agentid=a.agentcode left outer join (select avg(exchangeRate) usdRate,agentid from agentCurrencyRate group by agentid ) c    
  on a.agentcode=c.agentid left outer join (select cast(avg(DollarRate) as money) usdRRate,receivecountry     
  from CurrencyRate group by receivecountry ) r    
  on a.country=r.receivecountry    
  where a.accessed not in (''Cancel'') and a.agentcode not in('''+ @commission_agent_id +''')'    
  if @country is not null    
   set @sql=@sql+' and a.country='''+@country+''''    
  if @hide_nil='y'     
   set @sql=@sql+' and s.open_balance <> 0 '    
  if @agent_type='a'    
   set @sql=@sql+' and agentType in(''Sender Agent'',''Send and Pay'',''ExtAgent'',''HORemit'') '    
  if @agent_type='d'    
   set @sql=@sql+' and agentType in(''Commercial Bank'',''External Bank'') '    
  set @sql=@sql+' order by a.country,a.companyname'    
  --print @sql    
  exec(@sql)    
 end     
 if @agent_type='b'     
 begin    
  if @process_id is not null    
  begin    
   set @sql=@sql+'insert into '+ @temptablename +'(agent_id,agent_name,Dr,Cr,     
   CurrencyType, isBlock,USD_Detail,USD_Amt)'    
  end    
 set @sql=@sql+'    
  select agent_branch_code agent_id,'' [b] ''+ isNUll(a.agent_short_code,a.CompanyName)+'' [/b],''+b.Branch agent_name,    
  case when open_balance  >=0 then open_balance else 0 end DR,    
  case when open_balance < 0 then open_balance else 0 end CR,a.CurrencyType,    
  isNull(block_branch,''n'') isBlock ,0 USD_Detail,0 USD_Amt from (    
    
  select  branch_code, sum(Settlement_Amount) open_balance from(    
  SELECT branch_code,isNull(sum(paidAmt-(senderCommission+isNUll(agent_ex_gain,0))),0) Settlement_Amount    
  FROM MoneySend where transStatus not in(''Hold'')        
  and confirmDate  < '''+@as_of_date +' 23:59:59''    
  group by branch_code    
  UNION ALL    
  SELECT  rBankID, isNULL(sum(totalRoundAmt  *-1),0) Settlement_Amount    
  FROM   MoneySend  where transStatus=''Payment'' and status in(''Paid'',''Post'')    
  and paidDate   < '''+@as_of_date +' 23:59:59''    
  group by rBankID    
  UNION ALL    
  SELECT branch_code,sum(case when mode=''dr'' then Amount  else (Amount ) * -1 end) Settlement_Amount    
  FROM  AgentBalance b join agentdetail a on b.agentcode=a.agentcode    
  where  b.approved_by is not null    
  and dot   < '''+@as_of_date +' 23:59:59''    
  and b.agentcode not in('''+ @commission_agent_id +''') and a.agentCan not in (''Fund Account'')    
  group by b.branch_code    
  ---- Arch Table Start    
  union all    
  SELECT branch_code,isNull(sum(paidAmt-(senderCommission+isNUll(agent_ex_gain,0))),0) Settlement_Amount    
  FROM MoneySend_arch1 where transStatus not in(''Hold'')       
  and confirmDate  < '''+@as_of_date +' 23:59:59''    
  group by branch_code    
  UNION ALL    
  SELECT  rBankID, isNULL(sum(totalRoundAmt  *-1),0) Settlement_Amount    
  FROM   MoneySend_arch1  where transStatus=''Payment'' and status in(''Paid'',''Post'')    
  and paidDate   < '''+@as_of_date +' 23:59:59''    
  group by rBankID    
  UNION ALL    
  SELECT branch_code,sum(case when mode=''dr'' then Amount  else (Amount ) * -1 end) Settlement_Amount    
  FROM  AgentBalance_arch1 b join agentdetail a on b.agentcode=a.agentcode    
  where  b.approved_by is not null    
  and dot   < '''+@as_of_date +' 23:59:59''    
  and b.agentcode not in('''+ @commission_agent_id +''') and a.agentCan not in (''Fund Account'')    
  group by b.branch_code    
  ---- Arch Table End    
    
  )l    
  group by branch_code    
   ) s join agentbranchdetail b  on s.branch_code=b.agent_branch_code    
  join agentdetail a on b.agentcode=a.agentcode    
  where a.accessed not in (''Cancel'') and agentType in(''External Bank'',''Local Agent'') and a.agentcode not in('''+ @commission_agent_id +''')'    
  if @country is not null    
   set @sql=@sql+' and a.country='''+@country+''''    
  if @hide_nil='y'     
   set @sql=@sql+' and s.open_balance <> 0 '    
  set @sql=@sql+' order by a.country,companyname,Branch'    
  print @sql    
  exec(@sql)    
 end    
 if @agent_type in('c','e') -- COMMISSION    
 begin    
  if @process_id is not null    
  begin    
   set @sql=@sql+'insert into '+ @temptablename +'(agent_id,agent_name,Dr,Cr,     
   CurrencyType, isBlock,USD_Detail,USD_Amt)'    
  end    
 set @sql=@sql+'    
  select agent_branch_code agent_id,'' [b] ''+ isNUll(a.agent_short_code,a.CompanyName)+'' [/b],''+b.Branch agent_name,    
   case when open_balance  >=0 then open_balance else 0 end DR,    
  case when open_balance < 0 then open_balance else 0 end CR,a.CurrencyType,    
  isNull(block_branch,''n'') isBlock ,0 USD_Detail,0 USD_Amt from (    
  select  branch_code, sum(Settlement_Amount) open_balance from(    
      
  SELECT branch_code,sum(case when mode=''dr'' then Amount  else (Amount ) * -1 end) Settlement_Amount    
  FROM  AgentBalance  b join agentdetail a on b.agentcode=a.agentcode    
  where  b.approved_by is not null     
  and a.agentCan in (''Fund Account'')    
  and dot   < '''+@as_of_date +' 23:59:59''    
  and b.agentcode in ('''+ @commission_agent_id +''')    
  group by branch_code    
  union all    
  SELECT branch_code,sum(case when mode=''dr'' then Amount  else (Amount ) * -1 end) Settlement_Amount    
  FROM  AgentBalance_Arch1  b join agentdetail a on b.agentcode=a.agentcode    
  where b.approved_by is not null     
  and a.agentCan in (''Fund Account'')    
  and dot   < '''+@as_of_date +' 23:59:59''    
  and b.agentcode in ('''+ @commission_agent_id +''')    
  group by branch_code    
    
  )l    
  group by branch_code    
   ) s join agentbranchdetail b  on s.branch_code=b.agent_branch_code    
  join agentdetail a on b.agentcode=a.agentcode    
  where a.accessed not in (''Cancel'')'    
  if @country is not null    
   set @sql=@sql+' and a.country='''+@country+''''    
  if @hide_nil='y'     
   set @sql=@sql+' and s.open_balance <> 0 '    
    
  set @sql=@sql+' order by a.country,companyname,Branch'    
  print @sql    
  exec(@sql)    
 end    
 if @agent_type='l' -- Ledger Report    
 begin    
  if @process_id is not null    
  begin    
   set @sql=@sql+'insert into '+ @temptablename +'(agent_id,agent_name,Dr,Cr,     
   CurrencyType, isBlock,USD_Detail,USD_Amt)'    
  end    
 set @sql=@sql+'    
  select agent_branch_code agent_id,'' [b] ''+ isNUll(a.agent_short_code,a.CompanyName)+'' [/b],''+b.Branch agent_name,    
  case when open_balance  >=0 then open_balance else 0 end DR,    
  case when open_balance < 0 then open_balance else 0 end CR,a.CurrencyType,    
  isNull(block_branch,''n'') isBlock ,0 USD_Detail,0 USD_Amt from (    
  select  branch_code, sum(Settlement_Amount) open_balance from(     
  SELECT branch_code,sum(case when mode=''dr'' then Amount  else (Amount ) * -1 end) Settlement_Amount    
  FROM  AgentBalance  b join agentdetail a on b.agentcode=a.agentcode    
  where mode not in (''FundPending'',''FundPendingDr'',''comdr'',''comcr'') and b.approved_by is not null     
  and a.agentCan in (''Fund Account'')    
  and dot   < '''+@as_of_date +' 23:59:59''    
  and a.agentCan in (''Fund Account'')    
  group by branch_code    
  )l    
  group by branch_code    
   ) s join agentbranchdetail b  on s.branch_code=b.agent_branch_code    
  join agentdetail a on b.agentcode=a.agentcode    
  where a.accessed not in (''Cancel'')'    
  if @country is not null    
   set @sql=@sql+' and a.country='''+@country+''''    
  if @hide_nil='y'     
   set @sql=@sql+' and s.open_balance <> 0 '    
    
  set @sql=@sql+' order by a.country,companyname,Branch'    
  print @sql    
  exec(@sql)    
 end    
end    
    
if @process_id is not null    
 begin    
    
declare @msg_agenttype varchar(100),@url_desc varchar(200)    
if @agent_type='a'     
 set @msg_agenttype='(Main Agent) '    
else if @agent_type='b'     
 set @msg_agenttype='(Branch Wise) '    
else if @agent_type='d'     
 set @msg_agenttype='(Bank/District Wise)'    
else if @agent_type='c'     
 set @msg_agenttype='(Branch Wise Commission)'    
else if @agent_type='e'     
 set @msg_agenttype='(Agent Wise Commission)'    
else    
 set @msg_agenttype=''     
     
set @url_desc='fromDate='+@as_of_date+'&agent_type='+@agent_type+'&state='+isNULL(@state,'')   
    
 set @desc =upper(@batch_id)+' '+ @msg_agenttype +' is completed for as of date:' + @as_of_date         
 EXEC  spa_message_board 'u', @login_user_id,    
    NULL, @batch_id,    
    @desc, 'c', @process_id,null,@url_desc    
 end  
  