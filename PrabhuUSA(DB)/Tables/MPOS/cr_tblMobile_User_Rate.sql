DROP TABLE MPOS_tblMobile_User_Rate
GO
CREATE TABLE [dbo].[MPOS_tblMobile_User_Rate](
	[user_deno_sno] [int] IDENTITY(1,1) NOT NULL,
	[agent_deno_sno] [varchar](50) NULL,
	[agentCode] [int] NULL,
	[agentBranchCode] [int] NULL,
	[user_id] [int] NULL,
	[selling_price] [money] NULL,
	[service_charge] [money] NULL,
	[user_commission] [money] NULL,
	[discount] [money] NULL,
PRIMARY KEY CLUSTERED 
(
	[user_deno_sno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


