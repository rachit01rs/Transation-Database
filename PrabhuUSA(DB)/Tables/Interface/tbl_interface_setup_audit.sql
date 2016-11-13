IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbl_interface_setup_audit]') AND type in (N'U'))
DROP TABLE [dbo].[tbl_interface_setup_audit]
GO

/****** Object:  Table [dbo].[tbl_interface_setup_audit]    Script Date: 02/18/2014 11:48:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:  Sunita Shrestha
-- Create date: 18th february 2014
-- Purpose: created table tbl_interface_setup_audit.
-- =============================================
SET ANSI_PADDING OFF
GO

CREATE TABLE [dbo].[tbl_interface_setup_audit](
	[access_id] [bigint]IDENTITY(1,1) NOT NULL,
	[sno] [int]  NOT NULL,
	[agentcode] [varchar](50) NOT NULL,
	[mode] [varchar](50) NOT NULL,
	[enable_update_remote_DB] [char](1) NULL,
	[remote_db] [varchar](200) NULL,
	[external_agent_id] [varchar](50) NULL,
	[external_branch_id] [varchar](50) NULL,
	[Remarks] [varchar](500) NULL,
	[external_agent_name] [varchar](200) NULL,
	[external_branch_name] [varchar](200) NULL,
	[PartnerAgentcode] [varchar](50) NULL,
	[PayoutCountry] [varchar](100) NULL,
	[createdTS] [datetime] NULL,
	[updateTS] [datetime] NULL,
	[createdBY] [varchar](50) NULL,
	[updateBY] [varchar](50) NULL,
	[user_action] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


