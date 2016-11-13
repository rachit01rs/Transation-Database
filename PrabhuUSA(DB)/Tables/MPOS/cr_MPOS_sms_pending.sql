CREATE TABLE [dbo].[MPOS_sms_pending](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[AgentCode] [varchar](50) NOT NULL,
	[Agent_Branch_Code] [varchar](50) NOT NULL,
	[Agent_User_Id] [varchar](50) NOT NULL,
	[Agent_User_login] [varchar](100) NOT NULL,	
	[client_mobile] [varchar](50) NULL,
	[client_text] [varchar](500) NULL,
	[server_response] [varchar](100) NULL,
	[orginated_date] [datetime] NULL,
	[status] [varchar](100) NULL,
	[sender_id] [varchar](100) NULL,
	[iremit_log] [char](1) NULL,
	[priority] [int] NULL,
	[paging_no] [int] NULL,
	[rate] [money] NULL,
 CONSTRAINT [PK_MPOS_sms_pending] PRIMARY KEY CLUSTERED 
(
	[sno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


