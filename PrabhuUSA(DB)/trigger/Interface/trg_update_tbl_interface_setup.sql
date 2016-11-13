IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_update_tbl_interface_setup]'))
DROP TRIGGER [dbo].[trg_update_tbl_interface_setup]
GO

/****** Object:  Trigger [dbo].[trg_update_tbl_interface_setup]    Script Date: 02/18/2014 12:27:58 ******/
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:  Sunita Shrestha
-- Create date: 18th february 2014
-- Purpose: created trigger trg_update_tbl_interface_setup.
-- =============================================
SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[trg_update_tbl_interface_setup] ON [dbo].[tbl_interface_setup]
FOR UPDATE 
AS
INSERT INTO tbl_interface_setup_audit
(
	-- sno -- this column value is auto-generated,
	[sno],
	[agentcode],
	[mode],
	[enable_update_remote_DB] ,
	[remote_db],
	[external_agent_id],
	[external_branch_id],
	[Remarks],
	[external_agent_name],
	[external_branch_name],
	[PartnerAgentcode],
	[createdTS],
	[updateTS],
	[createdBY] ,
	[updateBY],
	[user_action]
)
SELECT 
	[sno],
	[agentcode],
	[mode],
	[enable_update_remote_DB] ,
	[remote_db],
	[external_agent_id],
	[external_branch_id],
	[Remarks] [varchar],
	[external_agent_name],
	[external_branch_name],
	[PartnerAgentcode],
	GETDATE(),
	[updateTS],
	[createdBY] ,
	[updateBY],
	'UPDATE'
FROM INSERTED
GO


