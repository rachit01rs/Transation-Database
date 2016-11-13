
/****** Object:  Trigger [tr_depositdetail_del]    Script Date: 10/21/2013 11:48:28 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[tr_depositdetail_del]'))
DROP TRIGGER [dbo].[tr_depositdetail_del]
GO

/****** Object:  Trigger [dbo].[tr_depositdetail_del]    Script Date: 10/21/2013 11:48:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



create TRIGGER [dbo].[tr_depositdetail_del] ON [dbo].[deposit_detail] 
FOR DELETE 
AS
UPDATE agentsub SET current_balance = isNUll(s.current_balance,0)-i.amtpaid
FROM cancelmoneysend m join Deleted i 
ON m.Tranno=i.tranno 
JOIN agentDetail ad ON ad.agentCode=m.agentid 
JOIN agentbranchdetail a ON a.agentCode=ad.agentcode AND m.Branch_code=a.agent_branch_Code
JOIN agentsub s ON s.agent_branch_code=a.agent_branch_Code 
AND s.User_login_Id=m.sEmpID
JOIN agent_function af ON af.agent_Id=m.agentid 
AND af.cash_ledger_id=i.bankcode
WHERE ad.isUniteller_Agent='y'

--UPDATE agentbranchdetail SET currentBalance = isNUll(a.currentBalance,0)-i.amtpaid
--FROM cancelmoneysend m join Deleted i 
--ON m.Tranno=i.tranno 
--JOIN agentDetail ad ON ad.agentCode=m.agentid 
--JOIN agentbranchdetail a ON a.agentCode=ad.agentcode AND m.Branch_code=a.agent_branch_Code
--JOIN agent_function af ON af.agent_Id=m.agentid 
--AND af.cash_ledger_id=i.bankcode
--WHERE ad.isUniteller_Agent='y'

INSERT INTO [deposit_detail_audit]
           ([sno]
           ,[BankCode]
           ,[deposit_detail1]
           ,[deposit_detail2]
           ,[amtPaid]
           ,[depositDOT]
           ,[tranno]
           ,[pending_id]
           ,[bank_serial_no]
           ,[update_ts]
			--,delete_ts
)
   SELECT [sno]
           ,[BankCode]
           ,[deposit_detail1]
           ,[deposit_detail2]
           ,[amtPaid]
           ,[depositDOT]
           ,[tranno]
           ,[pending_id]
           ,[bank_serial_no]
           ,[update_ts]
			--,getdate()
FROM deleted







GO


