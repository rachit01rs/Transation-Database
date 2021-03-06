
/****** Object:  Table [dbo].[report_writer_clm]    Script Date: 03/22/2013 16:51:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
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