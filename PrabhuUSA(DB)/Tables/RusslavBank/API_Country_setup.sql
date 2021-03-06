
CREATE TABLE [dbo].[API_Country_setup](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[country] [varchar](100) NULL,
	[country_Code] [varchar](50) NULL,
	[currencyType] [varchar](50) NULL,
	[enable_send] [char](1) NULL,
	[ex_rate_margin] [money] NULL,
	[sCharge_margin] [money] NULL,
	[API_Agent] [varchar](50) NULL,
	[API_comm] [money] NULL,
	[API_comm_type] [char](1) NULL,
	[update_by] [varchar](50) NULL,
	[update_ts] [datetime] NULL
) ON [PRIMARY]
SET ANSI_PADDING OFF
ALTER TABLE [dbo].[API_Country_setup] ADD [country_Code3] [varchar](3) NULL

GO
SET ANSI_PADDING OFF