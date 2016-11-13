
/*  
** Database    : PrabhuUSA
** Object      : TABLE report_writer_header
** Purpose     : Create TABLE report_writer_header
** Author      : Puja Ghaju 
** Date        : 12 September 2013  
*/ 


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[report_writer_header]') AND type in (N'U'))
DROP TABLE [dbo].[report_writer_header]
GO


CREATE TABLE [dbo].[report_writer_header](
	[report_id] [int] IDENTITY(1,1) NOT NULL,
	[report_name] [varchar](150) NOT NULL,
	[vw_sql] [varchar](5000) NOT NULL,
	[calc_total] [char](1) NULL,
	[main_menu] [varchar](50) NULL,
	[main_menu_agent] [varchar](50) NULL,
	[enable_paging] [char](1) NULL,
 CONSTRAINT [PK_report_writer_header] PRIMARY KEY CLUSTERED 
(
	[report_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


