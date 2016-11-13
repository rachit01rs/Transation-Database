GO

/****** Object:  Table [dbo].[Partner_Branch]    Script Date: 02/04/2013 10:38:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Partner_Branch](
	[sno] [int] IDENTITY(1,2) NOT NULL,
	[PartnerAgentCode] [varchar](50) NOT NULL,
	[Ext_AgentCode] [varchar](50) NOT NULL,
	[Ext_Agent_Branch_code] [varchar](50) NOT NULL,
	[Ext_BranchName] [varchar](150) NOT NULL,
	[Ext_BranchAddress] [varchar](200) NULL,
	[Ext_BranchCity] [varchar](50) NULL,
	[Ext_BranchState] [varchar](50) NULL,
	[Ext_BranchTelephone] [varchar](50) NULL,
	[Ext_BranchType] [varchar](50) NULL,
	[Ext_branch_group] [varchar](200) NULL,
 CONSTRAINT [PK_Partner_Branch] PRIMARY KEY CLUSTERED 
(
	[sno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


