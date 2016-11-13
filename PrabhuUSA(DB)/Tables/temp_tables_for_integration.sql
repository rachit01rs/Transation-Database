/****** Object:  Table [dbo].[tbl_status_moneysend_paid]    Script Date: 02/08/2012 15:40:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[moneySend_integration]') AND type in (N'U'))
DROP TABLE [dbo].[moneySend_integration]
GO

/****** Object:  Table [dbo].[tbl_status_moneysend_paid]    Script Date: 02/08/2012 15:40:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbl_status_moneysend_paid]') AND type in (N'U'))
DROP TABLE [dbo].[tbl_status_moneysend_paid]
GO

/****** Object:  Table [dbo].[tbl_status_moneysend]    Script Date: 02/08/2012 15:40:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbl_status_moneysend]') AND type in (N'U'))
DROP TABLE [dbo].[tbl_status_moneysend]
GO

/****** Object:  Table [dbo].[tbl_status]    Script Date: 02/08/2012 15:40:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbl_status]') AND type in (N'U'))
DROP TABLE [dbo].[tbl_status]
GO
/****** Object:  Table [dbo].[tbl_status_moneysend_paid]    Script Date: 02/08/2012 15:40:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_status_moneysend_paid](
	[sno] [int] IDENTITY(1,1) NOT NULL,
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
	[process_status] [varchar](200) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

GO

/****** Object:  Table [dbo].[tbl_status_moneysend]    Script Date: 02/08/2012 15:40:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_status_moneysend](
	[Sno] [int] IDENTITY(1,1) NOT NULL,
	[PartnerAgentCode] [varchar](50) NULL,
	[Refno] [varchar](50) NULL,
	[Status] [varchar](50) NULL,
	[Process_Date] [datetime] NULL,
	[Update_date] [datetime] NULL,
 CONSTRAINT [PK_tbl_status_moneysend] PRIMARY KEY CLUSTERED 
(
	[Sno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[tbl_status]    Script Date: 02/08/2012 15:40:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_status](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[refno] [varchar](50) NULL,
	[PartnerAgentCode] [varchar](50) NULL,
	[update_for] [varchar](50) NULL,
	[column_name] [varchar](50) NULL,
	[column_value] [varchar](50) NULL,
	[userid] [varchar](50) NULL,
	[remarks] [varchar](100) NULL,
	[Partner_sno] [int] NULL,
	[status] [varchar](50) NULL,
	[gmt_get_date] [varchar](100) NULL,
	[DIG_INFO] [varchar](200) NULL,
	[upload_date] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



GO
CREATE TABLE [dbo].[moneySend_integration](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[refno] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[agentid] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[agentname] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Branch_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Branch] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CustomerId] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SenderName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SenderAddress] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SenderPhoneno] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[senderSalary] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[senderFax] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SenderCity] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SenderCountry] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SenderEmail] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SenderCompany] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[senderPassport] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[senderVisa] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReceiverName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReceiverAddress] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReceiverPhone] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReceiverFax] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReceiverCity] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReceiverCountry] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReceiverRelation] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReceiverIDDescription] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReceiverID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DOT] [datetime] NULL,
	[DOtTime] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[paidAmt] [money] NULL,
	[paidCType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[receiveAmt] [money] NULL,
	[receiveCType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ExchangeRate] [money] NULL,
	[Today_Dollar_rate] [money] NULL,
	[Dollar_Amt] [money] NULL,
	[SCharge] [money] NULL,
	[ReciverMessage] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TestQuestion] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TestAnswer] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[amtSenderType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SenderBankID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SenderBankName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SenderBankBranch] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SenderBankVoucherNo] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Amt_paid_date] [datetime] NULL,
	[paymentType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[rBankID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[rBankName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[rBankBranch] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[rBankACNo] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[rBankAcType] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[otherCharge] [money] NULL,
	[TransStatus] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[status] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SEmpID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[bTno] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[imeCommission] [money] NULL,
	[bankCommission] [money] NULL,
	[TotalRoundAmt] [money] NULL,
	[TransferType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[paidBy] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[paidDate] [datetime] NULL,
	[paidTime] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[courierID] [int] NULL,
	[PODDate] [datetime] NULL,
	[senderCommission] [money] NULL,
	[receiverCommission] [money] NULL,
	[approve_by] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[receiveAgentID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[send_mode] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[confirmDate] [datetime] NULL,
	[lock_status] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[lock_dot] [datetime] NULL,
	[lock_by] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[local_DOT] [datetime] NULL,
	[sender_mobile] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[receiver_mobile] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[fax_trans] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SenderNativeCountry] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[receiverEmail] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ip_address] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[agent_dollar_rate] [money] NULL,
	[ho_dollar_rate] [money] NULL,
	[bonus_amt] [money] NULL,
	[request_for_new_account] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[trans_mode] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[digital_id_sender] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[digital_id_payout] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[expected_payoutagentid] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[bonus_value_amount] [money] NULL,
	[bonus_type] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[bonus_on] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ben_bank_id] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ben_bank_name] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[test_Trn] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[paid_agent_id] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[send_sms] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[agent_settlement_rate] [money] NULL,
	[agent_ex_gain] [money] NULL,
	[cancel_date] [datetime] NULL,
	[cancel_by] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[agent_receiverCommission] [money] NULL,
	[agent_receiverSCommission] [money] NULL,
	[door_to_door] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[customer_sno] [int] NULL,
	[paid_date_usd_rate] [money] NULL,
	[upload_trn] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PNBReferenceNo] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[receiverID_placeOfIssue] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[mileage_earn] [int] NULL,
	[tds_com_per] [float] NULL,
	[agent_receiverComm_Currency] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[paid_beneficiary_ID_type] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[paid_beneficiary_ID_number] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[source_of_income] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[reason_for_remittance] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[payout_settle_usd] [money] NULL,
	[confirm_process_id] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[costValue_SC] [money] NULL,
	[costValue_PC] [money] NULL,
	[Send_Settle_USD] [money] NULL,
	[c2c_receiver_code] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[c2c_secure_pwd] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ofac_list] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ofac_app_by] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ofac_app_ts] [datetime] NULL,
	[ho_cost_send_rate] [money] NULL,
	[ho_premium_send_rate] [money] NULL,
	[ho_premium_payout_rate] [money] NULL,
	[agent_customer_diff_value] [money] NULL,
	[agent_sending_rate_margin] [money] NULL,
	[agent_payout_rate_margin] [money] NULL,
	[agent_sending_cust_exchangerate] [money] NULL,
	[agent_payout_agent_cust_rate] [money] NULL,
	[ho_exrate_applied_type] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[c2c_pin_no] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[HO_confirmDate] [datetime] NULL,
	[HO_paidDate] [datetime] NULL,
	[HO_cancel_Date] [datetime] NULL,
	[sender_fax_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ID_Issue_date] [datetime] NULL,
	[SSN_Card_ID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Date_of_Birth] [datetime] NULL,
	[Sender_State] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[compliance_flag] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[compliance_sys_msg] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[transfer_ts] [datetime] NULL,
	[HO_ex_gain] [money] NULL,
	[ext_sCharge] [money] NULL,
	[xm_exRate] [money] NULL,
	[ext_settlement_amt] [money] NULL,
	[isIRH_trn] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[is_downloaded] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[downloaded_by] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[downloaded_ts] [datetime] NULL,
	[process_id] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[partnerSNO] [int],
	[partner_process_id] varchar(100)
 CONSTRAINT [PK_moneySend_integration] PRIMARY KEY CLUSTERED 
(
	[sno] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF