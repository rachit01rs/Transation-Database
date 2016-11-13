
GO

/****** Object:  Table [dbo].[ArchiveUnitellerCash]    Script Date: 01/21/2014 16:05:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[ArchiveUnitellerCash](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[sEmpID] [varchar](50) NULL,
	[opening_balance] [money] NULL,
	[archive_date] [datetime] NULL,
	[process_id] [varchar](150) NULL,
 CONSTRAINT [PK_UnitellerCashArchive] PRIMARY KEY CLUSTERED 
(
	[sno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


