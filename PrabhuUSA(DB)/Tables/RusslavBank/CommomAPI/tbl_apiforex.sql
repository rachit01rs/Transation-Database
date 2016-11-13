
CREATE TABLE [dbo].[tbl_apiforex](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[Send_Branch_ID] [varchar](50) NOT NULL,
	[payinCountry] [varchar](50) NULL,
	[payoutCountry] [varchar](50) NOT NULL,
	[API_payinRate_USD] [float] NULL,
	[API_payoutRate_USD] [float] NULL,
	[API_ServiceFee] [money] NULL,
	[API_Cust_Rate] [float] NULL,
	[payinCCY] [varchar](3) NULL,
	[payoutCCY] [varchar](3) NULL,
	[created_by] [varchar](50) NULL,
	[created_ts] [datetime] NULL,
	[updated_by] [varchar](50) NULL,
	[updated_ts] [datetime] NULL,
	[payoutAgentID] [int] NOT NULL,
	[Round_By] [varchar](50) NULL,
	[process_id] [varchar](200) NULL,
	[payoutAmt] [float] NULL,
	[payinAmt] [float] NULL,
	[Service_Fee] [money] NULL,
	[Collect_Amount] [money] NULL,
	[custRate] [float] NULL,
	[PartnerLocationID] [varchar](50) NULL,
	[HO_ExRate_Margin] [float] NULL,
	[Agent_ExRate_Margin] [float] NULL,
	[Agent_ServiceFee_Margin] [float] NULL,
	[isProceed] [char](1) NULL,
	[PaymentType] [varchar](50) NULL,
	[Partner_Settle_Amt] [float] NULL,
 CONSTRAINT [PK_tbl_apiforex] PRIMARY KEY CLUSTERED 
(
	[sno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF