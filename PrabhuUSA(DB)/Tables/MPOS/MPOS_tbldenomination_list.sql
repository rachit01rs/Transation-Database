/****** Object:  Table [dbo].[MPOS_tbldenomination_list]    Script Date: 02/16/2014 12:57:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MPOS_tbldenomination_list]') AND type in (N'U'))
DROP TABLE [dbo].[MPOS_tbldenomination_list]
GO
/****** Object:  Table [dbo].[MPOS_tbldenomination_list]    Script Date: 02/16/2014 12:57:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[MPOS_tbldenomination_list](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[operator] [int] NULL,
	[product_key] [varchar](20) NULL,
	[denomination] [money] NULL,
	[denomination_currency] [varchar](3) NULL,
	[denomination_usd] [money] NULL,
	[country] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[sno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


