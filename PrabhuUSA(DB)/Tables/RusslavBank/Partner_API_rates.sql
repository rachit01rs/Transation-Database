
CREATE TABLE [dbo].[Partner_API_rates](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[sendCountry] [varchar](50) NULL,
	[payoutCountry] [varchar](50) NULL,
	[sendAmt] [money] NULL,
	[sendCurrency] [varchar](50) NULL,
	[payoutAmt] [money] NULL,
	[ExchangeRate] [float] NULL,
	[Ho_dollar_rate] [float] NULL,
	[today_dollar_rate] [float] NULL,
	[agent_ex_gain] [float] NULL,
	[Gain_amt] [float] NULL,
	[agent_rate] [float] NULL,
	[customer_rate] [float] NULL,
	[Dot] [datetime] NULL,
	[confirm_process_id] [varchar](200) NULL,
	[is_used] [varchar](10) NULL,
	[paidamt] [money] NULL,
	[paidCtype] [varchar](20) NULL,
	[send_USDrate] [float] NULL,
	[sCharge] [money] NULL,
	[dollarAmt] [float] NULL,
	[pay_actualUSD] [float] NULL,
	[netAmt_Send] [float] NULL,
	[sChargeUSD] [float] NULL,
	[HO_EX_margin] [float] NULL,
 CONSTRAINT [PK__CIMB_API_rates__3BC25228] PRIMARY KEY CLUSTERED 
(
	[sno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF