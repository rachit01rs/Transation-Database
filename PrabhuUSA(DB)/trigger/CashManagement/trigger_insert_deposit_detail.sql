/****** Object:  Trigger [trigger_insert_deposit_detail]    Script Date: 10/21/2013 13:37:43 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trigger_insert_deposit_detail]'))
DROP TRIGGER [dbo].[trigger_insert_deposit_detail]
GO
/****** Object:  Trigger [dbo].[trigger_insert_deposit_detail]    Script Date: 10/21/2013 13:37:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trigger_insert_deposit_detail] ON [dbo].[deposit_detail] 
	FOR INSERT 
	AS
	INSERT INTO dbo.tbl_moneysend_log
	        ( refno, amount, current_balance )
	SELECT m.refno,i.amtpaid,s.current_balance 	FROM moneysend m WITH (NOLOCK) join INSERTED i 
	ON m.Tranno=i.tranno 
	JOIN agentDetail ad  WITH (NOLOCK) ON ad.agentCode=m.agentid 
	JOIN agentbranchdetail a  WITH (NOLOCK) ON a.agentCode=ad.agentcode
	JOIN agentsub s  WITH (NOLOCK) ON s.agent_branch_code=a.agent_branch_Code 
	AND s.User_login_Id=m.sEmpID
	JOIN agent_function af ON af.agent_Id=m.agentid 
	AND af.cash_ledger_id=i.bankcode
	WHERE ad.isUniteller_Agent='y'

	UPDATE agentsub SET current_balance = isNUll(s.current_balance,0)+i.amtpaid
	FROM moneysend m WITH (NOLOCK) join INSERTED i 
	ON m.Tranno=i.tranno 
	JOIN agentDetail ad  WITH (NOLOCK) ON ad.agentCode=m.agentid 
	JOIN agentbranchdetail a  WITH (NOLOCK) ON a.agentCode=ad.agentcode
	JOIN agentsub s  WITH (NOLOCK) ON s.agent_branch_code=a.agent_branch_Code 
	AND s.User_login_Id=m.sEmpID
	JOIN agent_function af ON af.agent_Id=m.agentid 
	AND af.cash_ledger_id=i.bankcode
	WHERE ad.isUniteller_Agent='y'

	--UPDATE agentbranchdetail SET currentBalance = isNUll(a.currentBalance,0)+i.amtpaid
	--FROM moneysend m  WITH (NOLOCK) join INSERTED i 
	--ON m.Tranno=i.tranno 
	--JOIN agentDetail ad  WITH (NOLOCK) ON ad.agentCode=m.agentid 
	--JOIN agentbranchdetail a  WITH (NOLOCK) ON a.agentCode=ad.agentcode AND m.Branch_code=a.agent_branch_Code
	--JOIN agent_function af  WITH (NOLOCK) ON af.agent_Id=m.agentid 
	--AND af.cash_ledger_id=i.bankcode
	--WHERE ad.isUniteller_Agent='y'

GO


