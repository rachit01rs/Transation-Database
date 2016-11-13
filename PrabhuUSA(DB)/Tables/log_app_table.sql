

CREATE TABLE [dbo].[log_app_table](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[log_date] [datetime] NULL,
	[log_user] [varchar](50) NULL,
	[visit_file] [varchar](1000) NULL,
	[visit_parameter] [varchar](5000) NULL,
	[dc_info] [varchar](250) NULL,
	[ip_address] [varchar](50) NULL,
	[tranno] [varchar](50) NULL,
	[refno] [varchar](50) NULL,
	[user_type] [varchar](50) NULL,
 CONSTRAINT [PK_log_app_table] PRIMARY KEY CLUSTERED 
(
	[sno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


