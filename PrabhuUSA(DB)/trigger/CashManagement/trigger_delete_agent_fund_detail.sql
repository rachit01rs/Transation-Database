/****** Object:  Trigger [trigger_delete_agent_fund_detail]    Script Date: 10/21/2013 11:23:05 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trigger_delete_agent_fund_detail]'))
DROP TRIGGER [dbo].[trigger_delete_agent_fund_detail]
GO

/****** Object:  Trigger [dbo].[trigger_delete_agent_fund_detail]    Script Date: 10/21/2013 11:23:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE trigger [dbo].[trigger_delete_agent_fund_detail] on [dbo].[agent_fund_detail]
FOR  DELETE
AS
	UPDATE agentbranchdetail
	SET Branch_vault_Balance = case when i.invoice_type='m'	then isNUll(Branch_vault_Balance,0) - i.local_amt 
	ELSE isNUll(Branch_vault_Balance,0) + i.local_amt 	END ,
	
	currentBalance=CASE WHEN i.teller_transfer='y' THEN currentBalance ELSE 
		case when i.invoice_type='m'	then isNUll(currentBalance,0) - i.local_amt  
	ELSE isNUll(currentBalance,0) + i.local_amt 	END
	             END 
	             
	FROM agentbranchdetail b JOIN agent_function af ON af.agent_Id=b.agentCode
	JOIN Deleted i ON b.agent_branch_Code=i.branch_code AND i.sender_bankID=af.cash_vault
	WHERE i.approve_by IS NOT NULL 

	UPDATE agentsub
	SET current_balance = case when i.invoice_type='m'	then isNUll(current_balance,0) + i.local_amt 
	ELSE isNUll(current_balance,0) - i.local_amt 	END 
	FROM agentsub s JOIN DELETED i ON s.user_login_id=i.staff_id
	JOIN agentbranchdetail b ON b.agent_branch_code=s.agent_branch_code
	JOIN agent_function af ON af.agent_Id=b.agentCode AND i.sender_bankID=af.cash_vault
	WHERE i.teller_transfer='y'
	
INSERT INTO [agent_fund_detail_audit]
           ([fund_id]
		   ,[Sender_BankID]
           ,[DOT]
           ,[Local_Amt]
           ,[Dollar_amt]
           ,[staff_id]
           ,[remarks]
           ,[xRate]
           ,[invoice_no]
           ,[AgentCode]
           ,[invoice_type]
           ,[branch_code]
		   ,[user_action]
		   ,[update_by]
		   ,[update_ts])
select [fund_id]
		   ,[Sender_BankID]
           ,[DOT]
           ,[Local_Amt]
           ,[Dollar_amt]
           ,[staff_id]
           ,[remarks]
           ,[xRate]
           ,[invoice_no]
           ,[AgentCode]
           ,[invoice_type]
           ,[branch_code]
		   ,'DELETE'
		   ,[staff_id]
		   ,getdate() from deleted

GO


