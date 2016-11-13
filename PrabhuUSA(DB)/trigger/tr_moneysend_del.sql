DROP TRIGGER [tr_moneysend_del] 
GO
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

CREATE TRIGGER [tr_moneysend_del] ON [dbo].[moneySend] 
FOR DELETE 
AS
insert delMoneysend (
  Tranno, refno, agentid, agentname, Branch_code, Branch, CustomerId, SenderName, SenderAddress, SenderPhoneno,  senderFax, 
                      SenderCity, SenderCountry, SenderEmail, SenderCompany, senderPassport, senderVisa, ReceiverName, ReceiverAddress, ReceiverPhone, 
                      ReceiverFax, ReceiverCity, ReceiverCountry, ReceiverRelation, ReceiverIDDescription, ReceiverID, DOT, DOtTime, paidAmt, paidCType, receiveAmt, 
                      receiveCType, ExchangeRate, Today_Dollar_rate, Dollar_Amt, SCharge, ReciverMessage, TestQuestion, TestAnswer, amtSenderType, SenderBankID, 
                      SenderBankName, SenderBankBranch, SenderBankVoucherNo, Amt_paid_date, paymentType, rBankID, rBankName, rBankBranch, rBankACNo, 
                      rBankAcType, otherCharge, TransStatus, status, SEmpID, bTno, imeCommission, bankCommission, TotalRoundAmt, TransferType,   
                      paidBy, paidDate, paidTime, courierID, PODDate, senderCommission, receiverCommission, approve_by, receiveAgentID, send_mode, confirmDate, 
                      lock_status, lock_dot, lock_by, local_DOT, sender_mobile, receiver_mobile, fax_trans, SenderNativeCountry, receiverEmail, ip_address, 
                      agent_dollar_rate, ho_dollar_rate, bonus_amt, request_for_new_account, trans_mode,delete_ts,digital_id_sender,digital_id_payout
                      ,msrepl_tran_version,expected_payoutagentid,bonus_value_amount,bonus_type,
                      bonus_on,ben_bank_id,ben_bank_name,test_Trn,paid_agent_id,send_sms,agent_settlement_rate,
                      agent_ex_gain,cancel_date,cancel_by,agent_receiverCommission,agent_receiverSCommission,door_to_door,
                      customer_sno,paid_date_usd_rate,upload_trn,PNBReferenceNo,receiverID_placeOfIssue,mileage_earn,[sPaymentReceivedType],[sCheque_bank],[sChequeno],IssueAuthority,sender_occupation,source_of_income,reason_for_remittance,ben_bank_branch_id,picture_id_type,transStatusPrevious)
select  
  Tranno, refno, agentid, agentname, Branch_code, Branch, CustomerId, SenderName, SenderAddress, SenderPhoneno,  senderFax, 
                      SenderCity, SenderCountry, SenderEmail, SenderCompany, senderPassport, senderVisa, ReceiverName, ReceiverAddress, ReceiverPhone, 
                      ReceiverFax, ReceiverCity, ReceiverCountry, ReceiverRelation, ReceiverIDDescription, ReceiverID, DOT, DOtTime, paidAmt, paidCType, receiveAmt, 
                      receiveCType, ExchangeRate, Today_Dollar_rate, Dollar_Amt, SCharge, ReciverMessage, TestQuestion, TestAnswer, amtSenderType, SenderBankID, 
                      SenderBankName, SenderBankBranch, SenderBankVoucherNo, Amt_paid_date, paymentType, rBankID, rBankName, rBankBranch, rBankACNo, 
                      rBankAcType, otherCharge, TransStatus, status, SEmpID, bTno, imeCommission, bankCommission, TotalRoundAmt, TransferType,   
                      paidBy, paidDate, paidTime, courierID, PODDate, senderCommission, receiverCommission, approve_by, receiveAgentID, send_mode, confirmDate, 
                      lock_status, lock_dot, lock_by, local_DOT, sender_mobile, receiver_mobile, fax_trans, SenderNativeCountry, receiverEmail, ip_address, 
                      agent_dollar_rate, ho_dollar_rate, bonus_amt, request_for_new_account, trans_mode,getdate(),digital_id_sender,digital_id_payout 
					  ,msrepl_tran_version,expected_payoutagentid,bonus_value_amount,bonus_type,
                      bonus_on,ben_bank_id,ben_bank_name,test_Trn,paid_agent_id,send_sms,agent_settlement_rate,
                      agent_ex_gain,cancel_date,cancel_by,agent_receiverCommission,agent_receiverSCommission,door_to_door,
                      customer_sno,paid_date_usd_rate,upload_trn,PNBReferenceNo,receiverID_placeOfIssue,mileage_earn,[sPaymentReceivedType],[sCheque_bank],[sChequeno],IssueAuthority,sender_occupation,source_of_income,reason_for_remittance,ben_bank_branch_id,picture_id_type,transStatusPrevious  from deleted
