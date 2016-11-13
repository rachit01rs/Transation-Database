      
--set ANSI_NULLS ON      
--set QUOTED_IDENTIFIER ON      
--go      
--      
--spa_deposit_ledger_summary_all_job '10100000',NULL,'11/13/2008',NULL,'klanoop','d'      
------- ##########NEW SYSTEM ################      
DROP PROC spa_deposit_ledger_summary_all
Go
--set ANSI_NULLS ON  
--set QUOTED_IDENTIFIER ON  
--go  
--  
--spa_deposit_ledger_summary_all_job '10100000',NULL,'11/13/2008',NULL,'klanoop','d'  
------- ##########NEW SYSTEM ################  
CREATE proc.[dbo].[spa_deposit_ledger_summary_all]  
@agentId varchar(50),  
@deposit_id varchar(50),  
@from_date varchar(20),  
@branch_code varchar(50)=NULL,  
@login_user_id varchar(50)=NULL,  
@process_id varchar(150)=NULL,  
@deposit_type varchar(10)=null  
  
as  
DECLARE @to_date varchar(20)  
  
------- FOR TEST  
--declare @agentId varchar(50),@deposit_id varchar(50),@from_date varchar(20),@to_date varchar(20),  
--@branch_code varchar(50),@flag char(1),@process_id varchar(150),@login_user_id varchar(50)  
--set @flag='d'  
----set @show_open_balance='y'  
--set @agentId='10100000'  
----set @deposit_id='8004'  
--set @from_date='2008-6-13'  
--set @to_date='2008-11-13'  
--drop table #temp  
--drop table #temp_balance  
--SET @process_id='123'  
--SET @login_user_id='Anoop'  
--DROP TABLE iremit_process.dbo.Deposit_Summary_Anoop_123  
--------End TEst  
  
SET @to_date=@from_date  
  
CREATE TABLE [#temp] (  
 [sno] int identity(1,1) ,  
 open_balance money NULL ,  
 SendTRN money NULL ,  
 PNDSND Money NULL,  
 Deposit Money  NULL ,  
 PendingTrans [money] NULL ,  
 Transfered [money] NULL ,  
 Cancel [money] NULL ,  
 [Settlement_Amount] [money] NULL,  
 Bank_code int   
) ON [PRIMARY]  
  
CREATE TABLE [#temp_balance] (  
 [sno] int identity(1,1) ,  
 type varchar(100),  
 SendTRN money NULL ,  
 PNDSND Money NULL,  
 Deposit Money  NULL ,  
 PendingTrans [money] NULL ,  
 Transfered [money] NULL ,  
 Cancel [money] NULL ,  
 [Settlement_Amount] [money] NULL,  
 Bank_code int    
) ON [PRIMARY]  
  
---- ############## calc Open Balance  
declare @sql varchar(5000),@sql_sub varchar(5000),@start_date varchar(20)  
set @start_date='2007-12-08'  
  
  
  
 -------Send Trans  
 set @sql_sub='insert #temp_balance([Type],Bank_code,[Settlement_Amount])   
    select ''Send Trans'',d.BankCode,  
    sum(case when SenderBankId is null then d.amtPaid else paidAmt end) Amt  
    from MoneySend m left outer join deposit_detail d  
    on m.tranno=d.tranno  
    where  convert(varchar,d.depositDOT,102)=convert(varchar,m.local_dot,102) and pending_id is null    
    and agentid='+@agentId +'  
    and d.depositDOT < '''+ @from_date +''''  
    if @branch_code is not null   
     set @sql_sub=@sql_sub+' and m.branch_code='''+@branch_code +''''  
    if @deposit_id is not null   
     set @sql_sub=@sql_sub+' and d.BankCode='''+@deposit_id +''''  
      
    set @sql_sub=@sql_sub+' group by d.BankCode'  
  
 print(@sql_sub)  
 exec(@sql_sub)  
 ---###arch1  
 --if exists(select top 1 table_name from close_transaction where close_date <= @to_date)  
 begin  
  set @sql_sub='insert #temp_balance([Type],bank_code,[Settlement_Amount])   
     select ''Send Trans'',d.BankCode,  
     sum(case when SenderBankId is null then d.amtPaid else paidAmt end) Amt  
     from MoneySend_arch1 m left outer join deposit_detail_arch1 d  
     on m.tranno=d.tranno  
     where   convert(varchar,d.depositDOT,102)=convert(varchar,m.local_dot,102) and pending_id is null    
    and  agentid='+@agentId +'   
     and d.depositDOT < '''+ @from_date +''''  
     if @branch_code is not null   
      set @sql_sub=@sql_sub+' and m.branch_code='''+@branch_code +''''  
    if @deposit_id is not null   
     set @sql_sub=@sql_sub+' and d.BankCode='''+@deposit_id +''''  
      
    set @sql_sub=@sql_sub+' group by d.BankCode'  
  
  print(@sql_sub)  
  exec(@sql_sub)  
 end  
  
-------Send Trans  
  
 set @sql_sub='insert #temp_balance([Type],bank_code,[Settlement_Amount])   
    select ''PNSSEnD'',d.BankCode,  
    sum(case when SenderBankId is null then d.amtPaid else paidAmt end) Amt  
    from MoneySend m left outer join deposit_detail d  
    on m.tranno=d.tranno  
    where convert(varchar,d.depositDOT,102)<> convert(varchar,m.local_dot,102)  
    and agentid='+@agentId +'  
    and d.depositDOT < '''+ @from_date +''''  
    if @branch_code is not null   
     set @sql_sub=@sql_sub+' and m.branch_code='''+@branch_code +''''  
    if @deposit_id is not null   
     set @sql_sub=@sql_sub+' and d.BankCode='+@deposit_id +''  
    set @sql_sub=@sql_sub+' group by d.BankCode'  
  
 print(@sql_sub)  
 exec(@sql_sub)  
 ---###arch1  
 --if exists(select top 1 table_name from close_transaction where close_date <= @to_date)  
 begin  
  set @sql_sub='insert #temp_balance([Type],bank_code,[Settlement_Amount])   
     select ''Send Trans'',d.BankCode,  
     sum(case when SenderBankId is null then d.amtPaid else paidAmt end) Amt  
     from MoneySend_arch1 m left outer join deposit_detail_arch1 d  
     on m.tranno=d.tranno  
     where  convert(varchar,d.depositDOT,102)<> convert(varchar,m.local_dot,102)  
     and agentid='+@agentId +'   
     and d.depositDOT < '''+ @from_date +''''  
     if @branch_code is not null   
      set @sql_sub=@sql_sub+' and m.branch_code='''+@branch_code +''''  
    if @deposit_id is not null   
     set @sql_sub=@sql_sub+' and d.BankCode='+@deposit_id +''  
    set @sql_sub=@sql_sub+' group by d.BankCode'  
  
  print(@sql_sub)  
  exec(@sql_sub)  
 end   
  
-------Pending Trans  
  
  set @sql_sub='insert #temp_balance([Type],bank_code,[Settlement_Amount])   
     select ''Pending Trans'',BankCode, sum(amtPaid) Amt  
     from pendingTransaction  
     where  pending=''y''  
     and agentCode='+@agentId +'   
     and depositDOT < '''+ @from_date +''''  
     if @branch_code is not null   
      set @sql_sub=@sql_sub+' and branch_code='''+@branch_code +''''  
     if @deposit_id is not null   
     set @sql_sub=@sql_sub+' and BankCode='+@deposit_id +''  
    set @sql_sub=@sql_sub+' group by BankCode'  
  
  print(@sql_sub)  
  exec(@sql_sub)  
  
-------With Draw/Deposit  
  
 set @sql_sub='insert #temp_balance([Type],bank_code,[Settlement_Amount])   
    select ''Withdraw'',sender_bankid,sum(case when invoice_type=''m'' then local_amt else local_amt *-1 end) Amt  
    from agent_fund_detail  
    where  agentCode='+@agentId +'   
    and DOT < '''+ @from_date +''''  
    if @branch_code is not null   
     set @sql_sub=@sql_sub+' and branch_code='''+@branch_code +''''  
    if @deposit_id is not null   
     set @sql_sub=@sql_sub+' and sender_bankid='+@deposit_id +''  
    set @sql_sub=@sql_sub+' group by sender_bankid'  
  
  
 print(@sql_sub)  
 exec(@sql_sub)  
  
-------Cancel  
  
 set @sql_sub='insert #temp_balance([Type],bank_code,[Settlement_Amount])   
    select ''Cancel'',d.BankCode,sum(case when SenderBankId is null then d.amtPaid else paidAmt end)*-1 Amt  
    from MoneySend m left outer join deposit_detail d  
    on m.tranno=d.tranno  
    where m.agentid='+@agentId +' and transStatus=''cancel''  
    and m.cancel_date between '''+ @start_date +''' and '''+ cast(dateadd(d,-1,@from_date + ' 23:59:59') as varchar) +''''  
    if @branch_code is not null   
     set @sql_sub=@sql_sub+' and m.branch_code='''+@branch_code +''''  
    if @deposit_id is not null   
     set @sql_sub=@sql_sub+' and d.BankCode='+@deposit_id +''  
    set @sql_sub=@sql_sub+' group by d.BankCode'  
  
  
 print '4::'+ @sql_sub  
 exec(@sql_sub)  
  
--if exists(select top 1 table_name from close_transaction where close_date <= @to_date)  
 begin  
  set @sql_sub='insert #temp_balance([Type],bank_code,[Settlement_Amount])   
     select ''Cancel'',d.BankCode,sum(case when SenderBankId is null then d.amtPaid else paidAmt end)*-1 Amt  
     from MoneySend_arch1 m left outer join deposit_detail_arch1 d  
     on m.tranno=d.tranno  
     where m.agentid='+@agentId +' and transStatus=''cancel''  
        and m.cancel_date between '''+ @start_date +''' and '''+ cast(dateadd(d,-1,@from_date + ' 23:59:59') as varchar) +''''  
     if @branch_code is not null   
      set @sql_sub=@sql_sub+' and m.branch_code='''+@branch_code +''''  
       
     if @deposit_id is not NULL   
      set @sql_sub=@sql_sub+' and d.BankCode='+@deposit_id +''  
    set @sql_sub=@sql_sub+' group by d.BankCode'  
  
  print '4::'+ @sql_sub  
  exec(@sql_sub)  
 end  
  
---############## END OPEN BALANC  
--return  
  
---############## END OPEN BALANC  
  
--select * from #temp_balance  
--return  
  
  
---#########Current Date Summary Detail  
  
-------Send Trans  
 set @sql_sub='insert #temp_balance(bank_code,SendTRN)   
    select d.BankCode,sum(case when SenderBankId is null then d.amtPaid else paidAmt end)  
     from MoneySend m left outer join deposit_detail d  
     on m.tranno=d.tranno  
     where  convert(varchar,d.depositDOT,102)=convert(varchar,m.local_dot,102) and pending_id is null   
     and agentid='+@agentId +'  
     and d.depositDOT between '''+ @from_date +''' and ''' + @to_date +' 23:59:59'''  
     if @branch_code is not null   
     set @sql_sub=@sql_sub+' and m.branch_code='''+@branch_code +''''  
    if @deposit_id is not null   
     set @sql_sub=@sql_sub+' and d.BankCode='+@deposit_id +''  
    set @sql_sub=@sql_sub+' group by d.BankCode'  
 print(@sql_sub)  
 exec(@sql_sub)  
 if exists(select top 1 table_name from close_transaction where close_date >= @from_date)  
 begin  
 set @sql_sub='insert #temp_balance(bank_code,SendTRN)   
    select d.BankCode, sum(case when SenderBankId is null then d.amtPaid else paidAmt end)  
     from MoneySend_arch1 m left outer join deposit_detail_arch1 d  
     on m.tranno=d.tranno  
     where  convert(varchar,d.depositDOT,102)=convert(varchar,m.local_dot,102) and pending_id is null   
     and agentid='+@agentId +'   
     and d.depositDOT between '''+ @from_date +''' and ''' + @to_date +' 23:59:59'''  
     if @branch_code is not null   
     set @sql_sub=@sql_sub+' and m.branch_code='''+@branch_code +''''  
    if @deposit_id is not null   
     set @sql_sub=@sql_sub+' and d.BankCode='+@deposit_id +''  
    set @sql_sub=@sql_sub+' group by d.BankCode'  
 print(@sql_sub)  
 exec(@sql_sub)  
 end  
  
 -------PNDSND   
 set @sql_sub='insert #temp_balance(bank_code,PNDSND)   
    select d.BankCode,sum(case when SenderBankId is null then d.amtPaid else paidAmt end)  
     from MoneySend m left outer join deposit_detail d  
     on m.tranno=d.tranno  
     where  convert(varchar,d.depositDOT,102)<> convert(varchar,m.local_dot,102)   
     and agentid='+@agentId +'   
     and m.local_dot between '''+ @from_date +''' and ''' + @to_date +' 23:59:59'''  
     if @branch_code is not null   
     set @sql_sub=@sql_sub+' and m.branch_code='''+@branch_code +''''  
    if @deposit_id is not null   
     set @sql_sub=@sql_sub+' and d.BankCode='+@deposit_id +''  
    set @sql_sub=@sql_sub+' group by d.BankCode'  
 print(@sql_sub)  
 exec(@sql_sub)  
 if exists(select top 1 table_name from close_transaction where close_date >= @from_date)  
 begin  
 set @sql_sub='insert #temp_balance(bank_code,PNDSND)   
    select d.BankCode,sum(case when SenderBankId is null then d.amtPaid else paidAmt end)  
     from MoneySend_arch1 m left outer join deposit_detail_arch1 d  
     on m.tranno=d.tranno  
     where  convert(varchar,d.depositDOT,102)<> convert(varchar,m.local_dot,102)   
     and agentid='+@agentId +'   
     and m.local_dot between '''+ @from_date +''' and ''' + @to_date +' 23:59:59'''  
     if @branch_code is not null   
     set @sql_sub=@sql_sub+' and m.branch_code='''+@branch_code +''''  
    if @deposit_id is not null   
     set @sql_sub=@sql_sub+' and d.BankCode='+@deposit_id +''  
    set @sql_sub=@sql_sub+' group by d.BankCode'  
 print(@sql_sub)  
 exec(@sql_sub)  
end  
-------Pending Trans  
set @sql_sub='insert #temp_balance(Bank_code,PendingTrans)   
   select BankCode,sum(amtPaid)  
    from pendingTransaction   
    where  pending=''y'' and agentCode='+@agentId +'  
    and depositDOT between '''+ @from_date +''' and ''' + @to_date +' 23:59:59'''  
    if @branch_code is not null   
    set @sql_sub=@sql_sub+' and branch_code='''+@branch_code +''''  
   if @deposit_id is not null   
     set @sql_sub=@sql_sub+' and BankCode='+@deposit_id +''  
    set @sql_sub=@sql_sub+' group by BankCode'  
print(@sql_sub)  
exec(@sql_sub)  
  
-------Deposit/Withdraw  
set @sql_sub='insert #temp_balance(Bank_code,Deposit)   
   select sender_bankid,sum(local_amt)  
    from agent_fund_detail   
    where invoice_type=''m'' and agentCode='+@agentId +'   
    and DOT between '''+ @from_date +''' and ''' + @to_date +' 23:59:59'''  
    if @branch_code is not null   
    set @sql_sub=@sql_sub+' and branch_code='''+@branch_code +''''  
   if @deposit_id is not null   
     set @sql_sub=@sql_sub+' and sender_bankid='+@deposit_id +''  
   set @sql_sub=@sql_sub+' group by sender_bankid'  
print(@sql_sub)  
exec(@sql_sub)  
-------Transfered  
set @sql_sub='insert #temp_balance(Bank_code,Transfered)   
   select sender_bankid,sum(local_amt *-1)  
    from agent_fund_detail   
    where invoice_type <> ''m'' and agentCode='+@agentId +'   
    and DOT between '''+ @from_date +''' and ''' + @to_date +' 23:59:59'''  
    if @branch_code is not null   
    set @sql_sub=@sql_sub+' and branch_code='''+@branch_code +''''  
   if @deposit_id is not null   
     set @sql_sub=@sql_sub+' and sender_bankid='+@deposit_id +''  
   set @sql_sub=@sql_sub+' group by sender_bankid'  
print(@sql_sub)  
exec(@sql_sub)  
-------Cancel  
set @sql_sub='insert #temp_balance(Bank_code,Cancel)   
   select d.BankCode,  
   sum(case when SenderBankId is null then d.amtPaid else paidAmt end) * -1   
    from MoneySend m left outer join deposit_detail d  
    on m.tranno=d.tranno  
    where   agentid='+@agentId +' and transStatus=''cancel''  
    and m.cancel_date between '''+ @from_date +''' and ''' + @to_date +' 23:59:59'''  
    if @branch_code is not null   
    set @sql_sub=@sql_sub+' and m.branch_code='''+@branch_code +''''  
   if @deposit_id is not null   
     set @sql_sub=@sql_sub+' and d.BankCode='+@deposit_id +''  
   set @sql_sub=@sql_sub+' group by d.BankCode'  
print(@sql_sub)  
exec(@sql_sub)  
  
if exists(select top 1 table_name from close_transaction where close_date >= @from_date)  
begin  
set @sql_sub='insert #temp_balance(Bank_code,Cancel)   
   select d.BankCode,  
   sum(case when SenderBankId is null then d.amtPaid else paidAmt end) * -1   
    from MoneySend_arch1 m left outer join deposit_detail_arch1 d  
    on m.tranno=d.tranno  
    where   agentid='+@agentId +' and transStatus=''cancel''  
    and m.cancel_date between '''+ @from_date +''' and ''' + @to_date +' 23:59:59'''  
    if @branch_code is not null   
    set @sql_sub=@sql_sub+' and m.branch_code='''+@branch_code +''''  
   if @deposit_id is not null   
     set @sql_sub=@sql_sub+' and d.BankCode='+@deposit_id +''  
   set @sql_sub=@sql_sub+' group by d.BankCode'  
print(@sql_sub)  
exec(@sql_sub)  
end  
  
  
set @sql='  
insert #temp(bank_code,open_balance,SendTRN,PNDSND,Deposit,PendingTrans,Transfered,Cancel)  
select bank_code,sum([Settlement_Amount]),sum(SendTRN),sum(PNDSND),sum(Deposit),sum(PendingTrans),sum(Transfered),sum(Cancel)  
 from #temp_balance group by bank_code'   
exec(@sql)  
  
DECLARE @temptablename varchar(200)  
  
  set @temptablename=dbo.FNAProcessTBl('Deposit_Summary', @login_user_id, @process_id)  
  PRINT 'Table '+@temptablename  
  set @sql_sub='create table '+@temptablename+'(  
   bank_code varchar(200),  
   bank_name varchar(200),  
   open_balance money NULL ,  
   SendTRN money NULL ,  
   PNDSND Money NULL,  
   Deposit Money  NULL ,  
   PendingTrans [money] NULL ,  
   Transfered [money] NULL ,  
   Cancel [money] NULL   
  )'  
  exec(@sql_sub)  
  SET @sql_sub='insert into '+@temptablename+'(bank_code,bank_name,open_balance,SendTRN,PNDSND,Deposit,PendingTrans,Transfered,Cancel)  
  select bank_code,b.bankName,open_balance,SendTRN,PNDSND,Deposit,PendingTrans,Transfered,Cancel  
   from #temp t join BankAgentSender b on b.agentcode=t.bank_code '  
 IF @deposit_type IS NOT NULL  
  SET @sql_sub=@sql_sub +' where isNull(b.deposit_type,''d'')='''+ @deposit_type +''''  
   
  SET @sql_sub=@sql_sub +' order by isNull(deposit_type,''d'') desc,b.bankName'  
  PRINT @sql_sub  
  exec(@sql_sub)  
  
 declare @msg_agenttype varchar(100),@url_desc varchar(200),  
 @bank_name varchar(200),@desc varchar(500),@branch varchar(100)  
  
 IF @deposit_id IS NOT NULL  
  SELECT @bank_name=bankName FROM BankAgentSender WHERE AgentCode=@deposit_id  
 ELSE  
 begin  
  IF @deposit_type IS NOT NULL  
   set @bank_name= CASE WHEN @deposit_type='a' THEN 'Non Bank Only' ELSE 'Bank Only' END   
  ELSE  
  set @bank_name= 'All Ledger'  
 end  
 IF @branch_code IS NOT NULL  
  SELECT @branch=branch FROM agentbranchdetail WHERE agent_branch_Code=@branch_code  
 ELSE  
  SET @branch=''  
   
 set @msg_agenttype=@bank_name   
    
 set @url_desc='fromDate='+@from_date+'&toDate='+@to_date+'&bank_name='+@bank_name +'&branch_name='+@branch  
  
  set @desc ='Ledger Summary ('+ @bank_name +') '+ @branch +' is completed as of date '+@from_date  
  
   
  
  EXEC  spa_message_board 'u', @login_user_id,  
     NULL, 'deposit_summary',  
     @desc, 'c', @process_id,null,@url_desc  