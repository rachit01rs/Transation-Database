
CREATE TABLE [dbo].[tblcountry](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[country_name] [varchar](100) NULL,
	[Number] [varchar](10) NULL,
	[ISO2] [char](3) NULL,
	[ISO3] [char](4) NULL,
	[Currency_code] [varchar](4) NULL,
	[vendor] [varchar](50) NULL,
	[provider_id] [int] NULL,
 CONSTRAINT [PK_tblcountry] PRIMARY KEY CLUSTERED 
(
	[sno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


