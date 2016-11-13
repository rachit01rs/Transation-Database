DROP PROC spa_UnitellerBankReport
GO
----set ANSI_NULLS ON  
----set QUOTED_IDENTIFIER ON  
----go  
----  
----  
----  
----/************************************************************  
---- * Code formatted by SoftTree SQL Assistant © v4.6.12  
---- * Time: 3/12/2012 4:56:22 PM  
---- ************************************************************/  
------SELECT  * FROM cash_payment cp ORDER BY 1 desc  
------spa_UnitellerBankReport 'u','10100000','klanoop','10100500','2012-04-22'        
CREATE PROCEDURE [dbo].[spa_UnitellerBankReport]  
 @flag CHAR(1) = NULL ,  
 @agent_id VARCHAR(50),  
 @username VARCHAR(100) = NULL ,  
 @branchCode VARCHAR(100) = NULL ,  
 @fromDate VARCHAR(100) = NULL  
  
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
  
DECLARE @cash_id VARCHAR(50),@start_opening_balance DATETIME   
SET @start_opening_balance ='2012-04-25'  
  
  
SELECT @cash_id=af.cash_ledger_id  
  FROM agent_function af WHERE af.agent_Id=@agent_id  
  
  --- Collect Amt  
SELECT bankCode,amtPaid CollectAMT,sEmpID,m.TransStatus,m.local_DOT,m.Tranno,m.Branch_code,dd.depositDOT,  
m.SenderName,m.ReceiverName,bas.BankName,m.rBankName  
 INTO #temp_collect  
FROM moneysend m JOIN deposit_detail dd   
ON m.Tranno=dd.tranno  
JOIN BankAgentSender bas ON bas.AgentCode=dd.BankCode  
WHERE CONVERT(VARCHAR,m.local_DOT,102) =CONVERT(VARCHAR,CAST(@fromDate AS DATETIME),102)   
AND CONVERT(VARCHAR,dd.depositDOT,102) = CONVERT(VARCHAR,CAST(@fromDate AS DATETIME),102)   
AND m.agentid=@agent_id AND    
CASE WHEN @branchCode IS NOT NULL THEN m.Branch_code ELSE '1' END = ISNULL(@branchCode,'1')  
AND CASE WHEN @username IS NOT NULL THEN sempID ELSE '1' END = ISNULL(@username,'1')  
AND dd.BankCode not in (@cash_id)  
AND m.TransStatus NOT IN ('Hold')  
---Pending Bank  
SELECT bankCode,amtPaid CollectAMT,sEmpID,m.TransStatus,m.local_DOT,m.Tranno,m.Branch_code,dd.depositDOT,  
m.SenderName,m.ReceiverName,bas.BankName,m.rBankName   
INTO #temp_collect_pending  
FROM moneysend m JOIN deposit_detail dd   
ON m.Tranno=dd.tranno  
JOIN BankAgentSender bas ON bas.AgentCode=dd.BankCode  
WHERE CONVERT(VARCHAR,m.local_DOT,102)= CONVERT(VARCHAR,CAST(@fromDate AS DATETIME),102)   
AND CONVERT(VARCHAR,dd.depositDOT,102) < CONVERT(VARCHAR,CAST(@fromDate AS DATETIME),102)   
AND m.agentid=@agent_id AND    
CASE WHEN @branchCode IS NOT NULL THEN m.Branch_code ELSE '1' END = ISNULL(@branchCode,'1')  
AND CASE WHEN @username IS NOT NULL THEN sempID ELSE '1' END = ISNULL(@username,'1')  
AND dd.BankCode not in (@cash_id)  
AND m.TransStatus NOT IN ('Hold')  
----- Cancel TXN  
---  
  
CREATE TABLE #temp_summary(  
Login_USER_ID VARCHAR(50),  
branch_code VARCHAR(50),  
Collect_Total INT,  
Collect_AMT MONEY,  
Pending_Total INT,  
Pending_Amount MONEY  
)  
  
  
  
IF @flag='u'  
BEGIN   
   
 INSERT #temp_summary(Login_USER_ID,Collect_Total,Collect_AMT,branch_code)  
 SeLECT sEmpID,count(*) Total_Collect,SUM(collectAmt),Branch_code FROM  #temp_collect   
 GROUP BY sEmpID,Branch_code  
  
   
 INSERT #temp_summary(Login_USER_ID,Pending_Total,Pending_Amount,Branch_code)  
 SELECT sEmpID, count(*),SUM(collectAmt) collectAmt,Branch_code FROM #temp_collect_pending  
 GROUP BY sEmpID,Branch_code  
   
  
 SELECT @fromDate local_dot,Login_USER_ID ,  
branch_code branch_code ,  
sum(isNUll(Collect_Total,0)) Collect_Total,  
sum(Collect_AMT) Collect_AMT,  
sum(isNull(Pending_Total,0)) Pending_Total,  
sum(isNUll(Pending_Amount,0)) Pending_Amount,  
SUM(isNUll(Collect_AMT,0)+ isnull(Pending_Amount,0)) Balance  
 FROM #temp_summary  
 GROUP BY Login_USER_ID,branch_code  
  
    
END   
IF @flag='d' -- user wise Detail  
BEGIN   
   
 CREATE TABLE #temp_detail(  
Login_USER_ID VARCHAR(50),  
branch_code VARCHAR(50),  
Tranno INT,  
senderName VARCHAR(100),  
ReceiverName VARCHAR(100),  
Local_Dot DATETIME,  
DepositDot DATETIME,  
DepositBankName VARCHAR(100),  
PayoutBank VARCHAR(150),  
Collect_AMT MONEY,  
Trans_Type VARCHAR(50)  
 )  
   
 INSERT #temp_detail(Login_USER_ID,branch_code,Tranno,senderName,ReceiverName,Local_Dot,  
 DepositDot,DepositBankName,PayoutBank,Collect_AMT,Trans_Type)  
 SELECT ms.SEmpID,ms.Branch_code,ms.Tranno,ms.SenderName,ms.ReceiverName,ms.local_DOT,ms.depositDot,  
 ms.BankName,ms.rBankName,ms.CollectAMT,'Same Day'  
   FROM #temp_collect ms   
     
 UNION ALL   
 SELECT ms.SEmpID,ms.Branch_code,ms.Tranno,ms.SenderName,ms.ReceiverName,ms.local_DOT,ms.depositDot,  
 ms.BankName,ms.rBankName,ms.CollectAMT,'Prev Day'  
   FROM #temp_collect_pending ms  
   
  SELECT * FROM #temp_detail ORDER BY DepositBankName,Local_Dot  
  
END  