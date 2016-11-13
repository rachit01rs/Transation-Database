DROP TABLE MPOS_BalanceTransfer_Pending
GO
CREATE TABLE [dbo].[MPOS_BalanceTransfer_Pending](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[AgentCode] [varchar](50) NOT NULL,
	[Agent_Branch_Code] [varchar](50) NOT NULL,
	[Agent_User_Id] [varchar](50) NOT NULL,
	[Agent_User_login] [varchar](100) NOT NULL,	
	[MobileNo] [varchar](20) NOT NULL,
	[Amount] [money] NOT NULL,
	[Status] [varchar](500) NOT NULL,
	[DT_date] [datetime] NULL,
	[mobile_operator] [int] NULL,
	[PAYMENT_TYPE] [varchar](10) NULL,
	[DLR_date] [datetime] NULL,
	[SellingPriceCCY] [money] NULL,
	[UserCCY] [varchar](3) NULL,
	[FaceCCY] [varchar](3) NULL,
	[service_charge] [money] NULL,
	[user_commission] [money] NULL,
	[selling_price] [money] NULL,
	[userRate] [money] NULL,
	[payoutRate] [money] NULL,
	[is_CardPayment] [char](5) NULL,
	[Card_Username] [varchar](100) NULL,
	[Card_UserEmail] [varchar](50) NULL,
	[Card_UserMobileNo] [varchar](20) NULL,
	[SessionID] [varchar](100) NULL,
	[card_updatets] [datetime] NULL,
	[PaypalTranId] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[sno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


