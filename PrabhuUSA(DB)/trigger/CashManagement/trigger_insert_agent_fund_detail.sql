

/****** Object:  Trigger [trigger_insert_agent_fund_detail]    Script Date: 10/21/2013 11:22:11 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trigger_insert_agent_fund_detail]'))
DROP TRIGGER [dbo].[trigger_insert_agent_fund_detail]
GO


/****** Object:  Trigger [dbo].[trigger_insert_agent_fund_detail]    Script Date: 10/21/2013 11:22:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE trigger [dbo].[trigger_insert_agent_fund_detail] on [dbo].[agent_fund_detail]
FOR  insert
AS
IF UPDATE(approve_by)
BEGIN 
	UPDATE agentbranchdetail
	SET Branch_vault_Balance = case when i.invoice_type='m'	then isNUll(Branch_vault_Balance,0) + i.local_amt 
	ELSE isNUll(Branch_vault_Balance,0) - i.local_amt 	END, 
	currentBalance=CASE WHEN i.teller_transfer='y' THEN currentBalance ELSE 
		case when i.invoice_type='m'	then isNUll(currentBalance,0) + i.local_amt  
	ELSE isNUll(currentBalance,0) - i.local_amt 	END
	             END 
	FROM agentbranchdetail b JOIN agent_function af ON af.agent_Id=b.agentCode
	JOIN INSERTED i ON b.agent_branch_Code=i.branch_code AND i.sender_bankID=af.cash_vault
	WHERE i.approve_by IS NOT NULL 

END 


GO


