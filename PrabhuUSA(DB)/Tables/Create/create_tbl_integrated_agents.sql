
/*  
** Database    : PrabhuUSA
** Object      : TABLE tbl_integrated_agents
** Purpose     : Create TABLE tbl_integrated_agents
** Author      : Puja Ghaju 
** Date        : 12 September 2013  
*/ 


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbl_integrated_agents]') AND type in (N'U'))
DROP TABLE [dbo].[tbl_integrated_agents]
GO


CREATE TABLE [dbo].[tbl_integrated_agents](
	[sno] [int] IDENTITY(1,2) NOT NULL,
	[agentcode] [varchar](50) NULL,
	[agentName] [varchar](200) NULL,
	[paymentType] [varchar](100) NULL,
	[approved_url] [varchar](250) NULL,
	[send_url] [varchar](200) NULL,
	[pay_url] [varchar](200) NULL,
	[cancel_url] [varchar](200) NULL,
	[amend_url] [varchar](200) NULL,
	[statu_check_url] [varchar](200) NULL,
	[isEnable] [char](1) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


