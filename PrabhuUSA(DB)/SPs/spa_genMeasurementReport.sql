/****** Object:  StoredProcedure [dbo].[spa_genMeasurementReport]    Script Date: 08/01/2014 15:10:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- spa_genMeasurementReport 's','10500000',NULL,'4/1/2008','8/14/2008',NULL,'y','d','l',1,NULL
-- spa_LedgerReport 's','10100000',NULL,'4/1/2008','5/30/2008','-1','y','a','l',1,'y'
-- spa_genMeasurementReport 's',NULL,'19500200','2008-04-01','2008-08-14',NULL,'y' ,'b',NULL,1 ,'n'
-- spa_LedgerReport 's',NULL,'19500200','2008-04-01','2008-05-30',NULL,'y' ,'b',NULL,1 ,'y'
-- spa_LedgerReport 'd',NULL,'19500200','2007-06-01','2007-06-10',NULL,'y','b'
-- spa_LedgerReport 's','41000100',NULL,'2007-11-29','2007-12-21',NULL,'y','a','l',64 46989021.0000

-- spa_LedgerReport 's',NULL,'19500200','12/04/2007','12/6/2007',NULL,'y','b',NULL,1 ,'y'
ALTER proc [dbo].[spa_genMeasurementReport]
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
@calc_commission char(1)=null --NULL Means calc commission

as

-----TESTING Script
--declare @flag char(1),
--@agent_id varchar(50),
--@branch_id varchar(50),
--@from_date varchar(20),
--@to_date varchar(20),
--@settlement_agent_id varchar(50),
--@calc_opening_balance char(1),
--@agent_type char(1), -- NULL/a MAIN AGENT TYPE , b= Branch Type , d Bank or Deposit type
--@calc_currency char(1), -- l = Local CUrrency , d - USD
--@usd_rate money,
--@calc_commission char(1),
--@process_id varchar(200),
--@login_user_id varchar(50)
--set @flag='s'
--set @agent_id='10100000'
--set @from_date='6/1/2008'
--set @to_date='8/14/2008'
----set @settlement_agent_id='-1'
--set @calc_opening_balance='y'
--set @agent_type='a'
--set @calc_currency='l'
--
--drop table #temp
--drop table #ledger_curr

---End Testing
declare @sql varchar(8000),@rComm_clm varchar(500),
@expected_payoutagentid varchar(50),
@curr_type varchar(20),
@v_settlement varchar(50),
@v_dr varchar(50),
@v_cr varchar(50),
@v_comm varchar(20)

if @branch_id is not null
begin
	select @agent_id=agentcode,@expected_payoutagentid=agent_code_id 
	from agentbranchdetail where agent_branch_code=@branch_id
	set @v_comm='branch_comm'
	set @v_settlement='branch_settlement'
	set @rComm_clm='receiverCommission'
end
else
begin
	
	if @agent_type in('b','d')
	begin
		set @v_comm='branch_comm'
		set @v_settlement='branch_settlement'
		set @rComm_clm='receiverCommission'
	end
	else
	begin
		set @v_comm='comm'
		set @v_settlement='Settlement_Amount'
		set @rComm_clm=' case when isNull(agent_receiverComm_Currency,''l'')=''l'' then agent_receiverCommission else agent_receiverCommission*isNull(paid_date_usd_rate,exchangeRate * agent_settlement_rate) end 
+ agent_receiverSCommission*agent_settlement_rate'
	end
end

declare @send_fx_clm varchar(50),@paid_fx_clm varchar(50),@balance_fx_clm varchar(50)

if @calc_currency='l' or @calc_currency is null
begin
	select @curr_type=currencyType  from agentdetail where agentcode=@agent_id
	set @v_dr='Dr'
	set @v_cr='Cr'
	
	set @send_fx_clm='1'
	set @paid_fx_clm='1'
	set @balance_fx_clm='1'

end
else
begin
	set @curr_type='USD'
	set @v_dr='USD_Dr'
	set @v_cr='USD_Cr'
	set @v_settlement='USD_Settlement'
	set @v_comm='USD_comm'


	set @send_fx_clm='ExchangeRate'
	set @paid_fx_clm='isNull(paid_date_usd_rate,exchangeRate * agent_settlement_rate)'
	set @balance_fx_clm='xRate'
end

if @calc_commission is not null 
begin
	set @v_comm='0'
	set @rComm_clm=0
	if @branch_id is not null
		set @v_settlement='branch_settlement_no_comm'
end

	if @agent_type ='d'
	begin
		
		set @v_settlement='branch_settlement_no_comm'
		set @rComm_clm='receiverCommission'
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

declare @ledger_table varchar(3000)
DECLARE @current_date datetime

--set @ledger_table='iremit_process.dbo.ledger_measurement_report'
set @ledger_table=dbo.FNAProcessLedgerTbl()
if @calc_opening_balance='y' 
begin
	--GET OPENING BALANCE
	set @sql='
	insert #temp(dot,remarks,DR,cr,comm,Settlement_Amount)
	select  dateadd(d,-1,'''+@from_date+'''),''Opening Balance'',0,0,0, sum(Settlement_Amount) open_balance 
	from(
	SELECT isNull(sum('+ @v_settlement +'),0) Settlement_Amount
	FROM '+ @ledger_table +' 
	where '
	if @branch_id is not null
		set @sql=@sql + ' (agentid='+ @agent_id +' or agentid='+@expected_payoutagentid+')'
	ELSE IF @agent_type ='d'
		set @sql=@sql + ' (agentid='+ @agent_id +' or expected_payoutagentid='+@agent_id+')'
	else
		set @sql=@sql + ' agentid='+ @agent_id +''
	set @sql=@sql + ' and dot < '''+ @from_date +''''
	if @branch_id is not null
		set @sql=@sql+' and branch_id='''+@branch_id +''''
	if @settlement_agent_id is not null
		set @sql=@sql+' and expected_payoutagentid='''+@settlement_agent_id +''''	
	set @sql=@sql+')l'
	print @sql
	exec(@sql)

	--END OPENING BALACNE
end

	set @sql='
	insert into #temp(Type,TranNo,DOT,Remarks,Dr,Cr,Comm,Settlement_Amount)
	select * from(
	SELECT  Type, Tranno, DOT,Remarks,'+ @v_dr +','+ @v_Cr +',
	'+ @v_Comm +' Commission,
	'+ @v_settlement +' Settlement_Amount
	FROM '+ @ledger_table +' 
	where '
	if @branch_id is not NULL 
		set @sql=@sql + ' (agentid='+ @agent_id +' or agentid='+@expected_payoutagentid+')'
	ELSE IF @agent_type ='d'
		set @sql=@sql + ' (agentid='+ @agent_id +' or expected_payoutagentid='+@agent_id+')'
	else
		set @sql=@sql + ' agentid='+ @agent_id +''
	set @sql=@sql + ' and dot between '''+ @from_date +''' and '''+@to_date+' 23:59:59'''
	if @branch_id is not null
		set @sql=@sql+' and branch_id='''+@branch_id +''''
	if @settlement_agent_id is not null
		set @sql=@sql+' and expected_payoutagentid='''+@settlement_agent_id +''''
	set @sql=@sql+') t order by t.dot'

	print(@sql)
	exec(@sql)

--- Check for Current DATE
set @current_date=convert(varchar,dbo.getDateHO(getutcdate()),101)
IF CAST(@to_date AS DATETIME)>=@current_date
begin 
CREATE TABLE [#ledger_curr] (
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

set @from_date=@to_date
---Create Temp Send mode
delete #temp where dot between @from_date and @to_date +' 23:59:59'
set @sql='
	
	insert into #ledger_curr(Type,TranNo,DOT,Remarks,Dr,Cr,Comm,Settlement_Amount)
	SELECT ''Send'' Type, NULL Tranno,convert(varchar,confirmDate,102) as DOT,
	''Total TRN ''+ cast(count(*) as varchar) Remarks,
	sum(
	'+ 
	case when @calc_currency='d' then ' dollar_amt '
		else ' paidAmt ' end +'
	) DR,0 CR,
	sum((isNUll(senderCommission,0)+isNUll(agent_ex_gain,0))/'+@send_fx_clm+') as Comm,
	sum(('+ 
	case when @calc_currency='d' then ' dollar_amt '
		else ' paidAmt ' end +'-(isNUll(senderCommission,0)+isNUll(agent_ex_gain,0))/'+@send_fx_clm+')) Settlement_Amount
	FROM MoneySend where transStatus in(''Payment'',''Cancel'',''Block'') 
	and agentid='''+@agent_id +'''
	and confirmDate between '''+ @from_date +''' and '''+ @to_date +' 23:59:59'''
	if @branch_id is not null
		set @sql=@sql+' and branch_code='''+@branch_id +''''
	if @settlement_agent_id is not null
		set @sql=@sql+' and expected_payoutagentid='''+@settlement_agent_id +''''
	set @sql=@sql+' group by convert(varchar,confirmDate,102)'
exec(@sql)

---Create Temp Paid mode
set @sql='
	
	insert into #ledger_curr(Type,TranNo,DOT,Remarks,Dr,Cr,Comm,Settlement_Amount)
	SELECT ''Paid'', NULL,convert(varchar,PaidDate,102),''Total TRN ''+ cast(count(*) as varchar) Remarks,0 DR,
	sum(totalRoundAmt/'+@paid_fx_clm+') CR,sum(isNUll('+@rComm_clm+',0)/'+@paid_fx_clm+') as Comm,
	sum(((totalRoundAmt '
if @calc_commission is null 
	set @sql=@sql+'  +isNUll('+@rComm_clm+',0) '

	 set @sql=@sql+' )*-1)/'+@paid_fx_clm+') Settlement_Amount
	FROM   MoneySend  where transStatus=''Payment'' and status in(''Paid'',''Post'')
	and paidDate between '''+ @from_date +''' and '''+@to_date+' 23:59:59'''

	if @agent_type is null or @agent_type='a'
		set @sql=@sql+' and expected_payoutagentid='''+ @agent_id +''''
	if @agent_type='d'
		set @sql=@sql+' and receiveAgentID='''+ @agent_id +''''

	if @branch_id is not null
		set @sql=@sql+' and rBankID='''+@branch_id +''''

	if @settlement_agent_id is not null
		set @sql=@sql+' and agentid='''+@settlement_agent_id +''''

	set @sql=@sql+'	group by convert(varchar,PaidDate,102)'

exec(@sql)

-- FUND Sending agent
set @sql='
	
	insert into #ledger_curr(Type,TranNo,DOT,Remarks,Dr,Cr,Comm,Settlement_Amount)
	SELECT case when mode=''cancel'' then ''CANCELLED'' else ''Fund'' end , 
	convert(varchar(50),InvoiceNo), DOT,  
	case when mode=''cancel'' then ''Cancel TRN '' else '''' end +'' ''+ isNULL(AgentBalance.remarks,'''') 
	+ case when a.agentType in(''Sender Agent'',''Send and Pay'') and mode not in (''cancel'') then
	'' $ ''+ isNUll(cast(Dollar_rate as varchar),''0'')  +'' @ ''+ltrim(isNUll(cast(str(xRate,10,4) as varchar),''0''))
	else '''' end as remarks,
	case when mode=''dr'' then '+ 
	case when @calc_currency='d' then ' dollar_rate '
		else ' amount ' end +' else 0 end DR,
	case when mode in(''Cr'',''Cancel'') then '+ 
	case when @calc_currency='d' then ' dollar_rate '
		else ' amount ' end +' else 0 end CR,
	round((case when mode=''cancel'' then other_commission * -1 
	else  isNull(other_commission,0)  end)/'+@balance_fx_clm+',2,1) as comm,
	(case when mode=''dr'' then '+ 
		case when @calc_currency='d' then ' dollar_rate '
		else ' amount ' end 

if @calc_commission is null 
		set @sql=@sql+' + round(isNUll(other_commission,0)/'+@balance_fx_clm +',2,1) '

	set @sql=@sql+'  else ('+ 
		case when @calc_currency='d' then ' dollar_rate '
		else ' amount ' end 

	set @sql=@sql+' -(case when mode=''cancel'' then (round(isNUll(other_commission,0)/'+@balance_fx_clm+',2,1)) * -1 
	else round(isNUll(other_commission,0)/'+@balance_fx_clm+',2,1) end  * -1) ' 
	set @sql=@sql+' ) * -1 end) Settlement_Amount
	
	FROM  AgentBalance left 
	join agentdetail a on a.agentcode=AgentBalance.agentcode
	where approved_by is not null
	and AgentBalance.agentcode='+ @agent_id +'  and invoiceno not like ''l:%''
	and isNull(AgentBalance.remarks,'''') not like (''Commission Gain:%'') 
	and dot between '''+ @from_date +''' and '''+@to_date+' 23:59:59'''

	if @branch_id is not null
		set @sql=@sql+' and AgentBalance.branch_code='''+@branch_id +''''
	
	if @settlement_agent_id is not null
		set @sql=@sql+' and invoiceno in (
		select b.invoiceno from agentbalance b join agentbalance b2
	on b.invoiceno=b2.invoiceno left outer join moneysend m
	on b2.tranno=m.tranno
	where  (b.agentcode='+ @settlement_agent_id +' or (m.expected_payoutagentid='+ @settlement_agent_id +' and b2.mode=''cancel'')) 
	and b2.agentcode='+ @agent_id +' and b.approved_by is not null 
	and b.dot between '''+ @from_date +''' and '''+@to_date+' 23:59:59''
	)'
---Local 
set @sql=@sql+'
union all 
SELECT case when mode=''cancel'' then ''CANCELLED'' else ''Local'' end , NULL ,convert(varchar,DOT,102) DOT,  
case when mode=''cancel'' then ''Cancel TRN '' + max(remarks) else ''Local: '' +upper(mode)+'' '' + cast(count(*) as varchar) end 
as remarks,
	case when mode=''dr'' then Sum('+ 
		case when @calc_currency='d' then ' dollar_rate '
		else ' amount ' end +') else 0 end DR,
	case when mode in(''Cr'',''Cancel'') then Sum('+ 
		case when @calc_currency='d' then ' dollar_rate '
		else ' amount ' end +') else 0 end CR,
	case when mode=''cancel'' then Sum(round(other_commission/'+@balance_fx_clm+',2,1)) * -1 
	else  isNull(Sum(round(other_commission/'+@balance_fx_clm+',2,1)),0)  end as comm,
	case when mode=''dr'' then Sum('+ 
		case when @calc_currency='d' then ' dollar_rate '
		else ' amount ' end +')   else (Sum('+ 
		case when @calc_currency='d' then ' dollar_rate '
		else ' amount ' end +')  ) * -1 end Settlement_Amount
	
	FROM  AgentBalance 
	where approved_by is not null
		and AgentBalance.agentcode='+ @agent_id +' and invoiceno like ''l:%''
	and dot between '''+ @from_date +''' and '''+@to_date+' 23:59:59'''

	if @branch_id is not null
		set @sql=@sql+' and AgentBalance.branch_code='''+@branch_id +''''
	
	if @settlement_agent_id is not null
		set @sql=@sql+' and invoiceno in (
		select b.invoiceno from agentbalance b join agentbalance b2
	on b.invoiceno=b2.invoiceno left outer join moneysend m
	on b2.tranno=m.tranno
	where  (b.agentcode='+ @settlement_agent_id +' or (m.expected_payoutagentid='+ @settlement_agent_id +' and b2.mode=''cancel'')) 
	and b2.agentcode='+ @agent_id +' and b.approved_by is not null 
	and b.dot between '''+ @from_date +''' and '''+@to_date+' 23:59:59''
	)'
	set @sql=@sql+' group by convert(varchar,DOT,102),mode '
-- COMMSSION SUMMARY
set @sql=@sql+'
union all 
SELECT case when mode=''cancel'' then ''CANCELLED'' else ''Commission'' end , NULL ,convert(varchar,DOT,102) DOT,  
case when mode=''cancel'' then ''Cancel TRN '' + max(AgentBalance.remarks) else ''Commission: '' +upper(mode)+'' '' + cast(count(*) as varchar) end 
as remarks,
	case when mode=''dr'' then Sum('+ 
		case when @calc_currency='d' then ' dollar_rate '
		else ' amount ' end +') else 0 end DR,
	case when mode in(''Cr'',''Cancel'') then Sum('+ 
		case when @calc_currency='d' then ' dollar_rate '
		else ' amount ' end +') else 0 end CR,
	case when mode=''cancel'' then Sum(round(other_commission/'+@balance_fx_clm+',2,1)) * -1 
	else  isNull(Sum(round(other_commission/'+@balance_fx_clm+',2,1)),0)  end as comm,
	case when mode=''dr'' then Sum('+ 
		case when @calc_currency='d' then ' dollar_rate '
		else ' amount ' end +')   else (Sum('+ 
		case when @calc_currency='d' then ' dollar_rate '
		else ' amount ' end +')  ) * -1 end Settlement_Amount
	
	FROM  AgentBalance 
	where approved_by is not null
		and AgentBalance.agentcode='+ @agent_id +' and isNull(AgentBalance.remarks,'''') like ''Commission Gain:%''
	and dot between '''+ @from_date +''' and '''+@to_date+' 23:59:59'''

	if @branch_id is not null
		set @sql=@sql+' and AgentBalance.branch_code='''+@branch_id +''''
	
	if @settlement_agent_id is not null
		set @sql=@sql+' and invoiceno in (
			select b.invoiceno from agentbalance b join agentbalance b2
	on b.invoiceno=b2.invoiceno left outer join moneysend m
	on b2.tranno=m.tranno
	where  (b.agentcode='+ @settlement_agent_id +' or (m.expected_payoutagentid='+ @settlement_agent_id +' and b2.mode=''cancel'')) 
	and b2.agentcode='+ @agent_id +' and b.approved_by is not null 
	and b.dot between '''+ @from_date +''' and '''+@to_date+' 23:59:59''
	)'

	set @sql=@sql+' group by convert(varchar,DOT,102),mode '
print 'Funding..'
print @sql
exec(@sql)
insert into #temp(Type,TranNo,DOT,Remarks,Dr,Cr,Comm,Settlement_Amount)
select Type,TranNo,DOT,Remarks,Dr,Cr,Comm,Settlement_Amount from #ledger_curr order by dot
end 

---Current Date end

--
--
--if @process_id is not null
--begin
--declare @temptablename varchar(200)
--	set @temptablename=dbo.FNAProcessTBl('batch_ledger', @login_user_id, @process_id)
--	set @sql='create table '+@temptablename+'(
--		Type varchar(150),
--		TranNo varchar(150),
--		DOT varchar(50),
--		Remarks varchar(500),
--		Dr Money,
--		CR Money,
--		Comm money,
--		Settlement_Amount money,
--		Balance money,
--		Currency varchar(50)
--		)'
--		exec(@sql)
--
--		set @sql='insert '+@temptablename+'(Type,TranNo,DOT,Remarks,Dr,Cr,Comm,Settlement_Amount,Balance,Currency)
--		select Type,TranNo,DOT,Remarks, Dr  as DR,Cr  as Cr ,Comm  as Comm,
--		Settlement_Amount  as Settlement_Amount,(select sum(Settlement_Amount) from #temp
--		where sno<= t.sno)  Balance,'''+ @curr_type +''' Currency
--		from #temp t
--		'
--		print (@sql)
--		exec(@sql)
--end
--else
--begin
	select Type,TranNo,DOT,Remarks, Dr  as DR,Cr  as Cr ,Comm  as Comm,
	Settlement_Amount  as Settlement_Amount,(select sum(Settlement_Amount) from #temp
	where sno<= t.sno)  Balance,@curr_type Currency
	from #temp t
--end



