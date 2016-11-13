CREATE TABLE [dbo].[temp_forex_print](
	[ExType] [varchar](50) NULL,
	[session_id] [varchar](200) NULL,
	[sno] [int] NOT NULL,
	[currencyId] [int] NULL,
	[idType] [char](1) NULL,
	[NewBuyRate] [numeric](19, 10) NULL,
	[premium] [money] NULL,
	[Current_SETTLEMENT] [numeric](26, 10) NULL,
	[CURRENT_MARGIN] [float] NULL,
	[Current_Customer] [float] NULL,
	[agent_premium_send] [money] NULL,
	[ExchangeRate] [float] NULL,
	[margin_sending_agent] [float] NULL,
	[SENDING_CUST_EXCHANGERATE] [float] NULL,
	[SEND_VS_PAYOUT_SETTMENT] [float] NULL,
	[SEND_VS_Payout_Customer] [float] NULL,
	[SEND_VS_Payout_MARGIN] [float] NULL,
	[roundby] [int] NULL,
	[sender] [varchar](150) NULL,
	[receiveCountry] [varchar](150) NULL,
	[receiver] [varchar](150) NULL,
	[alt_cost] [money] NULL,
	[alt_premium] [money] NULL,
	[Payout_Currency_Code] [varchar](5) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF