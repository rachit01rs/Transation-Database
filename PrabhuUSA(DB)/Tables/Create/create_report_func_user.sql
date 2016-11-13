

/*  
** Database    : PrabhuUSA
** Object      : TABLE report_func_user
** Purpose     : Create TABLE report_func_user
** Author      : Puja Ghaju 
** Date        : 12 September 2013  
*/ 



IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_report_func_user_application_role]') AND parent_object_id = OBJECT_ID(N'[dbo].[report_func_user]'))
ALTER TABLE [dbo].[report_func_user] DROP CONSTRAINT [FK_report_func_user_application_role]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_report_func_user_report_writer_header]') AND parent_object_id = OBJECT_ID(N'[dbo].[report_func_user]'))
ALTER TABLE [dbo].[report_func_user] DROP CONSTRAINT [FK_report_func_user_report_writer_header]
GO



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[report_func_user]') AND type in (N'U'))
DROP TABLE [dbo].[report_func_user]
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
GO


