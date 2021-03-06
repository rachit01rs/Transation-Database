
/****** Object:  Table [dbo].[report_writer_header]    Script Date: 03/22/2013 16:52:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[report_writer_header](
	[report_id] [int] IDENTITY(1,1) NOT NULL,
	[report_name] [varchar](150) NOT NULL,
	[vw_sql] [varchar](5000) NOT NULL,
	[calc_total] [char](1) NULL,
 CONSTRAINT [PK_report_writer_header] PRIMARY KEY CLUSTERED 
(
	[report_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF