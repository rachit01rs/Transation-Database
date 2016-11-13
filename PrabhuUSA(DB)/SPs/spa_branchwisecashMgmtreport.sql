--  
----Exec spa_branchwisecashMgmtreport 'a','10100000','4/7/2009','4/7/2009 23:59:59'   
CREATE Proc [dbo].[spa_branchwisecashMgmtreport]  
 @flag char(1),  
 @Agentid varchar(20),  
 @dateFrom varchar(25),  
 @dateTo varchar(25)  
AS  
---- TEST  
--DECLARE  @flag char(1),  
-- @Agentid varchar(20),  
-- @dateFrom varchar(25),  
-- @dateTo varchar(25)  
--SET @flag='a'  
--SET @Agentid='10100000'  
--SET @dateFrom='2009-08-14'  
--SET @dateTo='2009-08-14 23:59:59'  
--drop table #tempcashpre  
--drop table #tempcashdr  
--drop table #tempcashcr  
--drop table #tempcashpend  
--drop table #tempCashInHand  
---------End test  
  
DECLARE @cash_id int  
SELECT @cash_id=cash_ledger_id FROM agent_function WHERE agent_Id=@Agentid  
if @flag='a'  
begin  
  
  CREATE TABLE [dbo].[#tempcashpre](  
   [branch_code] [varchar](50)  NULL,  
   [branch] [varchar](200)  NULL,  
   [preBalance] [money] NULL  
  )   
  
  CREATE TABLE [dbo].[#tempcashdr](  
   [branch_code] [varchar](50)  NULL,  
   [BranchName] [varchar](100)  NULL,  
   [DR] [money] NULL,  
   [CR] [money] NULL  
  )   
  
  CREATE TABLE [dbo].[#tempcashcr](  
   [branch_code] [varchar](50)  NULL,  
   [BranchName] [varchar](100)  NULL,  
   [DR] [money] NULL,  
   [CR] [money] NULL  
  )  
  CREATE TABLE [dbo].[#tempcashpend](  
   [branch_code] [varchar](50)  NULL,  
   [branch] [varchar](200)  NULL,  
   [pendingAmt] [money] NULL  
  )  
  CREATE TABLE [dbo].[#tempCashInHand](  
   [branch_code] [varchar](50)  NULL,  
   [branch] [varchar](200)  NULL,  
   [totalAmt] [money] NULL  
  )  
  CREATE TABLE [dbo].[#tempCashCancel](  
   [branch_code] [varchar](50)  NULL,  
   [branch] [varchar](200)  NULL,  
   [totalAmt] [money] NULL  
  )  
  
 insert into #tempcashpre  
 select  branch_code,branch,  
 case when sum(dr-cr) <> 0 then sum(dr-cr) else 0 end preBalance  
 from   
 (  
  select  branch_code, branch, sum(stored_amount) DR,0 CR from store_cash  s   
  join agentbranchdetail b  on s.branch_code=b.agent_branch_code  
  where approve_date < @dateFrom  
  and mode='a' and b.agentcode=@Agentid   
  GROUP BY branch_code,branch  
  union all  
  select branch_code, branch, 0 DR,sum(local_amt) Cr from  agent_fund_detail s  
  join agentbranchdetail b  on s.branch_code=b.agent_branch_code  
  where dot < @dateFrom  
  and invoice_no is not null AND invoice_type='w'  
  and s.agentCode=@Agentid and sender_bankId=@cash_id  
  GROUP BY branch_code,branch  
  UNION ALL   
  select branch_code, branch, sum(local_amt) DR,0 Cr from  agent_fund_detail s  
  join agentbranchdetail b  on s.branch_code=b.agent_branch_code  
  where dot < @dateFrom  
  and invoice_no is not null AND invoice_type='m'  
  and s.agentCode=@Agentid and sender_bankId=@cash_id  
  GROUP BY branch_code,branch  
 ) p group by branch_code,branch order by branch  
  
  insert into #tempcashdr  
  SELECT branch_code,branchName,sum(DR+CR) DR,NULL CR FROM (  
  select branch_code,b.branch BranchName,sum(stored_amount) DR,0 CR   
   from store_cash s   
   join agentbranchdetail b  on s.branch_code=b.agent_branch_code  
   where approve_date between @dateFrom and @dateTo   
   and mode='a' and b.agentcode=@Agentid   
   group by b.agentcode, branch_code,b.branch  
  UNION ALL   
   select branch_code,b.branch BranchName,0 DR,sum(local_amt) Cr   
   from  agent_fund_detail f join  
   agentbranchdetail b  on f.branch_code=b.agent_branch_code  
   join BankAgentSender bank on f.Sender_BankId=bank.agentcode  
   where dot between @dateFrom and @dateTo   
   and f.agentCode=@Agentid  
   and sender_bankID in (@cash_id)  
   and invoice_no is not NULL  
   AND invoice_type ='m'  
   group by branch_code,b.branch  
  )p GROUP BY branch_code,branchName  
  
  insert into #tempcashcr  
  select branch_code,b.branch BranchName,NULL DR,sum(local_amt) Cr   
  from  agent_fund_detail f join  
   agentbranchdetail b  on f.branch_code=b.agent_branch_code  
   join BankAgentSender bank on f.Sender_BankId=bank.agentcode  
   where dot between @dateFrom and @dateTo   
   and f.agentCode=@Agentid  
   and sender_bankID in (@cash_id)  
   and invoice_no is not NULL  
   AND invoice_type ='w'  
  group by branch_code,b.branch  
  ORDER BY B.branch  
  
  INSERT INTO #tempCashInHand  
  SELECT branch_code,branch,sum(TotalCollected)-sum(TotalStored) TotalAmt FROM (  
  SELECT  branch_id branch_code,b.branch,sum(collected_amount) TotalCollected,0 TotalStored   
  from cash_collected c   
  JOIN agentbranchdetail b ON c.branch_id=b.agent_branch_Code  
  WHERE  b.agentCode=@Agentid  AND COLLECTED_TS <= @dateTo  
  GROUP BY branch_id,branch  
  UNION ALL  
  SELECT  branch_id branch_code,b.branch,0 TotalCollected,sum(collected_amount) TotalStored   
  from cash_payment c   
  JOIN agentbranchdetail b ON c.branch_id=b.agent_branch_Code  
  WHERE b.agentCode=@Agentid  AND COLLECTED_TS <= @dateTo  
  and cancel_sno is null  
  GROUP BY branch_id,branch  
  UNION ALL  
  SELECT  branch_id branch_code,b.branch,0 TotalCollected,sum(collected_amount) TotalStored   
  from cash_payment c   
  JOIN agentbranchdetail b ON c.branch_id=b.agent_branch_Code  
  WHERE b.agentCode=@Agentid  AND COLLECTED_TS <= @dateTo  
  and cancel_sno is not null  
  GROUP BY branch_id,branch  
  union all  
  SELECT  branch_code branch_code,b.branch,0 TotalCollected,sum(stored_amount) TotalStored   
  FROM store_cash s   
  JOIN agentbranchdetail b ON s.branch_code=b.agent_branch_Code   
  WHERE b.agentCode=@Agentid  AND deposit_date < @dateTo   
  GROUP BY branch_code,branch  
  )p   
  GROUP BY branch_code,branch  
  
  insert into #tempcashpend  
  select  branch_code,b.branch BranchName,isNULL(sum(stored_amount),0) pendingAmt  
   from store_cash  s   
   join agentbranchdetail b  on s.branch_code=b.agent_branch_code  
   where deposit_date < @dateTo  
   and mode='p' and b.agentcode=@Agentid   
   group by b.agentcode, branch_code,b.branch   
  
  
  insert into #tempCashCancel  
  select branch_id,b.branch BranchName,isNULL(sum(collected_amount),0) cancelAmt  
   from cash_collected  c   
   JOIN agentbranchdetail b ON c.branch_id=b.agent_branch_Code  
   where status_ts between @dateFrom and @dateTo   
   and status='cancel' and b.agentcode=@Agentid   
   group by b.agentcode, branch_id,b.branch   
  
 --select dr,cr,dr-cr from #tempcashpre  
  
 select a.agent_branch_Code,a.Branch,isNull(a.telephone,'--') telephone,isNULL(p.preBalance,0) preBalance,d.DR,c.CR,isNULL(pd.pendingAmt,0) pendingAmt,  
 isNUll(ch.totalAmt,0) cashierBalance,  
 (isnull(p.preBalance,0) + isnull(d.DR,0)+isNULL(ch.totalAmt,0)+isNULL(pd.pendingAmt,0))-isnull(c.CR,0) as Balance,  
 isNull(cc.totalAmt,0) CancelCash  
 FROM agentbranchdetail a   
 LEFT JOIN #tempcashpre p ON a.agent_branch_Code=p.branch_code  
 LEFT JOIN #tempcashdr d on a.agent_branch_Code=d.branch_code  
 LEFT JOIN #tempcashcr c on a.agent_branch_Code=c.branch_code   
 LEFT JOIN #tempcashpend pd on a.agent_branch_Code=pd.branch_code  
 LEFT JOIN #tempCashInHand ch on a.agent_branch_Code=ch.branch_code  
 LEFT JOIN #tempCashCancel cc on a.agent_branch_Code=cc.branch_code  
 WHERE a.agentCode=@agentid ORDER BY a.Branch  
  
drop table #tempcashpre  
drop table #tempcashdr  
drop table #tempcashcr  
drop table #tempcashpend  
drop table #tempCashInHand  
  
end   
  
  
  
  
  
  
  
  
  
  
  
  
  
  