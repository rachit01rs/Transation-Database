
/****** Object:  Table [dbo].[TransPaidStatus_OUT]    Script Date: 07/31/2013 02:15:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TransPaidStatus_OUT](
	[sno] [int] IDENTITY(1,2) NOT NULL,
	[refno] [varchar](50) NULL,
	[rBankId] [varchar](50) NULL,
	[rBankName] [varchar](100) NULL,
	[rBankBranch] [varchar](100) NULL,
	[paidBy] [varchar](50) NULL,
	[paidDate] [datetime] NULL,
	[podDate] [datetime] NULL,
	[paidTime] [varchar](50) NULL,
	[HO_paidDate] [datetime] NULL,
	[status] [varchar](50) NULL,
	[receiverCommission] [money] NULL,
	[receiveAgentID] [varchar](50) NULL,
	[digital_id_payout] [varchar](100) NULL,
	[agent_receiverCommission] [money] NULL,
	[agent_receiverComm_Currency] [varchar](50) NULL,
	[lock_status] [varchar](50) NULL,
	[agent_receiverSCommission] [money] NULL,
	[paid_agent_id] [varchar](50) NULL,
	[paid_date_usd_rate] [float] NULL,
	[paid_beneficiary_ID_type] [varchar](50) NULL,
	[paid_beneficiary_ID_number] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[process_status] [varchar](200) NULL,
	[isTransfered] [char](1) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF