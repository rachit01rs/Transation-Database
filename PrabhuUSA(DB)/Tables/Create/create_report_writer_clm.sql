
/*  
** Database    : PrabhuUSA
** Object      : TABLE report_writer_clm
** Purpose     : Create TABLE report_writer_clm
** Author      : Puja Ghaju 
** Date        : 12 September 2013  
*/ 


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[report_writer_clm]') AND type in (N'U'))
DROP TABLE [dbo].[report_writer_clm]
GO


CREATE TABLE [dbo].[report_writer_clm](
	[report_clm_id] [int] IDENTITY(1,1) NOT NULL,
	[report_id] [int] NOT NULL,
	[clm_name_id] [varchar](150) NOT NULL,
	[clm_label] [varchar](150) NOT NULL,
	[clm_type] [varchar](50) NOT NULL,
	[clm_source] [varchar](1000) NULL,
	[clm_sequence] [int] NULL,
	[null_allow] [char](1) NULL,
 CONSTRAINT [PK_report_writer_clm] PRIMARY KEY CLUSTERED 
(
	[report_clm_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


