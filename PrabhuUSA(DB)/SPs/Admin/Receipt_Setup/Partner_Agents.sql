

/****** Object:  Table [dbo].[Partner_Agents]    Script Date: 02/04/2013 10:25:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dbo].[Partner_Agents](
	[Sno] [int] IDENTITY(1,2) NOT NULL,
	[PartnerAgentCode] [varchar](50) NOT NULL,
	[Ext_AgentCode] [varchar](50) NOT NULL,
	[Ext_AgentName] [varchar](50) NOT NULL,
	[Ext_AgentCountry] [varchar](50) NOT NULL,
	[Ext_AgentCan] [varchar](50) NOT NULL,
	[Ext_AgentCurrency] [char](3) NOT NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_Partner_Agents] PRIMARY KEY CLUSTERED 
(
	[Sno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[Partner_Agents]  WITH CHECK ADD  CONSTRAINT [FK_Partner_Agents_agentDetail] FOREIGN KEY([PartnerAgentCode])
REFERENCES [dbo].[agentDetail] ([agentCode])
GO

ALTER TABLE [dbo].[Partner_Agents] CHECK CONSTRAINT [FK_Partner_Agents_agentDetail]
GO


