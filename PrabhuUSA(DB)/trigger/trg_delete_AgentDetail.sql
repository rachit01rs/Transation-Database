/****** Object:  Trigger [trg_delete_AgentDetail]    Script Date: 11/18/2014 11:25:14 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_delete_AgentDetail]'))
DROP TRIGGER [dbo].[trg_delete_AgentDetail]
GO


/****** Object:  Trigger [dbo].[trg_delete_AgentDetail]    Script Date: 11/18/2014 11:25:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_delete_AgentDetail] ON [dbo].[agentDetail] 
FOR  DELETE
AS
INSERT INTO agentDetail_audit (
	[agentCode],
	[agentPinCode],
	[ContactName1],
	[Post1],
	[email1],
	[ContactName2],
	[Post2],
	[email2],
	[CompanyName],
	[LicNo],
	[AgentType],
	[Address],
	[City],
	[Country],
	[Phone1],
	[Phone2],
	[Fax],
	[Email],
	[BankName],
	[BankACNo],
	[CurrentBalance],
	[CurrencyType],
	[DateOfJoin],
	[AgentCan],
	[accessed],
	[remarks],
	[commission],
	[cType],
	[limit],
	[limitPerTran],
	[upload],
	[agent_serial_send],
	[Zone_id],
	[GMT_Value],
	[sms_sender],
	[mobileNoformat],
	[mobile_digit_min],
	[mobile_digit_max],
	[sms_receiver],
	[credit_bank_limit],
	[limit_for_customer],
	[created_user],
	[created_ts],
	[user_action],
	[updated_user],
	[updated_ts],
	[agent_short_code],
	[CurrentCommission],
	[door_to_door_charge],
	[trn_limit_per_day],
	[trn_limit_date],
	[trn_limit_balance],

	[Intermediary_Bank],
	[Swift_Code_IB],
	[Account_No_IB],
	[Beneficiary_Bank],
	[Swift_Code_BB],
	[Account_No_BB],
	[Further_Credit],
	[Increased_Credit_limit],


	[date_format],
	[restrict_anywhere_payment],
	[cal_commission_daily],
	[dont_allow_apv_same_user],
	[receiver_mobileformat],
     [settlement_type]   ,
     [state],
     [send_txn_without_balance]
)

SELECT
	[agentCode],
	[agentPinCode],
	[ContactName1],
	[Post1],
	[email1],
	[ContactName2],
	[Post2],
	[email2],
	[CompanyName],
	[LicNo],
	[AgentType],
	[Address],
	[City],
	[Country],
	[Phone1],
	[Phone2],
	[Fax],
	[Email],
	[BankName],
	[BankACNo],
	[CurrentBalance],
	[CurrencyType],
	[DateOfJoin],
	[AgentCan],
	[accessed],
	[remarks],
	[commission],
	[cType],
	[limit],
	[limitPerTran],
	[upload],
	[agent_serial_send],
	[Zone_id],
	[GMT_Value],
	[sms_sender],
	[mobileNoformat],
	[mobile_digit_min],
	[mobile_digit_max],
	[sms_receiver],
	[credit_bank_limit],
	[limit_for_customer],
	[created_user],
	[created_ts],
	'DELETE',
	[updated_user],
	GETDATE(),
	[agent_short_code],
	[CurrentCommission],
	[door_to_door_charge],
	[trn_limit_per_day],
	[trn_limit_date],
	[trn_limit_balance],

	[Intermediary_Bank],
	[Swift_Code_IB],
	[Account_No_IB],
	[Beneficiary_Bank],
	[Swift_Code_BB],
	[Account_No_BB],
	[Further_Credit],
	[Increased_Credit_limit],


	[date_format],
	[restrict_anywhere_payment],
	[cal_commission_daily],
	[dont_allow_apv_same_user],
	[receiver_mobileformat],
     [settlement_type],
     [state],
     [send_txn_without_balance]
	FROM DELETED

GO


