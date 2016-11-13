/****** Object:  StoredProcedure [dbo].[spRemote_approve_job]    Script Date: 04/11/2012 16:17:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spRemote_approve_job]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spRemote_approve_job]
GO

/****** Object:  StoredProcedure [dbo].[spRemote_approve_job]    Script Date: 04/11/2012 16:17:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



Create proc [dbo].[spRemote_approve_job]
AS
BEGIN TRY

begin transaction  
DECLARE @process_id VARCHAR(150)

SET @process_id = REPLACE(newid(),'-','_')

UPDATE [Staging_process_2].[dbo].[moneySend_IN] SET process_id=@process_id WHERE process_id IS NULL 


update [Staging_process_2].[dbo].[moneySend_IN] set refno=dbo.encryptdb('D')+mi.refno,
receiverFax='duplicate',transstatus='Block' 
from [Staging_process_2].[dbo].[moneySend_IN] mi join moneysend m on mi.refno=m.refno where mi.process_id=@process_id

insert into moneysend
			([refno],[agentid],[agentname]
		   ,[Branch_code],[Branch]
		   ,[CustomerId],[SenderName],[SenderAddress]
           ,[SenderPhoneno],[senderSalary],[senderFax],[SenderCity],[SenderCountry],[SenderEmail]
           ,[SenderCompany],[senderPassport],[senderVisa],[ReceiverName],[ReceiverAddress],[ReceiverPhone]
           ,[ReceiverFax],[ReceiverCity],[ReceiverCountry],[ReceiverRelation],[ReceiverIDDescription]
           ,[ReceiverID],[DOT],[DOtTime],[paidAmt],[paidCType],[receiveAmt],[receiveCType],[ExchangeRate]
           ,[Today_Dollar_rate],[Dollar_Amt],[SCharge],[ReciverMessage],[TestQuestion],[TestAnswer]
           ,[amtSenderType],[SenderBankID],[SenderBankName],[SenderBankBranch],[SenderBankVoucherNo]
           ,[Amt_paid_date],[paymentType],[rBankID],[rBankName],[rBankBranch]
           ,[rBankACNo],[rBankAcType],[otherCharge],[TransStatus],[status],[SEmpID],[bTno],[imeCommission]
           ,[bankCommission],[TotalRoundAmt],[TransferType]
           ,[PODDate],[senderCommission],[receiverCommission],[approve_by],[receiveAgentID],[send_mode]
           ,[confirmDate],[local_DOT],[sender_mobile],[receiver_mobile]
           ,[fax_trans],[SenderNativeCountry],[receiverEmail],[ip_address],[agent_dollar_rate]
           ,[ho_dollar_rate],[bonus_amt],[request_for_new_account],[trans_mode],[digital_id_sender]
           ,[expected_payoutagentid],[bonus_value_amount]
           ,[bonus_type],[bonus_on],[ben_bank_id],[ben_bank_name],[paid_agent_id],[send_sms]
           ,[agent_settlement_rate],[agent_ex_gain],[agent_receiverCommission]
           ,[agent_receiverSCommission],[customer_sno]
           ,[receiverID_placeOfIssue],[mileage_earn],payout_settle_usd,isIRH_trn,
           [ofac_list],[ofac_app_by],[ofac_app_ts],[compliance_flag],[compliance_sys_msg],process_id,
			confirm_process_id
           )
select [refno],[agentid],[agentname]
		   ,[Branch_code],[Branch]
		   ,[CustomerId],[SenderName],[SenderAddress]
           ,[SenderPhoneno],[senderSalary],[senderFax],[SenderCity],[SenderCountry],[SenderEmail]
           ,[SenderCompany],[senderPassport],[senderVisa],[ReceiverName],[ReceiverAddress],[ReceiverPhone]
           ,[ReceiverFax],[ReceiverCity],[ReceiverCountry],[ReceiverRelation],[ReceiverIDDescription]
           ,[ReceiverID],[DOT],[DOtTime],[paidAmt],[paidCType],[receiveAmt],[receiveCType],[ExchangeRate]
           ,[Today_Dollar_rate],[Dollar_Amt],[SCharge],[ReciverMessage],[TestQuestion],[TestAnswer]
           ,[amtSenderType],[SenderBankID],[SenderBankName],[SenderBankBranch],[SenderBankVoucherNo]
           ,[Amt_paid_date],[paymentType],[rBankID],[rBankName],[rBankBranch]
           ,[rBankACNo],[rBankAcType],[otherCharge],[TransStatus],[status],[SEmpID],[bTno],[imeCommission]
           ,[bankCommission],[TotalRoundAmt],[TransferType]
           ,[PODDate],[senderCommission],0,[approve_by],[receiveAgentID],[send_mode]
           ,[confirmDate],[local_DOT],[sender_mobile],[receiver_mobile]
           ,[fax_trans],[SenderNativeCountry],[receiverEmail],[ip_address],[agent_dollar_rate]
           ,[ho_dollar_rate],[bonus_amt],[request_for_new_account],[trans_mode],[digital_id_sender]
           ,[expected_payoutagentid],[bonus_value_amount]
           ,[bonus_type],[bonus_on],[ben_bank_id],[ben_bank_name],[paid_agent_id],[send_sms]
           ,[agent_settlement_rate],0 [agent_ex_gain],0 [agent_receiverCommission]
           ,0,[customer_sno]
           ,[receiverID_placeOfIssue],[mileage_earn],payout_settle_usd,'y'
           ,[ofac_list],[ofac_app_by],[ofac_app_ts],[compliance_flag],[compliance_sys_msg],partner_process_id,
@process_id
from [Staging_process_2].[dbo].[moneySend_IN]  WHERE process_id=@process_id  and transStatus<>'Block'

update agentdetail set currentbalance=isNULL(currentbalance,0)+ (isNULL(paidamt,0)-(isNULL(sendercommission,0)+isNull(agent_ex_gain,0))) 
from (SELECT agentid,SUM(paidAmt) paidAmt,SUM(sendercommission) sendercommission,SUM(agent_ex_gain) agent_ex_gain
 FROM [Staging_process_2].[dbo].[moneySend_IN] WHERE process_id=@process_id  and transStatus<>'Block'
GROUP BY agentid) m 
join agentdetail a on m.agentid=a.agentcode

update [Staging_process_2].[dbo].[moneySend_IN] set Remote_status='Completed'

commit transaction 
end try  
begin catch
if @@trancount>0   
 rollback transaction  
  
 declare @desc varchar(1000)  
 set @desc='SQL Error found:  (' + ERROR_MESSAGE() + ')'  

   
 INSERT INTO [error_info]  
           ([ErrorNumber]  
           ,[ErrorDesc]  
           ,[Script]  
           ,[ErrorScript]  
           ,[QueryString]  
           ,[ErrorCategory]  
           ,[ErrorSource]  
           ,[IP]  
           ,[error_date])  
 select -1,@desc,'INTEGRATION','SQL',@desc,'SQL','SP','SYSTEM',getdate()  
  
end catch  

GO


