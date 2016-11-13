--spa_UnitellerCashReportV2  'u','11000000',NULL,'20100000','2013-02-28','y'         
--select * from agentbranchdetail where agentCode='11000000'  
DROP PROC spa_UnitellerCashReportV2
GO    
--spa_UnitellerCashReportV2  'u','11000000',NULL,'20100000','2013-02-28','y'       
--select * from agentbranchdetail where agentCode='11000000'    
--spa_UnitellerCashReportV2  'u','11000000',NULL,'20100000','2013-02-28','y'       
--select * from agentbranchdetail where agentCode='11000000'    
CREATE PROCEDURE [dbo].[spa_UnitellerCashReportV2]      
 @flag CHAR(1) = NULL ,      
 @agent_id VARCHAR(50),      
 @username VARCHAR(100) = NULL ,      
 @branchCode VARCHAR(100) = NULL ,      
 @fromDate VARCHAR(100) = NULL,      
 @display_with_balance CHAR(1)=null      
-- WITH ENCRYPTION      
AS      
      
------- test       
--DECLARE @flag CHAR(1) ,      
-- @agent_id VARCHAR(50),      
-- @username VARCHAR(100)  ,      
-- @branchCode VARCHAR(100) ,      
-- @fromDate VARCHAR(100)      
--       
--set @flag='u'      
--set @agent_id=10100000      
----set @username='klanoop'      
--SET @branchCode='10100500'      
--set @fromDate='2012-03-14'      
--      
--DROP TABLE #temp_collect      
--DROP TABLE #temp_cancel      
--DROP TABLE #temp_deny      
--DROP TABLE #temp_paid      
--DROP TABLE #temp_transfered      
--DROP TABLE #temp_summary      
--DROP TABLE #temp_transfered_in      
--DROP TABLE #temp_drill_down       
--DROP TABLE #temp_opening       
      
DECLARE @cash_id VARCHAR(50),@start_opening_balance DATETIME,@Process_id_arch VARCHAR(150)       
      
SELECT TOP 1 @start_opening_balance=abc.close_date,@Process_id_arch=abc.process_id      
FROM Account_Book_Close abc WHERE abc.book_type='UserCash' and CONVERT(VARCHAR,abc.close_date,102)<CONVERT(VARCHAR,dateadd(d,-1,CAST(@fromDate AS DATETIME)),102)  ORDER BY close_ts DESC      
       
IF @Process_id_arch IS NULL       
begin     
 SET @start_opening_balance ='2013-01-11'      
 set @Process_id_arch='-1'    
end      
      
SELECT @cash_id=af.cash_ledger_id      
  FROM agent_function af WHERE af.agent_Id=@agent_id      
       
          
 --start opening balance      
SELECT sEmpID,SUM(CollectAMT) opening_balance INTO #temp_opening FROM (         
SELECT sEmpID,a.opening_balance CollectAMT FROM ArchiveUnitellerCash a join agentsub s      
on a.sEmpID=s.user_login_id join agentbranchdetail b on b.agent_branch_Code=s.agent_branch_code    
 join agentdetail ad on ad.agentCode=b.agentCode      
WHERE process_id=@Process_id_arch and ad.agentCode=@agent_id and      
CASE WHEN @branchCode IS NOT NULL THEN b.agent_branch_Code ELSE '1' END = ISNULL(@branchCode,'1')      
UNION ALL        
SELECT sEmpID,SUM(dd.amtPaid) CollectAMT FROM moneySend m with (nolock) JOIN deposit_detail dd with (nolock)       
ON m.Tranno=dd.tranno      
where  CONVERT(VARCHAR,m.local_DOT,102) between @start_opening_balance       
and CONVERT(VARCHAR,dateadd(d,-1,CAST(@fromDate AS DATETIME)),102)       
AND m.agentid=@agent_id AND dd.BankCode=@cash_id AND       
CASE WHEN @branchCode IS NOT NULL THEN m.Branch_code ELSE '1' END = ISNULL(@branchCode,'1')      
AND CASE WHEN @username IS NOT NULL THEN sempID ELSE '1' END = ISNULL(@username,'1')      
GROUP BY sEmpID      
--UNION ALL       
--SELECT sEmpID,SUM(dd.amtPaid) CollectAMT FROM moneySend_arch1 m with (nolock) JOIN deposit_detail_arch1 dd with (nolock)       
--ON m.Tranno=dd.tranno      
--where       
-- CONVERT(VARCHAR,m.local_DOT,102) between @start_opening_balance       
--and CONVERT(VARCHAR,dateadd(d,-1,CAST(@fromDate AS DATETIME)),102)       
--AND m.agentid=@agent_id AND dd.BankCode=@cash_id AND       
--CASE WHEN @branchCode IS NOT NULL THEN m.Branch_code ELSE '1' END = ISNULL(@branchCode,'1')      
--AND CASE WHEN @username IS NOT NULL THEN sempID ELSE '1' END = ISNULL(@username,'1')      
--GROUP BY sEmpID      
UNION ALL      
SELECT cp.collected_by paidBy,sum(cp.collected_amount) * -1  PayAmt       
 FROM cash_payment cp with (nolock)      
WHERE payment_type is null and CONVERT(VARCHAR,cp.collected_ts,102) between @start_opening_balance and CONVERT(VARCHAR,dateadd(d,-1,CAST(@fromDate AS DATETIME)),102)       
AND CASE WHEN @branchCode IS NOT NULL THEN cp.branch_id ELSE '1' END = ISNULL(@branchCode,'1')      
AND CASE WHEN @username IS NOT NULL THEN cp.collected_by ELSE '1' END = ISNULL(@username,'1')      
GROUP BY cp.collected_by      
UNION ALL       
--- Amount Transfered Out      
SELECT sc.deposit_by,sum(stored_amount) * -1       
FROM store_cash sc with (nolock) JOIN agentbranchdetail b      
ON sc.branch_code=b.agent_branch_Code      
WHERE CONVERT(VARCHAR,sc.deposit_date,102) between @start_opening_balance and CONVERT(VARCHAR,dateadd(d,-1,CAST(@fromDate AS DATETIME)),102)       
 AND b.agentCode=@agent_id  AND sc.deposit_by <> 'Vault'      
AND CASE WHEN @branchCode IS NOT NULL THEN sc.branch_code ELSE '1' END = ISNULL(@branchCode,'1')      
AND CASE WHEN @username IS NOT NULL THEN sc.deposit_by ELSE '1' END = ISNULL(@username,'1')      
GROUP BY sc.deposit_by      
UNION ALL       
--- Amount Transfered IN      
SELECT sc.approve_by,sum(stored_amount)      
FROM store_cash sc with (nolock) JOIN agentbranchdetail b      
ON sc.branch_code=b.agent_branch_Code      
WHERE CONVERT(VARCHAR,sc.approve_date,102) between @start_opening_balance and CONVERT(VARCHAR,dateadd(d,-1,CAST(@fromDate AS DATETIME)),102)       
 AND b.agentCode=@agent_id  AND sc.approve_by <> 'Vault'      
AND CASE WHEN @branchCode IS NOT NULL THEN sc.branch_code ELSE '1' END = ISNULL(@branchCode,'1')      
AND CASE WHEN @username IS NOT NULL THEN sc.approve_by ELSE '1' END = ISNULL(@username,'1')      
GROUP BY sc.approve_by      
)l       
GROUP BY l.sEmpID      
    
--- opening balance closed      
       
  --- Collect Amt      
SELECT bankCode,CollectAMT,sEmpID,TransStatus,local_DOT,Tranno,Branch_code INTO #temp_collect      
from (      
select bankCode,amtPaid CollectAMT,sEmpID,m.TransStatus,m.local_DOT,m.Tranno,m.Branch_code      
FROM moneysend m with (nolock) JOIN deposit_detail dd  with (nolock)      
ON m.Tranno=dd.tranno      
WHERE CONVERT(VARCHAR,m.local_DOT,102) =CONVERT(VARCHAR,CAST(@fromDate AS DATETIME),102)       
AND m.agentid=@agent_id AND        
CASE WHEN @branchCode IS NOT NULL THEN m.Branch_code ELSE '1' END = ISNULL(@branchCode,'1')      
AND CASE WHEN @username IS NOT NULL THEN sempID ELSE '1' END = ISNULL(@username,'1')      
AND dd.BankCode=@cash_id      
--union all      
--select bankCode,amtPaid CollectAMT,sEmpID,m.TransStatus,m.local_DOT,m.Tranno,m.Branch_code      
--FROM moneysend_hold m with (nolock) JOIN deposit_detail_hold dd  with (nolock)      
--ON m.Tranno=dd.tranno      
--WHERE CONVERT(VARCHAR,m.local_DOT,102) =CONVERT(VARCHAR,CAST(@fromDate AS DATETIME),102)       
--AND m.agentid=@agent_id AND transStatus='Hold' AND       
--CASE WHEN @branchCode IS NOT NULL THEN m.Branch_code ELSE '1' END = ISNULL(@branchCode,'1')      
--AND CASE WHEN @username IS NOT NULL THEN sempID ELSE '1' END = ISNULL(@username,'1')      
--AND dd.BankCode=@cash_id      
)l      
      
      
      
----- Cancel TXN      
--SELECT bankCode,amtPaid CollectAMT,sEmpID,m.TransStatus,m.local_DOT,m.Tranno,m.Branch_code INTO #temp_cancel      
--FROM moneysend m JOIN deposit_detail dd       
--ON m.Tranno=dd.tranno      
--WHERE CONVERT(VARCHAR,m.local_DOT,102) =CONVERT(VARCHAR,CAST(@fromDate AS DATETIME),102)       
--AND m.agentid=@agent_id AND m.TransStatus='Cancel'       
--AND dd.BankCode=@cash_id AND       
--CASE WHEN @branchCode IS NOT NULL THEN m.Branch_code ELSE '1' END = ISNULL(@branchCode,'1')      
--AND CASE WHEN @username IS NOT NULL THEN sempID ELSE '1' END = ISNULL(@username,'1')      
      
--- Deny TXN      
SELECT amtPaid CollectAMT,sEmpID,m.TransStatus,m.delDate,m.Tranno,m.Branch_code INTO #temp_deny      
FROM cancelmoneysend m with (nolock) JOIN deposit_detail_audit dd with (nolock) ON m.Tranno=dd.tranno      
WHERE CONVERT(VARCHAR,m.local_DOT,102) =CONVERT(VARCHAR,CAST(@fromDate AS DATETIME),102)       
AND m.agentid=@agent_id AND  TransStatus='Hold' AND dd.BankCode=@cash_id and      
CASE WHEN @branchCode IS NOT NULL THEN m.Branch_code ELSE '1' END = ISNULL(@branchCode,'1')      
AND CASE WHEN @username IS NOT NULL THEN sempID ELSE '1' END = ISNULL(@username,'1')      
      
--- TXN Paid      
SELECT cp.collected_amount PayAmt,cp.collected_by paidBy,cp.collected_ts paidDate,cp.tranno,cp.branch_id branch_code INTO #temp_paid      
 FROM cash_payment cp with (nolock)      
WHERE payment_type is null and CONVERT(VARCHAR,cp.collected_ts,102) =CONVERT(VARCHAR,CAST(@fromDate AS DATETIME),102)       
AND CASE WHEN @branchCode IS NOT NULL THEN cp.branch_id ELSE '1' END = ISNULL(@branchCode,'1')      
AND CASE WHEN @username IS NOT NULL THEN cp.collected_by ELSE '1' END = ISNULL(@username,'1')      
      
--- Amount Transfered Out      
SELECT stored_amount,sc.deposit_by,sc.deposit_date,sc.branch_code INTO #temp_transfered      
FROM store_cash sc with (nolock) JOIN agentbranchdetail b      
ON sc.branch_code=b.agent_branch_Code      
WHERE CONVERT(VARCHAR,sc.deposit_date,102) =CONVERT(VARCHAR,CAST(@fromDate AS DATETIME),102)       
 AND b.agentCode=@agent_id AND sc.mode='a' AND sc.deposit_by <> 'Vault'      
AND CASE WHEN @branchCode IS NOT NULL THEN sc.branch_code ELSE '1' END = ISNULL(@branchCode,'1')      
AND CASE WHEN @username IS NOT NULL THEN sc.deposit_by ELSE '1' END = ISNULL(@username,'1')      
      
--- Amount Transfered Out - Pending Not approved      
SELECT stored_amount,sc.deposit_by,sc.deposit_date,sc.branch_code INTO #temp_transfered_pending      
FROM store_cash sc with (nolock) JOIN agentbranchdetail b      
ON sc.branch_code=b.agent_branch_Code      
WHERE CONVERT(VARCHAR,sc.deposit_date,102) =CONVERT(VARCHAR,CAST(@fromDate AS DATETIME),102)       
 AND b.agentCode=@agent_id AND sc.mode='p' AND sc.deposit_by <> 'Vault'      
AND CASE WHEN @branchCode IS NOT NULL THEN sc.branch_code ELSE '1' END = ISNULL(@branchCode,'1')      
AND CASE WHEN @username IS NOT NULL THEN sc.deposit_by ELSE '1' END = ISNULL(@username,'1')      
      
      
--- Amount Transfered IN      
SELECT stored_amount,sc.approve_by,sc.approve_date,sc.branch_code INTO #temp_transfered_in      
FROM store_cash sc with (nolock) JOIN agentbranchdetail b      
ON sc.branch_code=b.agent_branch_Code AND sc.mode='a'        
WHERE CONVERT(VARCHAR,sc.approve_date,102) =CONVERT(VARCHAR,CAST(@fromDate AS DATETIME),102)       
 AND b.agentCode=@agent_id AND sc.approve_by<>'Vault'      
AND CASE WHEN @branchCode IS NOT NULL THEN sc.branch_code ELSE '1' END = ISNULL(@branchCode,'1')      
AND CASE WHEN @username IS NOT NULL THEN sc.approve_by ELSE '1' END = ISNULL(@username,'1')      
      
      
CREATE TABLE #temp_summary(      
Login_USER_ID VARCHAR(50),      
branch_code VARCHAR(50),      
Collect_Total INT,      
Collect_AMT MONEY,      
Cancel_Total INT,      
Cancel_Amount MONEY,      
Paid_Total INT,      
Paid_Amount MONEY,      
Deny_Total INT,      
Deny_Amount MONEY,      
Transfer_Out MONEY,      
Transfer_IN MONEY,      
Transfer_out_Pending MONEY       
)      
      
CREATE TABLE #temp_drill_down(      
Login_USER_ID VARCHAR(50),      
branch_code VARCHAR(50),      
TRansaction_Date DATETIME,      
Tranno VARCHAR(50),      
Transaction_Amount MONEY,      
Transaction_Type VARCHAR(50),      
Remarks VARCHAR(250)      
)      
      
IF @flag='u'      
BEGIN       
       
 INSERT #temp_summary(Login_USER_ID,Collect_Total,Collect_AMT,branch_code)      
 SeLECT sEmpID,count(*) Total_Collect,SUM(collectAmt),Branch_code FROM  #temp_collect       
 GROUP BY sEmpID,Branch_code      
-- INSERT #temp_summary(Login_USER_ID,Cancel_Total,Cancel_Amount,branch_code)      
-- SELECT sEmpID,count(*),SUM(collectAmt) Cancel_Amt,Branch_code FROM #temp_cancel      
-- GROUP BY sEmpID,Branch_code      
       
 INSERT #temp_summary(Login_USER_ID,Paid_Total,Paid_Amount,Branch_code)      
 SELECT paidBy, count(*),SUM(PayAMT) Paid_AMT,Branch_code FROM #temp_paid      
 GROUP BY paidBy,Branch_code      
       
 INSERT #temp_summary(Login_USER_ID,Deny_Total,Deny_Amount,Branch_code)      
 SELECT sEmpID,count(*),SUM(collectAmt) Cancel_Amt,Branch_code FROM #temp_deny      
 GROUP BY sEmpID,Branch_code      
      
 INSERT #temp_summary(Login_USER_ID,Transfer_Out,Branch_code)      
 SELECT Deposit_By,SUM(Stored_amount),Branch_code FROM #temp_transfered      
 GROUP BY Deposit_By,Branch_code      
      
INSERT #temp_summary(Login_USER_ID,Transfer_Out_Pending,Branch_code)      
 SELECT Deposit_By,SUM(Stored_amount),Branch_code FROM #temp_transfered_pending      
 GROUP BY Deposit_By,Branch_code      
       
 INSERT #temp_summary(Login_USER_ID,Transfer_IN,Branch_code)      
 SELECT Approve_by,SUM(Stored_amount),Branch_code FROM #temp_transfered_in      
 GROUP BY Approve_by,Branch_code      
        
  --SELECT * FROM #temp_opening      
        
  IF NOT EXISTS(SELECT * FROM #temp_opening) AND @username IS NOT NULL       
  BEGIN       
    INSERT #temp_opening(sEmpID,opening_balance)      
    VALUES(@username,0)          
  END       
  IF @username IS NULL       
   INSERT #temp_opening(sEmpID,opening_balance)      
   SELECT user_login_id,0 FROM #temp_opening o right outer join agentsub s       
   ON o.sEmpID=s.User_login_Id      
   WHERE o.sEMpID IS NULL       
   AND s.agent_branch_code=@branchCode      
           
      
  SELECT @fromDate local_dot,isNUll(o.opening_balance,0) opening_balance,      
  upper(isNUll(l.Login_USER_ID,o.sEmpID)) Login_USER_ID,      
@branchCode branch_code  ,      
Collect_Total  ,      
Collect_AMT  ,      
Cancel_Total  ,      
Cancel_Amount  ,      
Paid_Total  ,      
Paid_Amount  ,      
Deny_Total  ,      
Deny_Amount  ,      
Transfer_Out  ,      
Transfer_IN  ,      
Transfer_Out_Pending,      
(isNUll(o.opening_balance,0)+isNUll(Collect_AMT,0) +isNUll(Transfer_IN,0)) -(isNUll(Paid_Amount,0)+isNUll(Transfer_Out,0)) Balance INTO #Result FROM (      
 SELECT Login_USER_ID Login_USER_ID ,      
branch_code branch_code ,      
sum(Collect_Total) Collect_Total,      
sum(Collect_AMT) Collect_AMT,      
sum(Cancel_Total) Cancel_Total,      
sum(Cancel_Amount) Cancel_Amount,      
sum(Paid_Total)Paid_Total,      
sum(Paid_Amount)Paid_Amount,      
sum(Deny_Total)Deny_Total,      
sum(Deny_Amount)Deny_Amount,      
sum(Transfer_Out)Transfer_Out,      
sum(Transfer_IN)Transfer_IN,      
sum(Transfer_Out_Pending) Transfer_Out_Pending       
 FROM #temp_summary      
 GROUP BY Login_USER_ID,branch_code      
  ) l right outer JOIN #temp_opening o       
  ON l.login_user_id=o.sEmpID      
      
       
SELECT *,b.Branch FROM #Result r JOIN dbo.agentbranchdetail b ON r.branch_code=b.agent_branch_Code      
WHERE CASE WHEN isNUll(@display_with_balance,'n')='y' THEN isNull(balance,0) ELSE 1 END > 0      
        
END       
IF @flag='d'      
BEGIN       
       
       
      
 INSERT #temp_drill_down(Login_USER_ID,Tranno,Transaction_Amount,branch_code,Transaction_Type,TRansaction_Date)      
 SeLECT sEmpID,tranno,collectAmt,Branch_code,'Send',local_DOT FROM  #temp_collect       
      
-- INSERT #temp_drill_down(Login_USER_ID,Tranno,Transaction_Amount,branch_code,Transaction_Type,TRansaction_Date)      
-- SELECT sEmpID,tranno,collectAmt Cancel_Amt,Branch_code,'Cancel',local_DOT FROM #temp_cancel      
       
 INSERT #temp_drill_down(Login_USER_ID,Tranno,Transaction_Amount,branch_code,Transaction_Type,TRansaction_Date)      
 SELECT paidBy, tranno,PayAMT Paid_AMT,Branch_code,'Paid',paiddate FROM #temp_paid      
       
 INSERT #temp_drill_down(Login_USER_ID,Tranno,Transaction_Amount,branch_code,Transaction_Type,TRansaction_Date)      
 SELECT sEmpID,Tranno,collectAmt Cancel_Amt,Branch_code,'Deny',delDate FROM #temp_deny      
      
 INSERT #temp_drill_down(Login_USER_ID,Transaction_Amount,branch_code,Transaction_Type,TRansaction_Date)      
 SELECT Deposit_By,Stored_amount,Branch_code,'Vault Out',deposit_date FROM #temp_transfered      
      
 INSERT #temp_drill_down(Login_USER_ID,Transaction_Amount,branch_code,Transaction_Type,TRansaction_Date)      
 SELECT Approve_by,Stored_amount,Branch_code,'Vault In',approve_date FROM #temp_transfered_in      
      
      
 SELECT @fromDate local_dot,Upper(Login_USER_ID) Login_USER_ID ,      
branch_code branch_code ,      
* FROM #temp_drill_down ORDER BY Transaction_Type,transaction_Date      
       
END 