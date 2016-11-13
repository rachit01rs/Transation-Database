CREATE TABLE [dbo].[temp_FTP_moneySend](
	[Tranno] [int] IDENTITY(100001,1) NOT FOR REPLICATION NOT NULL,
	[refno] [varchar](50) NOT NULL,
	[agentid] [varchar](50) NOT NULL,
	[agentname] [varchar](100) NULL,
	[Branch_code] [varchar](50) NOT NULL,
	[Branch] [varchar](100) NULL,
	[CustomerId] [varchar](50) NULL,
	[SenderName] [varchar](100) NOT NULL,
	[SenderAddress] [varchar](200) NULL,
	[SenderPhoneno] [varchar](50) NULL,
	[senderSalary] [varchar](100) NULL,
	[senderFax] [varchar](50) NULL,
	[SenderCity] [varchar](100) NULL,
	[SenderCountry] [varchar](50) NULL,
	[SenderEmail] [varchar](100) NULL,
	[SenderCompany] [varchar](100) NULL,
	[senderPassport] [varchar](50) NULL,
	[senderVisa] [varchar](50) NULL,
	[ReceiverName] [varchar](100) NULL,
	[ReceiverAddress] [varchar](100) NULL,
	[ReceiverPhone] [varchar](50) NULL,
	[ReceiverFax] [varchar](50) NULL,
	[ReceiverCity] [varchar](100) NULL,
	[ReceiverCountry] [varchar](50) NULL,
	[ReceiverRelation] [varchar](100) NULL,
	[ReceiverIDDescription] [varchar](50) NULL,
	[ReceiverID] [varchar](50) NULL,
	[DOT] [datetime] NULL,
	[DOtTime] [varchar](50) NULL,
	[paidAmt] [money] NULL,
	[paidCType] [varchar](50) NULL,
	[receiveAmt] [money] NULL,
	[receiveCType] [varchar](50) NULL,
	[ExchangeRate] [money] NULL,
	[Today_Dollar_rate] [money] NULL,
	[Dollar_Amt] [money] NULL,
	[SCharge] [money] NULL,
	[ReciverMessage] [varchar](1000) NULL,
	[TestQuestion] [varchar](200) NULL,
	[TestAnswer] [varchar](200) NULL,
	[amtSenderType] [varchar](50) NULL,
	[SenderBankID] [varchar](50) NULL,
	[SenderBankName] [varchar](100) NULL,
	[SenderBankBranch] [varchar](100) NULL,
	[SenderBankVoucherNo] [varchar](100) NULL,
	[Amt_paid_date] [datetime] NULL,
	[paymentType] [varchar](50) NULL,
	[rBankID] [varchar](50) NULL,
	[rBankName] [varchar](100) NULL,
	[rBankBranch] [varchar](500) NULL,
	[rBankACNo] [varchar](50) NULL,
	[rBankAcType] [varchar](200) NULL,
	[otherCharge] [money] NULL,
	[TransStatus] [varchar](50) NULL,
	[status] [varchar](50) NULL,
	[SEmpID] [varchar](50) NULL,
	[bTno] [varchar](200) NULL,
	[imeCommission] [money] NULL,
	[bankCommission] [money] NULL,
	[TotalRoundAmt] [money] NULL,
	[TransferType] [varchar](50) NULL,
	[paidBy] [varchar](50) NULL,
	[paidDate] [datetime] NULL,
	[paidTime] [varchar](50) NULL,
	[courierID] [int] NULL,
	[PODDate] [datetime] NULL,
	[senderCommission] [money] NULL,
	[receiverCommission] [money] NULL,
	[approve_by] [varchar](50) NULL,
	[receiveAgentID] [varchar](50) NULL,
	[send_mode] [char](1) NULL,
	[confirmDate] [datetime] NULL,
	[lock_status] [varchar](50) NULL,
	[lock_dot] [datetime] NULL,
	[lock_by] [varchar](50) NULL,
	[local_DOT] [datetime] NULL,
	[sender_mobile] [varchar](20) NULL,
	[receiver_mobile] [varchar](20) NULL,
	[fax_trans] [char](10) NULL,
	[SenderNativeCountry] [varchar](50) NULL,
	[receiverEmail] [varchar](50) NULL,
	[ip_address] [varchar](50) NULL,
	[agent_dollar_rate] [money] NULL,
	[ho_dollar_rate] [money] NULL,
	[bonus_amt] [money] NULL,
	[request_for_new_account] [char](1) NULL,
	[trans_mode] [char](1) NULL,
	[digital_id_sender] [varchar](100) NULL,
	[digital_id_payout] [varchar](100) NULL,
	[expected_payoutagentid] [varchar](50) NULL,
	[bonus_value_amount] [money] NULL,
	[bonus_type] [char](1) NULL,
	[bonus_on] [char](1) NULL,
	[ben_bank_id] [varchar](50) NULL,
	[ben_bank_name] [varchar](200) NULL,
	[test_Trn] [char](1) NULL,
	[paid_agent_id] [varchar](50) NULL,
	[send_sms] [char](1) NULL,
	[agent_settlement_rate] [money] NULL,
	[agent_ex_gain] [money] NULL,
	[cancel_date] [datetime] NULL,
	[cancel_by] [varchar](50) NULL,
	[agent_receiverCommission] [money] NULL,
	[agent_receiverSCommission] [money] NULL,
	[door_to_door] [char](1) NULL,
	[customer_sno] [int] NULL,
	[paid_date_usd_rate] [money] NULL,
	[upload_trn] [char](1) NULL,
	[PNBReferenceNo] [varchar](100) NULL,
	[receiverID_placeOfIssue] [varchar](50) NULL,
	[mileage_earn] [int] NULL,
	[tds_com_per] [float] NULL,
	[agent_receiverComm_Currency] [char](1) NULL,
	[paid_beneficiary_ID_type] [varchar](100) NULL,
	[paid_beneficiary_ID_number] [varchar](100) NULL,
	[source_of_income] [varchar](100) NULL,
	[reason_for_remittance] [varchar](100) NULL,
	[payout_settle_usd] [float] NULL,
	[confirm_process_id] [varchar](150) NULL,
	[costValue_SC] [money] NULL,
	[costValue_PC] [money] NULL,
	[Send_Settle_USD] [money] NULL,
	[c2c_receiver_code] [varchar](500) NULL,
	[c2c_secure_pwd] [varchar](50) NULL,
	[ofac_list] [char](1) NULL,
	[ofac_app_by] [varchar](50) NULL,
	[ofac_app_ts] [datetime] NULL,
	[ho_cost_send_rate] [money] NULL,
	[ho_premium_send_rate] [money] NULL,
	[ho_premium_payout_rate] [money] NULL,
	[agent_customer_diff_value] [money] NULL,
	[agent_sending_rate_margin] [money] NULL,
	[agent_payout_rate_margin] [money] NULL,
	[agent_sending_cust_exchangerate] [money] NULL,
	[agent_payout_agent_cust_rate] [money] NULL,
	[ho_exrate_applied_type] [varchar](20) NULL,
	[c2c_pin_no] [varchar](255) NULL,
	[HO_confirmDate] [datetime] NULL,
	[HO_paidDate] [datetime] NULL,
	[HO_cancel_Date] [datetime] NULL,
	[sender_fax_no] [varchar](50) NULL,
	[ID_Issue_date] [datetime] NULL,
	[SSN_Card_ID] [varchar](50) NULL,
	[Date_of_Birth] [datetime] NULL,
	[Sender_State] [varchar](100) NULL,
	[compliance_flag] [varchar](1) NULL,
	[compliance_sys_msg] [varchar](200) NULL,
	[transfer_ts] [datetime] NULL,
	[HO_ex_gain] [money] NULL,
	[ext_sCharge] [money] NULL,
	[xm_exRate] [money] NULL,
	[ext_settlement_amt] [money] NULL,
	[isIRH_trn] [char](1) NULL,
	[is_downloaded] [char](1) NULL,
	[downloaded_by] [varchar](50) NULL,
	[downloaded_ts] [datetime] NULL,
	[ext_payout_amount] [money] NULL,
	[process_id] [varchar](500) NULL,
	[sPaymentReceivedType] [varchar](50) NULL,
	[sCheque_bank] [varchar](200) NULL,
	[sChequeno] [varchar](100) NULL,
	[IssueAuthority] [varchar](200) NULL,
	[payout_send_agent_id] [varchar](50) NULL,
	[remote_download] [char](1) NULL,
	[customer_category_id] [int] NULL,
	[sender_occupation] [varchar](150) NULL,
	[ben_bank_branch_id] [varchar](50) NULL,
	[FreeSMS] [char](1) NULL,
	[PaymentRoutingNumber] [varchar](50) NULL,
	[PaymentAccountNumber] [varchar](50) NULL,
	[PaymentAccountType] [varchar](50) NULL,
	[employmentType] [varchar](50) NULL,
	[gender] [varchar](50) NULL,
	[customerType] [varchar](50) NULL,
	[id_place_of_issue] [varchar](50) NULL,
	[relation_other] [varchar](100) NULL,
	[source_of_income_other] [varchar](100) NULL,
	[sender_occupation_other] [varchar](50) NULL,
	[ben_bank_branch_extid] [varchar](50) NULL,
	[premium_rate] [float] NULL,
	[receiver_sno] [int] NULL,
	[SenderZipCode] [varchar](50) NULL,
	[online_txn_app_by] [varchar](50) NULL,
	[online_txn_app_ts] [datetime] NULL,
	[online_txn_released_by] [varchar](50) NULL,
	[online_txn_released_ts] [datetime] NULL,
	[picture_id_type] [varchar](50) NULL,
 CONSTRAINT [PK_temp_FTP_moneySend] PRIMARY KEY CLUSTERED 
(
	[Tranno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 70) ON [PRIMARY]
) ON [PRIMARY]




