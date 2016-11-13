      
--set ANSI_NULLS ON      
--set QUOTED_IDENTIFIER ON      
--go      
      
      DROP PROC spa_deposit_ledger_summary_vault
      GO
----       
--set ANSI_NULLS ON  
--set QUOTED_IDENTIFIER ON  
--go  
  
----   
create proc.[dbo].[spa_deposit_ledger_summary_vault]  
@agentId varchar(50),  
@deposit_id varchar(50),  
@from_date varchar(20),  
@branch_code varchar(50)=NULL,  
@login_user_id varchar(50)=NULL,  
@process_id varchar(150)=NULL,  
@deposit_type varchar(10)=NULL,  
@to_date varchar(20) = NULL   
as  
  
  
------- FOR TEST  
--declare @agentId varchar(50),@deposit_id varchar(50),@from_date varchar(20),  
--@branch_code varchar(50),@flag char(1),@process_id varchar(150),@login_user_id varchar(50)  
--  
----set @show_open_balance='y'  
--set @agentId='10100000'  
----SET @branch_code='10100500'  
--set @deposit_id='8241'  
--set @from_date='2012-03-14'  
--set @to_date='2012-11-13'  
--drop table #temp  
--drop table #temp_balance  
--SET @process_id='123'  
--SET @login_user_id='Anoop'  
--DROP TABLE iremit_process.dbo.Deposit_Summary_Anoop_123  
--------End TEst  
  
  
  
CREATE TABLE [#temp] (  
 [sno] int identity(1,1) ,  
 particulars VARCHAR(500),  
 DOT DATETIME,  
 type varchar(100),  
 [Settlement_Amount] [money] NULL,  
 Bank_code int ,  
 vault_in MONEY,  
 vault_out MONEY,  
 branch_id VARCHAR(20),  
   [user_id] varchar(50)      
   
) ON [PRIMARY]  
  
CREATE TABLE [#temp_balance] (  
 [sno] int identity(1,1) ,  
 particulars VARCHAR(500),  
 DOT DATETIME,  
 type varchar(100),  
 [Settlement_Amount] [money] NULL,  
 Bank_code int ,  
 vault_in MONEY,  
 vault_out MONEY ,  
 branch_id VARCHAR(20),  
   [user_id] varchar(50)     
) ON [PRIMARY]  
  
---- ############## calc Open Balance  
declare @sql varchar(5000),@sql_sub varchar(5000),@opening_date varchar(20)  
set @opening_date=dateadd(d,-1,cast(@from_date AS DATETIME))  
  
  
    
-------With Draw/Deposit  
  
 set @sql_sub='insert #temp_balance(particulars,[Type],bank_code,[Settlement_Amount],DOT)   
    select ''Opening Balance'',''Opening Balance'',sender_bankid,sum(case when invoice_type=''m'' then local_amt else local_amt *-1 end) Amt,  
    '''+ @opening_date +'''  
    from agent_fund_detail  
    where  agentCode='+@agentId +' and approve_by is not null  
    and DOT < '''+ @from_date +''''  
    if @branch_code is not null   
     set @sql_sub=@sql_sub+' and branch_code='''+@branch_code +''''  
    if @deposit_id is not null   
     set @sql_sub=@sql_sub+' and sender_bankid='+@deposit_id +''  
    set @sql_sub=@sql_sub+' group by sender_bankid'  
  
 print(@sql_sub)  
 exec(@sql_sub)  
  
-------Vault IN  
set @sql_sub='insert #temp_balance(particulars,DOT,Type,Bank_code,vault_in,settlement_amount,branch_id,[user_id])   
   select Remarks,dot,''Deposit'',sender_bankID,local_amt,local_amt,branch_code,staff_id  
    from agent_fund_detail   
    where invoice_type=''m'' and agentCode='+@agentId +'  and approve_by is not null  
    and DOT between '''+ @from_date +''' and ''' + @to_date +' 23:59:59'''  
    if @branch_code is not null   
    set @sql_sub=@sql_sub+' and branch_code='''+@branch_code +''''  
   if @deposit_id is not null   
     set @sql_sub=@sql_sub+' and sender_bankid='+@deposit_id +''  
print(@sql_sub)  
exec(@sql_sub)  
-------Vault Out  
set @sql_sub='insert #temp_balance(particulars,DOT,Type,Bank_code,vault_out,settlement_amount,branch_id,[user_id])   
   select Remarks,dot,''Vault Out'',sender_bankID,local_amt,local_amt*-1,branch_code,staff_id  
    from agent_fund_detail   
    where invoice_type=''w'' and agentCode='+@agentId +'  and approve_by is not null  
    and DOT between '''+ @from_date +''' and ''' + @to_date +' 23:59:59'''  
    if @branch_code is not null   
    set @sql_sub=@sql_sub+' and branch_code='''+@branch_code +''''  
   if @deposit_id is not null   
     set @sql_sub=@sql_sub+' and sender_bankid='+@deposit_id +''  
print(@sql_sub)  
exec(@sql_sub)  
  
  
  
insert #temp(particulars,DOT,Type,Bank_code,vault_in,vault_out,[Settlement_Amount],branch_id,[user_id])  
select particulars,DOT,Type,Bank_code,vault_in,vault_out,(select sum(Settlement_Amount) from #temp_balance  
where dot<= t.dot) Balance,branch_id,[user_id]  
 from #temp_balance t order by dot   
  
   
DECLARE @temptablename varchar(200)  
  
  set @temptablename=dbo.FNAProcessTBl('cash_vault', @login_user_id, @process_id)  
  PRINT 'Table '+@temptablename  
  set @sql_sub='create table '+@temptablename+'(  
   [sno] int identity(1,1) ,  
   particulars VARCHAR(500),  
   DOT DATETIME,  
   type varchar(100),  
   [Settlement_Amount] [money] NULL,  
   Bank_code int ,  
   vault_in MONEY,  
   vault_out MONEY ,  
   branch_id varchar(50),  
   branch_name varchar(200),  
   user_id varchar(50)   
  )'  
  exec(@sql_sub)  
  SET @sql_sub='insert into '+@temptablename+'(particulars,DOT,Type,Bank_code,vault_in,vault_out,[Settlement_Amount],branch_id,branch_name,user_id)  
  select particulars,DOT,Type,Bank_code,vault_in,vault_out,[Settlement_Amount],branch_id,ab.Branch,user_id  
   from #temp t JOIN dbo.agentbranchdetail ab ON t.branch_id=ab.agent_branch_Code  '  
 -- SET @sql_sub=@sql_sub +'group by branch_id,ab.Branch,user_id '
   SET @sql_sub=@sql_sub +' order by dot'  
  PRINT @sql_sub  
  exec(@sql_sub)  
  
 declare @msg_agenttype varchar(100),@url_desc varchar(200),  
 @bank_name varchar(200),@desc varchar(500),@branch varchar(100)  
  
 IF @branch_code IS NOT NULL  
  SELECT @branch=branch FROM agentbranchdetail WHERE agent_branch_Code=@branch_code  
 ELSE  
  SET @branch='ALL Branches'  
   
 set @msg_agenttype=@bank_name   
    
 set @url_desc='fromDate='+@from_date+'&toDate='+@to_date+'&bank_name=Cash Vault&branch_name='+@branch  
  
 set @desc ='Cash Vault : '+ @branch +' is completed as of date '+@from_date   
  
  EXEC  spa_message_board 'u', @login_user_id,  
     NULL, 'cash_vault',  
     @desc, 'c', @process_id,null,@url_desc  