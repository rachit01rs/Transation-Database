IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trigger_insert_agent_branch_commission]'))
DROP TRIGGER [dbo].[trigger_insert_agent_branch_commission]
GO

/****** Object:  Trigger [dbo].[trigger_insert_agent_branch_commission]    Script Date: 04/29/2014 13:38:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[trigger_insert_agent_branch_commission] ON [dbo].[agent_branch_commission]
FOR INSERT
AS 
INSERT INTO [agent_branch_commission_audit]
           ([agent_branch_code]
           ,[country]
           ,[commission_value]
           ,[commission_type]
           ,[send_commission_value]
           ,[send_commission_type]
           ,[updated_by]
           ,[updated_date]
           ,[agent_code]
           ,[comm_currency_Type]
           ,[user_action]
           ,[payment_mode]
		   ,[min_amount]
		   ,[max_amount]
		   ,[paidValueCCY]
		   ,[sendAgentCode] )
     SELECT [agent_branch_code]
           ,[country]
           ,[commission_value]
           ,[commission_type]
           ,[send_commission_value]
           ,[send_commission_type]
           ,[updated_by]
           ,[updated_date]
           ,[agent_code]
           ,[comm_currency_Type]
           ,'Inserted'
           ,[payment_mode]
		   ,[min_amount]
		   ,[max_amount]
		   ,[paidValueCCY]
		   ,[sendAgentCode]  FROM Inserted


GO


