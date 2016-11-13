/****** Object:  Table [dbo].[MPOS_BalanceTransfer]    Script Date: 02/16/2014 12:48:14 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MPOS_BalanceTransfer]') AND type in (N'U'))
DROP TABLE [dbo].[MPOS_BalanceTransfer]
GO

/****** Object:  Table [dbo].[MPOS_BalanceTransfer]    Script Date: 02/16/2014 12:48:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[MPOS_BalanceTransfer](
	[sno] [int] IDENTITY(100000,1) NOT NULL,
	[refno] [varchar](20) NOT NULL,
	[AgentCode] [varchar](50) NOT NULL,
	[Agent_Branch_Code] [varchar](50) NOT NULL,
	[Agent_User_login] [varchar](100) NOT NULL,
	[MobileNo] [varchar](20) NOT NULL,
	[Status] [varchar](500) NULL,
	[DT_date] [datetime] NULL,
	[mobile_operator] [int] NULL,
	[denomination_sno] [int] NULL,
	[denomination] [money] NULL,
	[DenoCCY] [varchar](3) NULL,
	[SendingCurrency] [varchar](3) NULL,
	[gross_sending_amount] [money] NULL,
	[total_charge] [money] NULL,
	[agent_commission] [money] NULL,
	[denomination_usd] [money] NULL,
	[actionkey] [varchar](10) NULL,
	[Operator_name] [varchar](100) NULL,
	[roundby] [int] NULL,
	[sendingCountry] [varchar](200) NULL,
	[receivingCountry] [varchar](200) NULL,
	[DLR_Response] [nvarchar](3000) NULL,
	[P2N_TxnId] [varchar](20) NULL,
	[customer_id] [varchar](10) NULL,
	[customer_name] [varchar](100) NULL,
	[senderId_type] [varchar](50) NULL,
	[senderId_description] [varchar](50) NULL,
	[sender_mobile] [varchar](50) NULL,
	[P2N_pending_TxnId] [varchar](50) NULL,
	[P2N_remaining_balance] [money] NULL,
	[P2N_settlement_currency] [varchar](5) NULL,
	[InvoiceNO] [varchar](50) NULL,
	[dRate_SendCCY] [money] NULL,
	[dRate_ReceivingCCY] [money] NULL,
	
 CONSTRAINT [PK__BalanceTransfer__0C5C8C72] PRIMARY KEY CLUSTERED 
(
	[sno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


