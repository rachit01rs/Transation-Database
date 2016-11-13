  
  
--spa_UnitellerBranchReset @agentid='92400000',@from_date='2013-03-20',@branch_code='92400100'  
DROP PROC  spa_UnitellerBranchReset
GO 
CREATE proc.[dbo].[spa_UnitellerBranchReset]  
@agentId varchar(50),  
@from_date varchar(20),  
@branch_code varchar(max)=NULL,  
@login_user_id varchar(50)=NULL,  
@deposit_type varchar(10)=NULL,  
@Reg_branch_code VARCHAR(50)=NULL  
-- WITH ENCRYPTION  
as  
DECLARE @process_id varchar(150),@to_date varchar(20)   
SET @process_id = REPLACE(newid(),'-','_')  
  
--------- FOR TEST  
--declare @agentId varchar(50), @from_date varchar(20),  
--@branch_code varchar(50),@flag char(1),@process_id varchar(150),@login_user_id varchar(50),@to_date varchar(20)  
--  
----    
------set @show_open_balance='y'  
--set @agentId='10100000'  
----SET @branch_code='33424455'  
------set @deposit_id='8241'  
--set @from_date='2012-04-26'  
------set @to_date='2012-04-15'  
--drop table #temp  
--drop table #temp_balance  
--DROP TABLE #temp_vault_in  
--DROP TABLE #temp_vault_cit  
--  
--DROP TABLE #temp_vault_out_teller  
--DROP TABLE #temp_vault_out_bank  
--DROP TABLE #temp_vault_out_refund  
--DROP TABLE #branch_list   
--DROP TABLE #temp_collected  
--DROP TABLE #temp_payment  
--DROP TABLE #temp_cash_in_hand  
--  
--SET @process_id='123'  
--SET @login_user_id='Anoop'  
--DROP TABLE iremit_process.dbo.cash_vault_Anoop_123  
----------End TEst  
SET @to_date=@from_date   
DECLARE @cash_id VARCHAR(50),@start_opening_balance varchar(50) ,@deposit_id  VARCHAR(50),@Process_id_arch VARCHAR(150)   
  
SELECT TOP 1 @start_opening_balance=convert(varchar,abc.close_date,111) ,@Process_id_arch=abc.process_id  
FROM Account_Book_Close abc WHERE abc.book_type='BranchCash' and abc.close_date<@from_date ORDER BY close_ts DESC  
   
IF @Process_id_arch IS NULL    
 SET @start_opening_balance ='2013-03-19'  
   
--SET @deposit_id='8241'  
  
DECLARE @CIT VARCHAR(50),@refund_id VARCHAR(50)  
        
select @deposit_id=AgentCode from BankAgentSender where BankName='Cash Vault' and Send_AgentCode=@agentID        
SELECT @cash_id=af.cash_ledger_id,@refund_id=af.customer_refund_ledger        
  FROM agent_function af WHERE af.agent_Id=@agentId        
    
SET @CIT=8161   
  
DECLARE @isHO CHAR(1)  
SELECT @isHO=a.isHeadOffice  
  FROM agentbranchdetail a WHERE a.agent_branch_Code=@Reg_branch_code  
IF @branch_code IS NULL   
BEGIN  
   
 select @branch_code= COALESCE(@branch_code + ',', '') + reg_branch_id from agent_regional_branch  WHERE agent_branch_code=@Reg_branch_code  
 IF @branch_code IS NOT NULL   
  SET @branch_code=@branch_code +','+ @Reg_branch_code  
 ELSE   
 BEGIN   
  IF isNULL(@isHO,'n')='n'  
   SET @branch_code=@Reg_branch_code  
 END    
END   
  
CREATE TABLE [#temp] (  
 [sno] int identity(1,1) ,  
 particulars VARCHAR(100),  
 DOT DATETIME,  
 type varchar(100),  
 [Settlement_Amount] [money] NULL,  
 Bank_code int ,  
 vault_in MONEY,  
 vault_out MONEY,  
 branch_id VARCHAR(20)   
   
) ON [PRIMARY]  
  
CREATE TABLE [#temp_balance] (  
 [sno] int identity(1,1) ,  
 particulars VARCHAR(100),  
 DOT DATETIME,  
 type varchar(100),  
 [Settlement_Amount] [money] NULL,  
 Bank_code int ,  
 vault_in MONEY,  
 vault_out MONEY ,  
 branch_id VARCHAR(20)  
) ON [PRIMARY]  
  
CREATE TABLE #temp_vault_in(  
 TYPE VARCHAR(50),  
 vault_in MONEY,  
 branch_id VARCHAR(50))  
  
CREATE TABLE #temp_vault_cit(  
 TYPE VARCHAR(50),  
 vault_out MONEY,  
 branch_id VARCHAR(50))  
  
CREATE TABLE #temp_vault_out_teller(  
 TYPE VARCHAR(50),  
 vault_out MONEY,  
 branch_id VARCHAR(50))  
  
CREATE TABLE #temp_vault_out_bank(  
 TYPE VARCHAR(50),  
 vault_out MONEY,  
 branch_id VARCHAR(50))  
  
CREATE TABLE #temp_vault_out_refund(  
 TYPE VARCHAR(50),  
 vault_out MONEY,  
 branch_id VARCHAR(50))  
     
CREATE TABLE #branch_list(  
 agent_branch_code VARCHAR(50),  
 branch VARCHAR(150)  
)  
DECLARE @sql VARCHAR(MAX)  
SET @sql='insert #branch_list  
select agent_branch_code,branch from agentbranchdetail where agentcode='+ @agentId   
IF @branch_code IS NOT NULL   
 SET @sql=@sql + ' and agent_branch_code in ('+@branch_code +')'  
EXEC (@sql)   
      
---- ############## calc Open Balance  
declare @sql_sub varchar(5000),@opening_date varchar(50)   
set @opening_date=convert(varchar,dateadd(d,-1,cast(@from_date AS DATETIME)),111)  
   
  
-------With Draw/Deposit  
SET @sql='  
 insert #temp_balance([Type],[Settlement_Amount],branch_id)   
    select ''Opening Balance'',sum(afd_opening_balance),branch_ID from (  
    SELECT a.afd_opening_balance,branch_ID FROM ArchiveUnitellerCashBranch a join   
    agentbranchdetail b on b.agent_branch_Code=a.branch_id  
    WHERE process_id='''+ @Process_id_arch +''' and b.agentCode='''+ @agentId +''''  
    IF @branch_code IS NOT NULL   
     SET @sql=@sql + ' and branch_ID in ('+@branch_code +')'  
    SET @sql=@sql + '  
    UNION ALL   
    select  sum(case when invoice_type=''m'' then local_amt else local_amt *-1 end) Amt,  
    branch_code  
    from agent_fund_detail with (nolock)  
    where  agentCode='+ @agentId +' and approve_by is NOT NULL  
    and DOT between '''+ @start_opening_balance  +''' and '''+ @opening_date +' 23:59:59'''  
     IF @branch_code IS NOT NULL   
     SET @sql=@sql + ' and branch_code in ('+@branch_code +')'  
     SET @sql=@sql + '  
     and sender_bankid='+ @deposit_id  +'  
    group by branch_code  
    ) l group by branch_id  
    '  
print @sql  
  
 EXEC (@sql)     
--return  
---- Opening balance End  
  
-------Vault IN Teller Transfer  
SET @sql='  
insert #temp_vault_in(Type,vault_in,branch_id)   
   select ''VaultIn'',sum(local_amt),branch_code  
    from agent_fund_detail with (nolock)  
    where invoice_type=''m'' and agentCode='+ @agentId +'  and approve_by is not null  
    and DOT between '''+  @from_date +''' and '''+  @to_date +' 23:59:59'''  
  IF @branch_code IS NOT NULL   
 SET @sql=@sql + ' and branch_code in ('+@branch_code +')'    
 SET @sql=@sql + ' and sender_bankid='+ @deposit_id +'   
   group by branch_code'  
 EXEC (@sql)    
  
-------Vault Out Teller  
SET @sql='  
insert #temp_vault_out_teller(Type,vault_out,branch_id)   
   select ''Vault Out'',sum(local_amt),branch_code  
    from agent_fund_detail with (nolock)  
    where invoice_type=''w'' and agentCode='+ @agentId + ' and approve_by is not null and teller_transfer=''y''  
    and DOT between '''+  @from_date +''' and '''+  @to_date +' 23:59:59'''  
   IF @branch_code IS NOT NULL      
    SET @sql=@sql + ' and branch_code in ('+@branch_code +')'    
    
  SET @sql=@sql + ' and sender_bankid='+ @deposit_id +'   
   group by branch_code'  
  EXEC  (@sql)  
    
  
  
-------Vault Out CIT  
SET @sql='  
insert #temp_vault_cit(Type,vault_out,branch_id)   
   select ''Vault Out'',sum(local_amt),branch_code  
    from agent_fund_detail with (nolock)  
    where invoice_type=''m'' and agentCode='+ @agentId +' and approve_by is not null   
    and teller_transfer is null  
    and DOT between '''+  @from_date +''' and '''+  @to_date +' 23:59:59'''  
       
   IF @branch_code IS NOT NULL      
    SET @sql=@sql + ' and branch_code in ('+@branch_code +')'    
   SET @sql=@sql + '  
   and sender_bankid='+ @CIT +'  
   group by branch_code '  
  EXEC(@sql)  
    
  
-------Vault Out Bank  
set @sql_sub='insert #temp_vault_out_bank(Type,vault_out,branch_id)   
   select ''Vault Out'',sum(a1.local_amt),a1.branch_code  
    from agent_fund_detail a1 with (nolock) join agent_fund_detail a2 with (nolock)  
    on a1.invoice_no=a2.invoice_no  
    where a1.invoice_type=''m'' and a1.agentCode='+@agentId +'  and a1.approve_by is not null and a1.teller_transfer is null   
    and a1.DOT between '''+ @from_date +''' and ''' + @to_date +' 23:59:59'''  
    if @branch_code is not null   
    set @sql_sub=@sql_sub+' and a1.branch_code in ('+@branch_code +')'  
     
   set @sql_sub=@sql_sub+' and a1.sender_bankid <>a2.sender_bankid'  
     
   set @sql_sub=@sql_sub+' and a1.sender_bankid not in ('+@deposit_id +','+@CIT +','+@refund_id+',8019)'  
   set @sql_sub=@sql_sub+' and a2.sender_bankid ='+@deposit_id   
   set @sql_sub=@sql_sub+' group by a1.branch_code'  
print(@sql_sub)  
exec(@sql_sub)  
  
-------Vault Out Refund  
SET @sql='  
insert #temp_vault_out_refund(Type,vault_out,branch_id)   
   select ''Vault Out'',sum(local_amt),branch_code  
    from agent_fund_detail with (nolock)  
    where invoice_type=''m'' and agentCode='+ @agentId +' and approve_by is not null and teller_transfer is null  
    and DOT between '''+  @from_date +''' and '''+  @to_date +' 23:59:59'''  
       
  IF @branch_code IS NOT NULL      
    SET @sql=@sql + ' and branch_code in ('+@branch_code +')'    
  SET @sql=@sql + ' and sender_bankid='+ @refund_id +'  
   group by branch_code'  
   EXEC(@sql)  
    
    
CREATE TABLE #temp_collected(  
CollectAMT MONEY,  
 Branch_code VARCHAR(50)  
)  
SET @sql='insert #temp_collected  
select SUM(CollectAMT) CollectAMT,Branch_code from (  
SELECT SUM(dd.amtPaid) CollectAMT,m.Branch_code FROM moneySend m with (nolock) JOIN deposit_detail dd with (nolock)   
ON m.Tranno=dd.tranno  
where  CONVERT(VARCHAR,m.local_DOT,102) between  CONVERT(VARCHAR,cast('''+ @from_date +''' AS DATETIME),102)    
 and CONVERT(VARCHAR,CAST('''+ @to_date + ''' AS DATETIME),102)   
AND m.agentid='+ @agentId +' AND dd.BankCode='+ @cash_id   
  
 IF @branch_code IS NOT NULL      
    SET @sql=@sql + ' and m.Branch_code in ('+@branch_code +')'    
SET @sql=@sql + '      
GROUP BY m.Branch_code) l group by Branch_code'  
print(@sql)  
EXEC(@sql)  
  
CREATE TABLE #temp_payment(  
PayAmt MONEY,  
 Branch_code VARCHAR(50)  
)  
SET @sql='insert #temp_payment  
SELECT sum(cp.collected_amount)   PayAmt , cp.branch_id  branch_code   
 FROM cash_payment cp with (nolock)  
WHERE payment_type is null and CONVERT(VARCHAR,cp.collected_ts,102) BETWEEN  CONVERT(VARCHAR,cast('''+ @from_date +''' AS DATETIME),102)  
 and  CONVERT(VARCHAR,CAST('''+ @to_date +''' AS DATETIME),102)'  
   
 IF @branch_code IS NOT NULL      
    SET @sql=@sql + ' and cp.branch_id in ('+@branch_code +')'   
       
SET @sql=@sql + '   
GROUP BY cp.branch_id'  
EXEC (@sql)  
  
------------Teller Balance  
   CREATE TABLE #temp_cash_in_hand  
  (teller_balance MONEY,  
  branch_code VARCHAR(50)  
  )  
    
  --union all  
--SELECT SUM(dd.amtPaid) CollectAMT,m.Branch_code FROM moneySend_arch1 m with (nolock)  JOIN deposit_detail_arch1 dd with (nolock)   
--ON m.Tranno=dd.tranno  
--where  CONVERT(VARCHAR,m.local_DOT,102) between CONVERT(VARCHAR,cast('''+ @start_opening_balance +''' AS DATETIME),102)    
-- and CONVERT(VARCHAR,CAST('''+ @to_date +''' AS DATETIME),102)   
--AND m.agentid='+ @agentId +' AND dd.BankCode='+ @cash_id   
--IF @branch_code IS NOT NULL   
--  SET @sql=@sql + ' and m.Branch_code in ('+@branch_code +')'  
-- SET @sql=@sql + '  
--GROUP BY m.Branch_code   
 --start opening balance  
 SET @sql='insert #temp_cash_in_hand  
SELECT SUM(CollectAMT) teller_balance,branch_code FROM (  
      
SELECT a.cih_opening_balance CollectAMT,branch_ID Branch_code FROM ArchiveUnitellerCashBranch a join   
agentbranchdetail b on b.agent_branch_Code=a.branch_id  
WHERE process_id='''+ @Process_id_arch +''' and b.agentCode='''+ @agentId +'''  
UNION ALL     
SELECT SUM(dd.amtPaid) CollectAMT,m.Branch_code FROM moneySend m with (nolock) JOIN deposit_detail dd with (nolock)   
ON m.Tranno=dd.tranno  
where  CONVERT(VARCHAR,m.local_DOT,102) between CONVERT(VARCHAR,cast('''+ @start_opening_balance +''' AS DATETIME),102)    
 and CONVERT(VARCHAR,CAST('''+ @to_date +''' AS DATETIME),102)   
AND m.agentid='+ @agentId +' AND dd.BankCode='+ @cash_id   
IF @branch_code IS NOT NULL   
  SET @sql=@sql + ' and m.Branch_code in ('+@branch_code +')'  
 SET @sql=@sql + '  
GROUP BY m.Branch_code  '  
  
SET @sql=@sql + '  
UNION ALL   
SELECT sum(cp.collected_amount) * -1  PayAmt , cp.branch_id  
 FROM cash_payment cp with (nolock)   
WHERE payment_type is null and CONVERT(VARCHAR,cp.collected_ts,102) between  CONVERT(VARCHAR,cast('''+ @start_opening_balance +''' AS DATETIME),102)    and CONVERT(VARCHAR,CAST('''+ @to_date +''' AS DATETIME),102)'   
IF @branch_code IS NOT NULL   
  SET @sql=@sql + ' and cp.branch_id in ('+@branch_code +')'  
 SET @sql=@sql + '  
 GROUP BY cp.branch_id  
UNION ALL   
--- Amount Transfered Out  
SELECT sum(stored_amount) * -1 ,sc.branch_code  
FROM store_cash sc with (nolock) JOIN agentbranchdetail b  
ON sc.branch_code=b.agent_branch_Code  
WHERE CONVERT(VARCHAR,sc.deposit_date,102) between  CONVERT(VARCHAR,cast('''+ @start_opening_balance  + ''' AS DATETIME),102)  and CONVERT(VARCHAR,CAST('''+ @to_date +''' AS DATETIME),102)   
 AND b.agentCode='+ @agentId +' AND sc.deposit_by<>''Vault'''  
 IF @branch_code IS NOT NULL   
  SET @sql=@sql + ' and sc.branch_code in ('+@branch_code +')'  
SET @sql=@sql + '   
GROUP BY sc.branch_code  
UNION ALL   
--- Amount Transfered IN  
SELECT sum(stored_amount),sc.branch_code  
FROM store_cash sc with (nolock) JOIN agentbranchdetail b  
ON sc.branch_code=b.agent_branch_Code  
WHERE CONVERT(VARCHAR,sc.approve_date,102)  
 between  CONVERT(VARCHAR,cast('''+ @start_opening_balance  +''' AS DATETIME),102) and CONVERT(VARCHAR,CAST('''+ @to_date +''' AS DATETIME),102)   
 AND b.agentCode='+ @agentId +' AND sc.approve_by <>''Vault'''  
  IF @branch_code IS NOT NULL   
  SET @sql=@sql + ' and sc.branch_code in ('+@branch_code +')'  
SET @sql=@sql + '  
GROUP BY sc.branch_code  
)l   
GROUP BY l.branch_code'  
EXEC(@sql)   
-- opening balance closed  
  
select bl.*,col.CollectAMT,pay.PayAmt, tb.Settlement_Amount OpeningBalance,vin.vault_in,cit.vault_out CIT,  
tel.vault_out Vault_out_teller,bank.vault_out Bank_Out,ref.vault_out Refund,  
ISNULL(cit.vault_out,0) +ISNULL(tel.vault_out,0) + ISNULL(bank.vault_out,0) + ISNULL(ref.vault_out,0) Vault_Out,  
cash.teller_balance,   
(ISNULL(tb.Settlement_Amount,0) + ISNULL(vin.vault_in,0) + ISNULL(cash.teller_balance,0))   
 - (ISNULL(cit.vault_out,0) +ISNULL(tel.vault_out,0) + ISNULL(bank.vault_out,0) + ISNULL(ref.vault_out,0) )   
NETBalance  
INTO #branch_reset  
from #branch_list bl Left OUTER JOIN #temp_balance tb  
ON bl.agent_branch_code=tb.branch_id   
left outer JOIN #temp_vault_in vin ON vin.branch_id=bl.agent_branch_code  
left outer JOIN #temp_vault_cit cit ON cit.branch_id=bl.agent_branch_code  
left outer JOIN #temp_vault_out_teller tel ON tel.branch_id=bl.agent_branch_code  
left outer JOIN #temp_vault_out_bank bank ON bank.branch_id=bl.agent_branch_code  
left outer JOIN #temp_vault_out_refund ref ON ref.branch_id=bl.agent_branch_code  
left outer JOIN #temp_cash_in_hand cash ON cash.branch_code=bl.agent_branch_code  
left outer JOIN #temp_collected col ON col.branch_code=bl.agent_branch_code  
left outer JOIN #temp_payment pay ON pay.branch_code=bl.agent_branch_code  
ORDER BY bl.branch  
  
  
UPDATE agentbranchdetail  
SET currentBalance = isnUll(r.NETBalance,0),  
Branch_vault_Balance = isnUll(r.NETBalance,0)  
FROM agentbranchdetail b JOIN #branch_reset r   
ON b.agent_branch_Code=r.agent_branch_code  
WHERE b.agentCode=@agentId  
  
SELECT branch,netbalance closeBalance FROM #branch_reset  