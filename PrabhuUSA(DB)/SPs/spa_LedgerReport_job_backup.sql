----------LIVE BACKUP ------------
CREATE proc [dbo].[spa_LedgerReport_job]                      
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
 ------TEST Script                      
 --declare @flag char(1),@agent_id varchar(50),@branch_id varchar(50),@from_date varchar(20),                      
 --@to_date varchar(20),@settlement_agent_id varchar(50),@calc_opening_balance char(1),                      
 --@agent_type char(1), @calc_currency char(1),@usd_rate money,@calc_commission char(1),                      
 --@login_user_id varchar(50),@process_id varchar(200),@batch_id varchar(100)                      
 --set @flag='s'                      
 --set @agent_id='20100114'                      
 ----set @settlement_agent_id='84600001'                      
 --set @from_date='2012-08-01'                      
 --set @to_date='2012-08-08'                      
 --set @calc_opening_balance='y'                      
 --set @agent_type='a'                      
 --set @login_user_id='Anoop'                      
 --set @process_id='222'                      
 --set @calc_currency='d'                      
 --set @batch_id='Ledger'                      
 --exec('drop table iremit_process.dbo.'+@batch_id+'_Anoop_222')                      
 --drop table #temp                      
 --drop table #temp_arch1                      
 --drop table #temp_current                      
 -----------TEST End                      
 if @batch_id is null                      
 set @batch_id='soa_ledger'                      
 declare @ledger_tabl varchar(150)                      
                       
 declare @round_value varchar(2),@calc_currency_soa char(1)                    
                     
 set @calc_currency_soa=isNull(@calc_currency,'l')                      
                       
                       
 declare @sql varchar(max),@rComm_clm varchar(550), @expected_payoutagentid varchar(50),@curr_type varchar(20),                      
 @headoffice_commission_id varchar(50),@agent_name varchar(500),@branch_name varchar(500)                      
 select @headoffice_commission_id=headoffice_commission_id,@round_value=round_value from tbl_setup WITH(NOLOCK)                     
                       
 if @round_value is null                      
 set @round_value=10                      
                       
 if @agent_id is not null                      
  select @calc_commission=cal_commission_daily        
 --,@calc_currency=ISNULL(@calc_currency,isNUll(settlement_type,'l'))          
   from agentdetail WITH(NOLOCK)                     
 where agentcode=@agent_id                      
                       
 if @calc_commission='y'                      
  set @calc_commission=NULL                      
                     
 if @batch_id='soa_ledger_monthly'                    
  set  @calc_currency= @calc_currency_soa                    
                       
 -- ajay add fininsh                      
 if @branch_id is not null                      
 begin                      
  --set @rComm_clm='receiverCommission'                      
  set @rComm_clm=' ReceiverCommission'                      
                       
  select @agent_id=agentcode,@expected_payoutagentid=agent_code_id ,@branch_name=branch                      
  from agentbranchdetail WITH(NOLOCK) where agent_branch_code=@branch_id                      
 end                      
 else                      
 begin               
                       
  if @agent_type='d'                      
   set @rComm_clm='ReceiverCommission'                        
  else                      
   set @rComm_clm=' (CASE WHEN isNull(agent_receiverComm_Currency,''l'')=''l'' then agent_receiverCommission else agent_receiverCommission*isNull(paid_date_usd_rate,exchangeRate * agent_settlement_rate) end                       
 + agent_receiverSCommission*agent_settlement_rate)'                      
 end                      
 if @calc_commission is not null                      
  set @rComm_clm='0'                      
                       
 declare @send_fx_clm varchar(50),@paid_fx_clm varchar(200),@balance_fx_clm varchar(50)                      
                       
 --if @agent_type is NULL or @agent_type ='a'                      
if @calc_currency='l' or @calc_currency is null                      
 begin                      
  select @curr_type=currencyType  from agentdetail WITH(NOLOCK) where agentcode=@agent_id                      
  set @send_fx_clm='1'                      
  set @paid_fx_clm='1'                      
  set @balance_fx_clm='1'                      
 end                      
 else                      
 begin                      
  set @curr_type='USD'                      
  set @send_fx_clm='ExchangeRate'                      
  set @paid_fx_clm='isNull(CASE WHEN ReceiverCountry=''Nepal'' THEN paid_date_usd_rate ELSE payout_settle_usd END ,exchangeRate * agent_settlement_rate)'                      
  set @balance_fx_clm='xRate'                      
 end                      
                       
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
  [Settlement_Amount] [money] NULL                       
 ) ON [PRIMARY]                      
                       
 CREATE TABLE [#temp_current] (                      
  [sno] int identity(1,1) ,                      
  [DOT] [datetime] NULL ,                      
  [TranNo] varchar(50) NULL ,                      
  [Type] varchar(20) NULL,                      
  [Remarks] [varchar] (6000)  NULL ,                      
  [DR] [money] NULL ,                      
  [CR] [money] NULL ,                      
  [Comm] [money] NULL ,                      
  [Settlement_Amount] [money] NULL                       
 ) ON [PRIMARY]                      
                       
 CREATE TABLE [#temp_arch1] (                      
  [sno] int identity(1,1) ,                      
  [DOT] [datetime] NULL ,                      
  [TranNo] varchar(50) NULL ,                      
  [Type] varchar(20) NULL,                      
  [Remarks] [varchar] (6000)  NULL ,                      
  [DR] [money] NULL ,                      
  [CR] [money] NULL ,                      
  [Comm] [money] NULL ,                      
  [Settlement_Amount] [money] NULL                       
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
  Currency varchar(50)                      
 ) ON [PRIMARY]'                      
 exec (@sql)     
                       
 select @agent_name=companyName from agentdetail WITH(NOLOCK) where agentcode=@agent_id                      
                       
 DECLARE @map_id varchar(1000)                      
                       
 if @settlement_agent_id IS NOT NULL                      
 begin                      
                       
 SET @map_id=''              
 SELECT @map_id=@map_id + ''''+ ledger_id  +''',' FROM                       
 agent_mapping_ledger  WITH(NOLOCK)                     
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
  insert #temp_current(Settlement_Amount)                      
  SELECT sum('+                       
  case when @calc_currency='d' then ' dollar_amt '                      
   else ' paidAmt ' end +'- round((senderCommission+isNUll(agent_ex_gain,0))/'+@send_fx_clm +','+ @round_value +',1)) Settlement_Amount                      
  FROM MoneySend with (nolock) where transStatus in(''Payment'',''Cancel'',''Block'') and agentid='+ @agent_id +'                      
  and confirmDate < '''+ @from_date +''''                      
                      
  if @branch_id is not null                      
   set @sql=@sql+' and branch_code='''+@branch_id +''''                       
  if @settlement_agent_id is not null                      
   set @sql=@sql+' and expected_payoutagentid='''+@settlement_agent_id +''''                      
  set @sql=@sql+'                      
  UNION ALL                      
  SELECT   isNULL(sum(round(((totalRoundAmt '                      
  if @calc_commission is null                       
   set @sql=@sql+' + isNUll('+@rComm_clm+',0)'                      
  set @sql=@sql+') * -1)/'+@paid_fx_clm +','+@round_value+',1)),0) Settlement_Amount                      
  FROM   MoneySend m with (nolock) join agentdetail sa on sa.agentcode=m.agentid                        
  where transStatus=''Payment'' and status in(''Paid'',''Post'')                      
  and paidDate < '''+ @from_date +''''                      
  if @agent_type is null or @agent_type='a'                      
   set @sql=@sql+' and expected_payoutagentid='''+ @agent_id +''''                      
  if @agent_type='d'                      
   set @sql=@sql+' and receiveAgentID='''+ @agent_id +''''                      
  if @branch_id is not null                      
   set @sql=@sql+' and rBankID='''+@branch_id +''''                      
                        
  if @settlement_agent_id is not null                      
   set @sql=@sql+' and agentid='''+@settlement_agent_id +''''                      
                        
 --- Sending Agent Agent Balance                      
 set @sql=@sql+' union all                       
 select sum((case when mode=''dr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +'+ round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)  else                       
  ('+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +'  -(case when mode=''cancel'' then round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) * -1 else                       
  round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) end * -1 ) ) * -1 end)) Settlement_Amount                      
  from agentbalance b with (nolock) join agentdetail a WITH(NOLOCK) on a.agentcode=b.agentcode and a.agentType in(''Sender Agent'',''Send and Pay'')                       
  where mode in (''dr'',''cr'') and approved_by is not null                       
  and   dot < '''+ @from_date +'''                      
  and b.agentcode ='''+@agent_id+'''                      
  UNION ALL                       
 --- Receiving Agent Agent Balance                      
  SELECT sum(case when mode=''dr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' '                      
  if @calc_commission is null                       
   set @sql=@sql+' + round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)'                      
  set @sql=@sql+' else ('+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' '                      
    set @sql=@sql+') * -1 end) Settlement_Amount                      
  FROM  AgentBalance b with (nolock) join agentdetail a WITH(NOLOCK)                     
  on a.agentcode=b.agentcode and a.agentType not in(''Sender Agent'',''Send and Pay'')                      
  where mode in (''dr'',''cr'') and approved_by is not null                      
  and dot < '''+ @from_date  +''' and b.agentcode='+ @agent_id         
  if @branch_id is not null                      
   set @sql=@sql+' and b.branch_code='''+@branch_id +''''                      
  set @sql=@sql+' group by b.agentcode,branch_code                      
  Union All                       
 -- CANCEL Voucher Only                      
  SELECT sum('+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +'  - round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)) * -1 Settlement_Amount                      
  FROM  AgentBalance b with (nolock) left outer join moneysend m    with (nolock)                   
  on b.tranno=m.tranno                       
  where b.mode=''cancel'' and b.approved_by is not null                      
  and b.dot < '''+ @from_date  +''' and b.agentcode='+ @agent_id                       
  if @branch_id is not null                      
   set @sql=@sql+' and b.branch_code='''+@branch_id +''''                      
  if @settlement_agent_id is not null                      
   set @sql=@sql+' and m.expected_payoutagentid='''+@settlement_agent_id +''''                      
 --------------------------CALC AgentWise for ExGain and Loss                      
                       
 if len(@map_id) > 8 AND @settlement_agent_id IS NOT NULL                      
 begin                      
                       
 set @sql=@sql+' union all                     
 select sum((case when mode=''dr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +'+ round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)  else                       
  ('+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +'  -(case when mode=''cancel'' then round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) * -1 else                       
  round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) end * -1 ) ) * -1 end)) Settlement_Amount                      
 from agentbalance b with (nolock) join agentdetail a WITH(NOLOCK) on a.agentcode=b.agentcode and a.agentType in(''Sender Agent'',''Send and Pay'')                       
  where mode in (''dr'',''cr'') and approved_by is not null                       
  and   dot < '''+ @from_date +'''                      
  and b.agentcode ='''+@agent_id+''''                       
  set @sql=@sql+' and b.branch_code  in ('+@map_id +')'                      
  set @sql=@sql+'                       
 ) b '                      
 end                      
 -- set @sql=@sql+')l'                      
  print @sql                      
  exec(@sql)                      
                       
 -----------###############ARCH1                      
 set @sql='insert #temp_arch1(Settlement_Amount)                      
  SELECT sum('+                       
  case when @calc_currency='d' then ' dollar_amt '                      
   else ' paidAmt ' end +'- round((senderCommission+isNUll(agent_ex_gain,0))/'+@send_fx_clm +','+ @round_value +',1)) Settlement_Amount                      
  FROM MoneySend_arch1 with (nolock) where transStatus in(''Payment'',''Cancel'',''Block'') and agentid='+ @agent_id +'                      
  and confirmDate < '''+ @from_date +''''                      
                       
  if @branch_id is not null                      
   set @sql=@sql+' and branch_code='''+@branch_id +''''                       
  if @settlement_agent_id is not null                      
   set @sql=@sql+' and expected_payoutagentid='''+@settlement_agent_id +''''                      
  set @sql=@sql+'                      
  UNION ALL                      
  SELECT   isNULL(sum(round(((totalRoundAmt '                      
  if @calc_commission is null                       
   set @sql=@sql+' + isNUll('+@rComm_clm+',0)'                      
  set @sql=@sql+') * -1)/'+@paid_fx_clm +','+@round_value+',1)),0) Settlement_Amount                      
  FROM   MoneySend_arch1 m with (nolock) join agentbranchdetail b WITH(NOLOCK)                       
 on m.rbankID=b.agent_branch_code join agentdetail sa WITH(NOLOCK) on sa.agentcode=m.agentid                    
  where transStatus=''Payment'' and status in(''Paid'',''Post'')                      
  and paidDate < '''+ @from_date +''''                 
  if @agent_type is null or @agent_type='a'                      
   set @sql=@sql+' and expected_payoutagentid='''+ @agent_id +''''                      
  if @agent_type='d'                      
   set @sql=@sql+' and receiveAgentID='''+ @agent_id +''''                      
  if @branch_id is not null                      
   set @sql=@sql+' and rBankID='''+@branch_id +''''                      
                        
  if @settlement_agent_id is not null                      
   set @sql=@sql+' and agentid='''+@settlement_agent_id +''''                      
                        
 --- Sending Agent Agent Balance                      
 set @sql=@sql+' union all                       
 select sum((case when mode=''dr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +'+ round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)  else                       
  ('+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +'  -(case when mode=''cancel'' then round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) * -1 else                       
  round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) end * -1 ) ) * -1 end)) Settlement_Amount                      
 from agentbalance_arch1 b with (nolock) join agentdetail a WITH(NOLOCK) on a.agentcode=b.agentcode and a.agentType in(''Sender Agent'',''Send and Pay'')                       
  where mode in (''dr'',''cr'') and approved_by is not null                       
  and   dot < '''+ @from_date +'''                      
  and b.agentcode ='''+@agent_id+'''                       
  UNION ALL                       
 --- Receiving Agent Agent Balance                      
  SELECT sum(case when mode=''dr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' '                      
  if @calc_commission is null                       
   set @sql=@sql+' + round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)'                      
  set @sql=@sql+' else ('+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' '                      
    set @sql=@sql+') * -1 end) Settlement_Amount                      
  FROM  agentbalance_arch1 b with (nolock) join agentdetail a WITH(NOLOCK)                      
  on a.agentcode=b.agentcode and a.agentType not in(''Sender Agent'',''Send and Pay'')                      
  where mode in (''dr'',''cr'') and approved_by is not null                      
  and dot < '''+ @from_date  +''' and b.agentcode='+ @agent_id                       
  if @branch_id is not null                      
   set @sql=@sql+' and b.branch_code='''+@branch_id +''''                      
  set @sql=@sql+' group by b.agentcode,branch_code                      
  Union All                       
 -- CANCEL Voucher Only                      
  SELECT sum('+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +'  - round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)) * -1 Settlement_Amount                      
  FROM  agentbalance_arch1 b with (nolock) left outer join moneysend_arch1 m WITH(NOLOCK)                      
  on b.tranno=m.tranno                       
  where b.mode=''cancel'' and b.approved_by is not null                      
  and b.dot < '''+ @from_date  +''' and b.agentcode='+ @agent_id                       
  if @branch_id is not null                      
   set @sql=@sql+' and b.branch_code='''+@branch_id +''''                      
  if @settlement_agent_id is not null                      
   set @sql=@sql+' and m.expected_payoutagentid='''+@settlement_agent_id +''''                      
                        
 -- set @sql=@sql+')l'                      
  print @sql                      
                       
  exec(@sql)                      
                       
 end                     
                     
 --PMT NEPAL                    
 ---pmt nepal                    
 if @agent_id='20100003'                    
 begin                    
 declare @pmt_date varchar(50)                    
                     
 if @calc_opening_balance='y'                   
 begin                      
 set @pmt_date='2011-04-30 23:59:59.998'                    
 delete #temp_current                    
 delete #temp_arch1                    
  --GET OPENING BALANCE                      
  set @sql='                      
  insert #temp_current(Settlement_Amount)                    
  select -2390386.29 Settlement_Amount                     
  union all                    
  SELECT sum('+                       
  case when @calc_currency='d' then ' dollar_amt '                      
   else ' paidAmt ' end +'- round((senderCommission+isNUll(agent_ex_gain,0))/'+@send_fx_clm +','+ @round_value +',1)) Settlement_Amount                      
  FROM MoneySend with (nolock) where transStatus in(''Payment'',''Cancel'',''Block'') and agentid='+ @agent_id +'                      
  and confirmDate between '''+ @pmt_date +''' and '''+@from_date +''''                    
                      
  if @branch_id is not null                      
   set @sql=@sql+' and branch_code='''+@branch_id +''''                       
  if @settlement_agent_id is not null                      
   set @sql=@sql+' and expected_payoutagentid='''+@settlement_agent_id +''''                      
  set @sql=@sql+'                      
  UNION ALL                      
  SELECT   isNULL(sum(round(((totalRoundAmt '                      
  if @calc_commission is null                       
   set @sql=@sql+' + isNUll('+@rComm_clm+',0)'                      
  set @sql=@sql+') * -1)/'+@paid_fx_clm +','+@round_value+',1)),0) Settlement_Amount                      
  FROM   MoneySend m with (nolock) join agentdetail sa WITH(NOLOCK) on sa.agentcode=m.agentid                        
  where transStatus=''Payment'' and status in(''Paid'',''Post'')                      
  and paidDate between '''+ @pmt_date +''' and '''+@from_date +''''                    
  if @agent_type is null or @agent_type='a'                      
   set @sql=@sql+' and expected_payoutagentid='''+ @agent_id +''''                      
  if @agent_type='d'                      
   set @sql=@sql+' and receiveAgentID='''+ @agent_id +''''                      
  if @branch_id is not null                      
   set @sql=@sql+' and rBankID='''+@branch_id +''''                      
                        
  if @settlement_agent_id is not null                      
   set @sql=@sql+' and agentid='''+@settlement_agent_id +''''                      
                        
 --- Sending Agent Agent Balance                      
 set @sql=@sql+' union all                    
 select sum((case when mode=''dr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +'+ round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)  else                       
  ('+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +'  -(case when mode=''cancel'' then round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) * -1 else                       
  round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) end * -1 ) ) * -1 end)) Settlement_Amount                      
  from agentbalance b with (nolock) join agentdetail a WITH(NOLOCK) on a.agentcode=b.agentcode and a.agentType in(''Sender Agent'',''Send and Pay'')                       
  where mode in (''dr'',''cr'') and approved_by is not null                       
  and   dot between '''+ @pmt_date +''' and '''+@from_date +'''                    
  and b.agentcode ='''+@agent_id+'''                       
  UNION ALL                       
 --- Receiving Agent Agent Balance                      
  SELECT sum(case when mode=''dr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' '                      
  if @calc_commission is null                       
   set @sql=@sql+' + round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)'                      
  set @sql=@sql+' else ('+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' '                      
    set @sql=@sql+') * -1 end) Settlement_Amount                      
  FROM  AgentBalance b with (nolock) join agentdetail a WITH(NOLOCK)                      
  on a.agentcode=b.agentcode and a.agentType not in(''Sender Agent'',''Send and Pay'')                      
  where mode in (''dr'',''cr'') and approved_by is not null                      
  and dot between '''+ @pmt_date +''' and '''+@from_date +''' and b.agentcode='+ @agent_id                       
  if @branch_id is not null                      
   set @sql=@sql+' and b.branch_code='''+@branch_id +''''                      
  set @sql=@sql+' group by b.agentcode,branch_code                      
  Union All                       
 -- CANCEL Voucher Only                      
  SELECT sum('+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +'  - round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)) * -1 Settlement_Amount                      
  FROM  AgentBalance b with (nolock) left outer join moneysend m    with (nolock)                   
  on b.tranno=m.tranno                       
  where b.mode=''cancel'' and b.approved_by is not null                      
  and b.dot between '''+ @pmt_date +''' and '''+@from_date +''' and b.agentcode='+ @agent_id                       
  if @branch_id is not null                      
   set @sql=@sql+' and b.branch_code='''+@branch_id +''''                      
  if @settlement_agent_id is not null   
   set @sql=@sql+' and m.expected_payoutagentid='''+@settlement_agent_id +''''                      
 --------------------------CALC AgentWise for ExGain and Loss                      
                       
 if len(@map_id) > 8 AND @settlement_agent_id IS NOT NULL                      
 begin                      
                       
 set @sql=@sql+' union all                     
 select sum((case when mode=''dr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +'+ round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)  else                       
  ('+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +'  -(case when mode=''cancel'' then round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) * -1 else              
  round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) end * -1 ) ) * -1 end)) Settlement_Amount                      
 from agentbalance b with (nolock) join agentdetail a WITH(NOLOCK) on a.agentcode=b.agentcode and a.agentType in(''Sender Agent'',''Send and Pay'')                       
  where mode in (''dr'',''cr'') and approved_by is not null                       
  and   dot between '''+ @pmt_date +''' and '''+@from_date +'''                    
  and b.agentcode ='''+@agent_id+''''                       
  set @sql=@sql+' and b.branch_code  in ('+@map_id +')'                      
  set @sql=@sql+'                       
 ) b '                      
 end                      
 -- set @sql=@sql+')l'                      
  print @sql                      
  exec(@sql)                      
                       
 -----------###############ARCH1                      
 set @sql='insert #temp_arch1(Settlement_Amount)                      
  SELECT sum('+                       
  case when @calc_currency='d' then ' dollar_amt '                      
   else ' paidAmt ' end +'- round((senderCommission+isNUll(agent_ex_gain,0))/'+@send_fx_clm +','+ @round_value +',1)) Settlement_Amount                      
  FROM MoneySend_arch1 with (nolock) where transStatus in(''Payment'',''Cancel'',''Block'') and agentid='+ @agent_id +'                      
  and confirmDate between '''+ @pmt_date +''' and '''+@from_date +''''                    
                       
  if @branch_id is not null                      
   set @sql=@sql+' and branch_code='''+@branch_id +''''                       
  if @settlement_agent_id is not null                      
   set @sql=@sql+' and expected_payoutagentid='''+@settlement_agent_id +''''                      
  set @sql=@sql+'                      
  UNION ALL                      
  SELECT   isNULL(sum(round(((totalRoundAmt '                      
  if @calc_commission is null                       
   set @sql=@sql+' + isNUll('+@rComm_clm+',0)'                      
  set @sql=@sql+') * -1)/'+@paid_fx_clm +','+@round_value+',1)),0) Settlement_Amount                      
  FROM   MoneySend_arch1 m with (nolock) join agentbranchdetail b WITH(NOLOCK)                       
 on m.rbankID=b.agent_branch_code join agentdetail sa WITH(NOLOCK) on sa.agentcode=m.agentid                    
  where transStatus=''Payment'' and status in(''Paid'',''Post'')                      
  and paidDate between '''+ @pmt_date +''' and '''+@from_date +''''                    
  if @agent_type is null or @agent_type='a'                      
   set @sql=@sql+' and expected_payoutagentid='''+ @agent_id +''''                      
  if @agent_type='d'                      
   set @sql=@sql+' and receiveAgentID='''+ @agent_id +''''                      
  if @branch_id is not null                      
   set @sql=@sql+' and rBankID='''+@branch_id +''''                      
                        
  if @settlement_agent_id is not null                      
   set @sql=@sql+' and agentid='''+@settlement_agent_id +''''                      
              
 --- Sending Agent Agent Balance                      
 set @sql=@sql+' union all                       
 select sum((case when mode=''dr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +'+ round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)  else                       
  ('+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +'  -(case when mode=''cancel'' then round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) * -1 else                       
  round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) end * -1 ) ) * -1 end)) Settlement_Amount                      
 from agentbalance_arch1 b with (nolock) join agentdetail a WITH(NOLOCK) on a.agentcode=b.agentcode and a.agentType in(''Sender Agent'',''Send and Pay'')                       
  where mode in (''dr'',''cr'') and approved_by is not null                       
  and   dot between '''+ @pmt_date +''' and '''+@from_date +'''                    
  and b.agentcode ='''+@agent_id+'''                       
  UNION ALL                       
 --- Receiving Agent Agent Balance                      
  SELECT sum(case when mode=''dr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' '                      
  if @calc_commission is null                       
   set @sql=@sql+' + round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)'                      
  set @sql=@sql+' else ('+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' '                      
    set @sql=@sql+') * -1 end) Settlement_Amount                      
  FROM  agentbalance_arch1 b with (nolock) join agentdetail a WITH(NOLOCK)                      
  on a.agentcode=b.agentcode and a.agentType not in(''Sender Agent'',''Send and Pay'')                      
  where mode in (''dr'',''cr'') and approved_by is not null                      
  and dot between '''+ @pmt_date +''' and '''+@from_date +''' and b.agentcode='+ @agent_id                       
  if @branch_id is not null                      
   set @sql=@sql+' and b.branch_code='''+@branch_id +''''                      
  set @sql=@sql+' group by b.agentcode,branch_code                      
  Union All                       
 -- CANCEL Voucher Only                      
  SELECT sum('+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +'  - round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)) * -1 Settlement_Amount                      
  FROM  agentbalance_arch1 b with (nolock) left outer join moneysend_arch1 m WITH(NOLOCK)                      
  on b.tranno=m.tranno                       
  where b.mode=''cancel'' and b.approved_by is not null                      
  and b.dot between '''+ @pmt_date +''' and '''+@from_date +''' and b.agentcode='+ @agent_id                       
  if @branch_id is not null                      
   set @sql=@sql+' and b.branch_code='''+@branch_id +''''                      
  if @settlement_agent_id is not null             
   set @sql=@sql+' and m.expected_payoutagentid='''+@settlement_agent_id +''''                      
                        
 -- set @sql=@sql+')l'                      
  print @sql                      
                       
  exec(@sql)                      
                       
 end                      
                     
 --PMT NEPAL END                    
 --select * from #temp_current                      
 --select * from #temp_arch1                      
                     
                     
 END                    
 insert #temp(dot,remarks,DR,cr,comm,Settlement_Amount)                      
 select  dateadd(d,-1,@from_date),'Opening Balance',0,0,0,sum(Settlement_Amount) open_balance from(                      
 select Settlement_Amount from #temp_current                       
 union all                       
 select Settlement_Amount from #temp_arch1                       
 ) l                      
 --END OPENING BALACNE                    
                     
 if @flag='d'  -- DETAIL  REPORT                      
 begin                      
  set @sql='                      
  insert into #temp(Type,TranNo,DOT,Remarks,Dr,Cr,Comm,Settlement_Amount)                      
  select * from(                      
  SELECT ''Send'' Type, cast(TranNo as varchar) Tranno,confirmDate as DOT,dbo.decryptdb(refno)+'',''+senderName +'',''+receiverCountry ''Remarks'',                      
   '+                       
  case when @calc_currency='d' then ' dollar_amt '                      
   else ' paidAmt ' end +' ''DR'',0 ''CR'',round((isNUll(senderCommission,0)+isNUll(agent_ex_gain,0))/'+@send_fx_clm +','+@round_value+',1) as Comm,                      
  '+                      
  case when @calc_currency='d' then ' dollar_amt '                      
   else ' paidAmt ' end +'-round(((isNUll(senderCommission,0)+isNUll(agent_ex_gain,0))/'+@send_fx_clm +'),'+@round_value+',1) Settlement_Amount                      
  FROM MoneySend with (nolock) where transStatus in(''Payment'',''Cancel'',''Block'') and agentid='+ @agent_id +'                      
  and confirmDate between '''+ @from_date +''' and '''+@to_date+' 23:59:59.997'''                      
  if @branch_id is not null                      
   set @sql=@sql+' and branch_code='''+@branch_id +''''                      
  if @settlement_agent_id is not null                      
   set @sql=@sql+' and expected_payoutagentid='''+@settlement_agent_id +''''                      
                       
  set @sql=@sql+'                      
  UNION ALL                      
  SELECT ''Paid'', cast(TranNo as varchar),PaidDate,dbo.decryptdb(refno)+'',''+ receiverName +'',''+senderCountry ''Remarks'',0 ''DR'',                       
  round(totalRoundAmt/'+@paid_fx_clm+','+@round_value+',1) ''CR'',round(isNUll('+@rComm_clm+',0)/'+@paid_fx_clm+','+@round_value+',1) as Comm,                      
  round((totalRoundAmt/'+@paid_fx_clm                      
  if @calc_commission is null                       
   set @sql=@sql+' +isNUll('+@rComm_clm+',0)/'+@paid_fx_clm+''               
  set @sql=@sql+' )*-1,'+@round_value+',1) Settlement_Amount                      
  FROM   MoneySend m with (nolock)  join agentdetail sa WITH(NOLOCK) on sa.agentcode=m.agentid   where transStatus=''Payment'' and status in(''Paid'',''Post'')                      
  and paidDate between '''+ @from_date +''' and '''+@to_date+' 23:59:59.997'''                      
                       
  if @agent_type is null or @agent_type='a'                      
   set @sql=@sql+' and expected_payoutagentid='''+ @agent_id +''''                      
  if @agent_type='d'                      
   set @sql=@sql+' and receiveAgentID='''+ @agent_id +''''                      
                       
  if @branch_id is not null                      
   set @sql=@sql+' and rBankID='''+@branch_id +''''                      
  if @settlement_agent_id is not null                      
   set @sql=@sql+' and agentid='''+@settlement_agent_id +''''                      
                       
  set @sql=@sql+'                      
  UNION ALL                      
  SELECT case when mode=''cancel'' then ''CANCELLED'' else ''Fund'' end , cast(InvoiceNo as varchar), DOT,                        
  case when mode=''cancel'' then ''Cancel TRN '' else '''' end +'' ''+ isNULL(AgentBalance.remarks,'''') + '' - ''+                      
  case when mode=''receive'' or mode=''cr'' then '' ''+ isNULL(money_transfer.moneyTransfer,'''')                       
                      
   else isNULL(convert(varchar(50),AgentBalance.TRANNO),'''')+'' ''+ isNULL(money_transfer.moneyTransfer,'''')                       
   end           
 + case when a.agentType in(''Sender Agent'',''Send and Pay'') and mode not in (''cancel'') then                      
    '' $ ''+ isNUll(cast(Dollar_rate as varchar),''0'')  +'' @ ''+ltrim(isNUll(cast(str(xRate,10,4) as varchar),''0''))                      
    else '''' end                      
 as remarks,                      
  case when mode=''dr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' else 0 end DR,case when mode in(''Cr'',''Cancel'') then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' else 0 end CR,                      
  case when mode=''cancel'' then round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) * -1                      
  else  round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)  end as comm,                      
  case when mode=''dr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' '                      
                        
 if @calc_commission is null                       
   set @sql=@sql+' + round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)'                      
                       
  set @sql=@sql+'  else ('+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' '                       
  set @sql=@sql+' -(case when mode=''cancel'' then  round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) * -1                       
  else '                      
 if @calc_commission is null                       
  set @sql=@sql+' round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) '                      
 else                      
  set @sql=@sql+'0'                      
                       
 set @sql=@sql+' end * -1)'                       
                       
  set @sql=@sql+' ) * -1 end Settlement_Amount                 
                        
  FROM  AgentBalance with (nolock) left outer join money_transfer  WITH(NOLOCK)                      
  on AgentBalance.money_id=money_transfer.money_id                      
  join agentdetail a WITH(NOLOCK) on a.agentcode=AgentBalance.agentcode                      
  where mode not in (''FundPending'',''FundPendingDr'',''comdr'',''comcr'')  and approved_by is not null                      
  and AgentBalance.agentcode='+ @agent_id +'                      
  and dot between '''+ @from_date +''' and '''+@to_date+' 23:59:59.997'''         
  if @branch_id is not null                      
   set @sql=@sql+' and AgentBalance.branch_code='''+@branch_id +''''                      
  if @settlement_agent_id is not null                      
   set @sql=@sql+' and invoiceno in (                      
   select b.invoiceno from agentbalance b WITH(NOLOCK) join agentbalance b2 WITH(NOLOCK)                      
  on b.invoiceno=b2.invoiceno left outer join moneysend m WITH(NOLOCK)             
  on b2.tranno=m.tranno                      
  where  (b.agentcode='+ @settlement_agent_id +' or (m.expected_payoutagentid='+ @settlement_agent_id +' and b2.mode=''cancel''))                       
  and b2.agentcode='+ @agent_id +' and b.approved_by is not null                       
  and b.dot between '''+ @from_date +''' and '''+@to_date+' 23:59:59.997''                      
  )'                      
                       
                      
                       
  set @sql=@sql+') t order by t.dot'                      
 end                      
 else if @flag='s' ----------------- ################# Summary ###########-------------                      
 begin                      
  set @sql='                      
  insert into #temp(Type,TranNo,DOT,Remarks,Dr,Cr,Comm,Settlement_Amount)                      
  select * from(                      
                        
  SELECT ''Send'' Type, NULL Tranno,convert(varchar,confirmDate,102) as DOT,''Total TRN ''+ cast(count(*) as varchar) Remarks,                      
   sum('+               
  case when @calc_currency='d' then ' dollar_amt '                      
   else ' paidAmt ' end +') DR,0 CR,                      
  sum(round(isNUll(senderCommission/'+@send_fx_clm +',0)+isNUll(agent_ex_gain/'+@send_fx_clm +',0),'+@round_value+',1)) as Comm,                      
  sum('+                       
  case when @calc_currency='d' then ' dollar_amt '                      
   else ' paidAmt ' end +'-round(((isNUll(senderCommission,0)+isNUll(agent_ex_gain,0))/'+@send_fx_clm +'),'+@round_value+',1)) Settlement_Amount               
  FROM MoneySend with (nolock) where transStatus in(''Payment'',''Cancel'',''Block'') and agentid='+ @agent_id +'                      
  and confirmDate between '''+ @from_date +''' and '''+@to_date+' 23:59:59.997'''                      
                        
  if @branch_id is not null                      
   set @sql=@sql+' and branch_code='''+@branch_id +''''                      
  if @settlement_agent_id is not null                      
   set @sql=@sql+' and expected_payoutagentid='''+@settlement_agent_id +''''                      
                       
  set @sql=@sql+' group by convert(varchar,confirmDate,102)                      
  UNION ALL                      
  SELECT ''Paid'', NULL,convert(varchar,PaidDate,102),''Total TRN ''+ cast(count(*) as varchar) Remarks,0 DR,                      
  sum(round(totalRoundAmt/'+@paid_fx_clm +','+@round_value+',1)) CR,                      
  sum(round(isNUll('+@rComm_clm+'/'+@paid_fx_clm +',0),'+@round_value+',1)) as Comm,                      
  sum(round(((totalRoundAmt '                      
 if @calc_commission is null                       
  set @sql=@sql+'  +isNUll('+@rComm_clm+',0) '                      
                       
   set @sql=@sql+' )*-1)/'+@paid_fx_clm +','+@round_value+',1)) Settlement_Amount                      
  FROM   MoneySend  m with (nolock) join agentdetail sa WITH(NOLOCK) on sa.agentcode=m.agentid                         
  where transStatus=''Payment'' and status in(''Paid'',''Post'')                      
  and paidDate between '''+ @from_date +''' and '''+@to_date+' 23:59:59.997'''                     
                       
  if @agent_type is null or @agent_type='a'                      
   set @sql=@sql+' and expected_payoutagentid='''+ @agent_id +''''                      
  if @agent_type='d'                      
   set @sql=@sql+' and receiveAgentID='''+ @agent_id +''''                      
                       
  if @branch_id is not null                      
   set @sql=@sql+' and rBankID='''+@branch_id +''''                      
                       
  if @settlement_agent_id is not null                      
   set @sql=@sql+' and agentid='''+@settlement_agent_id +''''                      
                       
  set @sql=@sql+'                      
  group by convert(varchar,PaidDate,102)'                      
 -----------SEND FUND                      
 set @sql=@sql+' union all                       
 select ''Fund'', convert(varchar(50),b.InvoiceNo), b.DOT,                       
  isNULL(b.remarks,'''')                       
  + case when agentType in(''Sender Agent'',''Send and Pay'') and b.mode not in (''cancel'') then                      
  '' $ ''+ isNUll(cast(b.Dollar_rate as varchar),''0'')  +'' @ ''+ltrim(isNUll(cast(str(b.xRate,10,4) as varchar),''0''))                      
  else '''' end as remarks,                      
   case when mode=''dr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' else 0 end DR,                      
  case when mode in(''Cr'',''Cancel'') then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' else 0 end CR,                      
  case when mode=''cancel'' then round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) * -1                       
  else  round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)  end as comm,                      
  (case when mode=''dr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' '                       
 if @calc_commission is null                       
   set @sql=@sql+' +round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) '                      
                       
  set @sql=@sql+'  else ('+                       
  case when @calc_currency='d' then ' dollar_rate '      else ' amount ' end +' '                       
 if @calc_commission is null                       
  set @sql=@sql+' -(case when mode=''cancel'' then round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) * -1                       
  else round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) end  * -1) '                       
                        
 set @sql=@sql+' ) * -1 end ) Settlement_Amount                      
  from agentbalance b with (nolock) join agentdetail a WITH(NOLOCK) on a.agentcode=b.agentcode and a.agentType in(''Sender Agent'',''Send and Pay'')                       
  where mode in (''dr'',''cr'') and approved_by is not null  and money_id is null                      
  and   dot between '''+ @from_date +''' and '''+@to_date+' 23:59:59.997''                
  and b.agentcode ='''+@agent_id+''''                      
                 
 -----------Commission Money Transfer Table FUND                      
 set @sql=@sql+' union all                       
 select ''Fund'', NULL,convert(varchar,b.DOT,102),                       
  mt.MoneyTransfer +'':''+ cast(count(*) as varchar)                
   as remarks,                      
   sum(case when mode=''dr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' else 0 end) DR,                      
  sum(case when mode in(''Cr'') then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' else 0 end) CR,                      
  0 as comm,                      
  sum(case when mode=''dr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' '                       
                       
  set @sql=@sql+'  else ('+                       
  case when @calc_currency='d' then ' dollar_rate '      else ' amount ' end +' '                       
                     
 set @sql=@sql+' ) * -1 end ) Settlement_Amount                      
  from agentbalance b with (nolock) join agentdetail a WITH(NOLOCK)                
  on a.agentcode=b.agentcode                     
  join money_transfer mt WITH(NOLOCK) on mt.money_id=b.money_id                
  where mode in (''dr'',''cr'') and approved_by is not null  and b.money_id is not null                      
  and   b.dot between '''+ @from_date +''' and '''+@to_date+' 23:59:59.997''                       
  and b.agentcode ='''+@agent_id+'''                      
  group by convert(varchar,b.DOT,102),mt.MoneyTransfer,mode '                 
 ---- CANCEL TRN                      
 set @sql=@sql+'                      
 union all                       
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
   else ' amount ' end +'-round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1))  * -1 end ) Settlement_Amount                      
  FROM  AgentBalance b with (nolock)  left outer join moneysend m WITH(NOLOCK)                      
  on b.tranno=m.tranno                       
  where b.mode=''cancel'' and b.approved_by is not null                      
  and b.dot between '''+ @from_date +''' and '''+@to_date+' 23:59:59.997''  and b.agentcode='+ @agent_id                       
  if @branch_id is not null                     
   set @sql=@sql+' and b.branch_code='''+@branch_id +''''                      
  if @settlement_agent_id is not null                      
   set @sql=@sql+' and m.expected_payoutagentid='''+@settlement_agent_id +''''                      
                       
 -- COMMSSION SUMMARY                      
 if @headoffice_commission_id=@agent_id                      
 begin                      
 set @sql=@sql+'                      
 union all                       
 SELECT ''Commission'' , NULL ,convert(varchar,DOT,102) DOT,                        
 ''Commission: '' +upper(mode)+'' '' + cast(count(*) as varchar) as remarks,                      
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
  FROM  AgentBalance b  with (nolock)                      
  where mode in (''dr'',''cr'')  and approved_by is not null and b.money_id is null                   
  and dot between '''+ @from_date +''' and '''+ @to_date +' 23:59:59.997''                        
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
  isNULL(b.remarks,'''')                       
  as remarks,                      
  case when b.mode=''dr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' else 0 end DR,                      
  case when b.mode =''Cr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' else 0 end CR,'                      
 if @calc_commission is null                       
  set @sql=@sql+' round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)'                      
 ELSE                      
  set @sql=@sql+' 0 '                      
  set @sql=@sql+' as comm,                      
  (case when b.mode=''dr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +''                      
 if @calc_commission is null                       
 set @sql=@sql+' +round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)  '                       
                       
 set @sql=@sql+' else ('+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' '                         
 if @calc_commission is null                       
 set @sql=@sql+'-(round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) * -1) '                      
 set @sql=@sql+' ) * -1 end) Settlement_Amount                      
  FROM  AgentBalance b with (nolock) join agentdetail a WITH(NOLOCK)                      
  on a.agentcode=b.agentcode and a.agentType not in (''Sender Agent'',''Send and Pay'')                      
  where mode in (''dr'',''cr'') and approved_by is not null and b.money_id is null                        
  --and invoiceno not like (''l%'')                      
  and b.agentcode <> '''+ @headoffice_commission_id +'''                      
  and  b.dot between '''+ @from_date +''' and '''+ @to_date +' 23:59:59.997''                      
  and b.agentcode='''+@agent_id +''''                      
  if @branch_id is not null                      
   set @sql=@sql+' and b.branch_code='''+@branch_id +''''                      
                       
 if exists (select top 1 * from close_transaction WITH(NOLOCK) where close_date >= @from_date)                      
 begin                      
                       
  -----################## ARCH1 Summary #####################                      
  set @sql=@sql+' SELECT ''Send'' Type, NULL Tranno,convert(varchar,confirmDate,102) as DOT,''Total TRN ''+ cast(count(*) as varchar) Remarks,                      
   sum('+                       
  case when @calc_currency='d' then ' dollar_amt '                      
   else ' paidAmt ' end +') DR,0 CR,                      
  sum(round(isNUll(senderCommission/'+@send_fx_clm +',0)+isNUll(agent_ex_gain/'+@send_fx_clm +',0),'+@round_value+',1)) as Comm,                      
  sum('+                       
  case when @calc_currency='d' then ' dollar_amt '                      
   else ' paidAmt ' end +'-round(((isNUll(senderCommission,0)+isNUll(agent_ex_gain,0))/'+@send_fx_clm +'),'+@round_value+',1)) Settlement_Amount                      
  FROM MoneySend_arch1 with (nolock)  where transStatus in(''Payment'',''Cancel'',''Block'') and agentid='+ @agent_id +'                      
  and confirmDate between '''+ @from_date +''' and '''+@to_date+' 23:59:59.997'''                      
                       
  if @branch_id is not null                      
   set @sql=@sql+' and branch_code='''+@branch_id +''''                      
  if @settlement_agent_id is not null                      
   set @sql=@sql+' and expected_payoutagentid='''+@settlement_agent_id +''''              
                       
  set @sql=@sql+' group by convert(varchar,confirmDate,102)                      
  UNION ALL                      
  SELECT ''Paid'', NULL,convert(varchar,PaidDate,102),''Total TRN ''+ cast(count(*) as varchar) Remarks,0 DR,                      
  sum(round(totalRoundAmt/'+@paid_fx_clm +'),'+@round_value+',1) CR,                      
  sum(round(isNUll('+@rComm_clm+'/'+@paid_fx_clm +',0)),'+@round_value+',1) as Comm,                      
  sum(round(((totalRoundAmt '                      
 if @calc_commission is null                       
  set @sql=@sql+'  +isNUll('+@rComm_clm+',0) '                      
                       
   set @sql=@sql+' )*-1)/'+@paid_fx_clm +'),'+@round_value+',1) Settlement_Amount                      
  FROM   MoneySend_arch1 m with (nolock)  join agentdetail sa WITH(NOLOCK) on sa.agentcode=m.agentid                        
  where transStatus=''Payment'' and status in(''Paid'',''Post'')                      
  and paidDate between '''+ @from_date +''' and '''+@to_date+' 23:59:59.997'''                      
                       
  if @agent_type is null or @agent_type='a'                      
   set @sql=@sql+' and expected_payoutagentid='''+ @agent_id +''''                      
  if @agent_type='d'                      
   set @sql=@sql+' and receiveAgentID='''+ @agent_id +''''                      
                       
  if @branch_id is not null                      
   set @sql=@sql+' and rBankID='''+@branch_id +''''                      
                       
  if @settlement_agent_id is not null                      
   set @sql=@sql+' and agentid='''+@settlement_agent_id +''''                      
                       
  set @sql=@sql+'                      
  group by convert(varchar,PaidDate,102)'                      
 -----------SEND FUND                      
 set @sql=@sql+' union all                       
 select ''Fund'', convert(varchar(50),b.InvoiceNo), b.DOT,                       
  isNULL(b.remarks,'''')                       
  + case when agentType in(''Sender Agent'',''Send and Pay'') and b.mode not in (''cancel'') then                      
  '' $ ''+ isNUll(cast(b.Dollar_rate as varchar),''0'')  +'' @ ''+ltrim(isNUll(cast(str(b.xRate,10,4) as varchar),''0''))                      
  else '''' end as remarks,                      
   case when mode=''dr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' else 0 end DR,                      
  case when mode in(''Cr'',''Cancel'') then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' else 0 end CR,                      
  case when mode=''cancel'' then round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) * -1                       
  else  round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)  end as comm,                      
  (case when mode=''dr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' '                       
 if @calc_commission is null                       
   set @sql=@sql+' +round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) '                      
                       
  set @sql=@sql+'  else ('+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' '                       
 if @calc_commission is null                       
  set @sql=@sql+' -(case when mode=''cancel'' then round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) * -1                       
  else round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) end  * -1) '                       
                        
 set @sql=@sql+' ) * -1 end ) Settlement_Amount                      
  from agentbalance_arch1 b with (nolock)  join agentdetail a WITH(NOLOCK) on a.agentcode=b.agentcode and a.agentType in(''Sender Agent'',''Send and Pay'')                       
  where mode in (''dr'',''cr'') and approved_by is not null                       
  and   dot between '''+ @from_date +''' and '''+@to_date+' 23:59:59.997''                       
  and b.agentcode ='''+@agent_id+''''                      
                       
 ---- CANCEL TRN                      
 set @sql=@sql+'                      
 union all                       
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
   else ' amount ' end +'-round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1))  * -1 end ) Settlement_Amount                      
  FROM  agentbalance_arch1 b with (nolock)  left outer join moneysend_arch1 m with (nolock)                      
  on b.tranno=m.tranno                       
  where b.mode=''cancel'' and b.approved_by is not null                      
  and b.dot between '''+ @from_date +''' and '''+@to_date+' 23:59:59.997''  and b.agentcode='+ @agent_id                       
  if @branch_id is not null                      
   set @sql=@sql+' and b.branch_code='''+@branch_id +''''                      
  if @settlement_agent_id is not null                      
   set @sql=@sql+' and m.expected_payoutagentid='''+@settlement_agent_id +''''                      
                       
 -- COMMSSION SUMMARY                      
 if @headoffice_commission_id=@agent_id                      
                       
 begin                      
 set @sql=@sql+'                      
 union all                       
 SELECT ''Commission'' , NULL ,convert(varchar,DOT,102) DOT,                        
 ''Commission: '' +upper(mode)+'' '' + cast(count(*) as varchar) as remarks,                      
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
  FROM  agentbalance_arch1 b WITH(NOLOCK)                       
  where mode in (''dr'',''cr'')  and approved_by is not null                      
  and dot between '''+ @from_date +''' and '''+ @to_date +' 23:59:59.997''                        
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
  isNULL(b.remarks,'''')                       
  as remarks,                      
  case when b.mode=''dr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '              
   else ' amount ' end +' else 0 end DR,                      
  case when b.mode =''Cr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' else 0 end CR,'                      
 if @calc_commission is null                       
  set @sql=@sql+' round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)'                      
 ELSE                      
  set @sql=@sql+' 0 '                      
  set @sql=@sql+' as comm,                      
  (case when b.mode=''dr'' then '+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +''                      
 if @calc_commission is null                       
 set @sql=@sql+' +round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1)  '                       
                       
 set @sql=@sql+' else ('+                       
  case when @calc_currency='d' then ' dollar_rate '                      
   else ' amount ' end +' '                         
 if @calc_commission is null                       
 set @sql=@sql+'-(round(isNUll(other_commission,0)/'+@balance_fx_clm+','+@round_value+',1) * -1) '                      
 set @sql=@sql+' ) * -1 end) Settlement_Amount                      
  FROM  agentbalance_arch1 b WITH(NOLOCK) join agentdetail a  WITH(NOLOCK)                     
  on a.agentcode=b.agentcode and a.agentType not in (''Sender Agent'',''Send and Pay'')                      
  where mode in (''dr'',''cr'') and approved_by is not null                      
  --and invoiceno not like (''l%'')                      
  and b.agentcode <> '''+ @headoffice_commission_id +'''                      
  and  b.dot between '''+ @from_date +''' and '''+ @to_date +' 23:59:59.997''                      
  and b.agentcode='''+@agent_id +''''                      
  if @branch_id is not null                      
   set @sql=@sql+' and b.branch_code='''+@branch_id +''''                      
 --- ############### Arch1 END                      
 end -------- CHECK  Close date end                      
  set @sql=@sql+') t order by t.dot'                      
 end                      
  print(@sql)                      
  exec(@sql)                      
                       
                       
 set @sql='insert into '+ @ledger_tabl +'(Type,TranNo,DOT,Remarks,Dr,Cr,Comm,Settlement_Amount,Balance,Currency)                      
 select Type,TranNo,DOT,Remarks, Dr ,Cr   ,Comm ,                      
 Settlement_Amount  as Settlement_Amount,(select sum(Settlement_Amount) from #temp                      
 where sno<= t.sno) Balance,'''+ @curr_type +''' Currency from #temp t'                      
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
                       
 set @url_desc='fromDate='+@from_date+'&toDate='+@to_date+'&agent_type='+@agent_type                       
 +'&agent_detail_text='+ @agent_name                      
 if @calc_currency is not null                      
 set @url_desc=@url_desc+'&currType='+ @calc_currency                      
 if @branch_name is not null                      
  set @url_desc=@url_desc +'&branch_detail_text=('+ [dbo].FNATrimAND(@branch_name)+')'                      
 set @url_desc=@url_desc +'&agentcode='+@agent_id+'&agent_branch_id='+isNull(@branch_id,'')                      
 set @url_desc=@url_desc +'&receive_agent_id='+isNull(@settlement_agent_id,'')                      
 set @url_desc=@url_desc +'&ReportType='+isNull(@flag,'')                      
                       
                       
  set @desc ='SOA '+ @msg_agenttype +' is completed'                           
  EXEC  spa_message_board 'u', @login_user_id,                      
  NULL, @batch_id,                      
  @desc, 'c', @process_id,null,@url_desc                      
  end 