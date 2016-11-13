/****** Object:  Table [dbo].[MPOS_tbldenomination]    Script Date: 02/16/2014 12:54:28 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MPOS_tbldenomination]') AND type in (N'U'))
DROP TABLE [dbo].[MPOS_tbldenomination]
GO

/****** Object:  Table [dbo].[MPOS_tbldenomination]    Script Date: 02/16/2014 12:54:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[MPOS_tbldenomination](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[receiving_country] [varchar](100) NULL,
	[payout_amount] [money] NULL,
	[total_charge] [money] NULL,
	[gross_sending_amount] [money] NULL,
	[agent_commission] [money] NULL,
	[payout_currency] [varchar](10) NULL,
	[sending_country] [varchar](100) NULL,
	[sending_currency] [varchar](10) NULL,
	[operator_sno] [int] NULL,
	[denomination_sno] [int] NULL,
	[denomination_key] [varchar](15) NULL,
	[updated_by] [varchar](100) NULL,
	[updated_ts] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[sno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


