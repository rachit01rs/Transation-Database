
/****** Object:  Table [dbo].[report_func_user]    Script Date: 03/22/2013 16:50:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[report_func_user](
	[sno] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[function_id] [int] NULL,
	[user_id] [varchar](50) NULL,
	[role_id] [int] NULL,
 CONSTRAINT [PK_report_func_user] PRIMARY KEY CLUSTERED 
(
	[sno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[report_func_user]  WITH CHECK ADD  CONSTRAINT [FK_report_func_user_application_role] FOREIGN KEY([role_id])
REFERENCES [dbo].[application_role] ([role_id])
GO
ALTER TABLE [dbo].[report_func_user] CHECK CONSTRAINT [FK_report_func_user_application_role]
GO
ALTER TABLE [dbo].[report_func_user]  WITH CHECK ADD  CONSTRAINT [FK_report_func_user_report_writer_header] FOREIGN KEY([function_id])
REFERENCES [dbo].[report_writer_header] ([report_id])
GO
ALTER TABLE [dbo].[report_func_user] CHECK CONSTRAINT [FK_report_func_user_report_writer_header]