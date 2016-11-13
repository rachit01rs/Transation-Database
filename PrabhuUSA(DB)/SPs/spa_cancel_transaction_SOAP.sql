USE [PrabhuUsa]
GO
/****** Object:  StoredProcedure [dbo].[spa_cancel_transaction_SOAP]    Script Date: 01/19/2015 16:47:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
--select top 10 * from moneysend where status='Un-Paid' and transStatus='Payment'    
--select transStatus,* from moneysend where refno='MKOKJP'    
--spa_cancel_transaction 'RQLMJQPNPQLM','dipen','2009-08-2 12:10:22','Payment'    
ALTER PROCEDURE [dbo].[spa_cancel_transaction_SOAP]     
@refno varchar(20),    
@cancel_by varchar(50),    
@gmt_get_date varchar(100),    
@status varchar(50)=null,    
@table_name varchar(200)=NULL    
AS    
declare @receiverCountry varchar(100),@payout_agentid varchar(50),@sql_remote varchar(2000)    
declare @gmt_date datetime,@dot varchar(50),@senderPassport varchar(50),@paidAmt money    
--set @gmt_date=cast(@gmt_get_date as datetime)    
select @receiverCountry=receiverCountry,@payout_agentid=expected_payoutagentid,@dot=convert(varchar,m.dot,101),@senderPassport=senderPassport,@paidAmt=paidAmt,    
@gmt_date=dateadd(mi,isNUll(gmt_value,480),getutcdate())    
from moneysend m join agentdetail a on m.agentid=a.agentcode     
where refno=@refno    
    
if exists (select tranno FROM moneySend WHERE refno=@refno AND TransStatus IN ('Hold','OFAC') and status = 'Post' and is_downloaded is null)    
BEGIN    
 update moneysend set status='Un-Paid' WHERE refno=@refno    
END    
    
IF not exists (select tranno FROM moneySend WHERE refno=@refno AND (TransStatus IN ('Payment','Hold','OFAC','Compliance') and status = 'Un-Paid'))    
BEGIN    
 exec('insert '+ @table_name +'(status,remarks)    
 select ''ERROR'',''3012: Transaction cant be cancelled''')    
END    
CREATE TABLE #temp_status_remote(    
 msg_status VARCHAR(50),    
 msg_remarks VARCHAR(200)    
)    
    
exec spa_PartnerCheck_for_Cancel_SOAP @refno,'#temp_status_remote'    
    
IF not EXISTS (SELECT msg_status FROM #temp_status_remote WHERE msg_status='Success')    
BEGIN     
 exec('insert '+ @table_name +'(status,remarks)    
 select ''ERROR'',msg_remarks from #temp_status_remote')    
 RETURN     
END     
    
BEGIN TRY    
SET XACT_ABORT ON;    
begin transaction     
    
if @dot=convert(varchar,getdate(),101)    
begin    
 update customer_trans_limit set paidAmt=(isNull(paidAmt,0)-@paidAmt) where customer_passport=@senderPassport    
end    
insert into cancelMoneySend(Tranno, refno, agentid, agentname, Branch_code, Branch, CustomerId, SenderName,     
SenderAddress, SenderPhoneno, senderFax, SenderCity,SenderCountry,  SenderCompany, senderPassport,     
senderVisa, ReceiverName, ReceiverAddress, ReceiverPhone, ReceiverCity, ReceiverCountry,     
 ReceiverIDDescription, ReceiverID, DOT, DOtTime, paidAmt, paidCType, receiveAmt,     
receiveCType,ExchangeRate, Today_Dollar_rate, Dollar_Amt, SCharge, ReciverMessage, TestQuestion,     
TestAnswer, amtSenderType, SenderBankID, SenderBankName, SenderBankBranch, SenderBankVoucherNo,     
Amt_paid_date, paymentType, rBankID, rBankName, rBankBranch, rBankACNo,rBankAcType, otherCharge,     
TransStatus, status, SEmpID, bTno, imeCommission, bankCommission, TotalRoundAmt, TransferType,    
paidBy, paidDate, paidTime,  PODDate, senderCommission, receiverCommission,approve_by,delBy,delDate,    
expected_payoutagentid, bonus_value_amt, bonus_type, bonus_on, ben_bank_id, ben_bank_name,     
test_trn, paid_agent_id,send_sms,agent_receiverCommission,agent_receiverSCommission,customer_sno,paid_date_usd_rate,    
local_dot,lock_status,lock_dot,lock_by ,    
senderSalary,ReceiverRelation,receiveAgentID,send_mode,confirmDate,sender_mobile,receiver_mobile,    
fax_trans,SenderNativeCountry,ip_address,agent_dollar_rate,ho_dollar_rate,bonus_amt,request_for_new_account,    
trans_mode,digital_id_sender ,digital_id_payout,bonus_value_amount,agent_settlement_rate,agent_ex_gain,    
cancel_date,cancel_by,door_to_door,upload_trn,PNBReferenceNo,receiverID_placeOfIssue,mileage_earn)    
select Tranno, refno, agentid, agentname, Branch_code, Branch, CustomerId, SenderName, SenderAddress,    
SenderPhoneno, senderFax, SenderCity,SenderCountry,  SenderCompany, senderPassport, senderVisa,     
ReceiverName, ReceiverAddress, ReceiverPhone, ReceiverCity, ReceiverCountry,    
ReceiverIDDescription, ReceiverID, Local_DOT, DOtTime, paidAmt, paidCType, receiveAmt, receiveCType,    
ExchangeRate, Today_Dollar_rate, Dollar_Amt, SCharge, ReciverMessage, TestQuestion, TestAnswer,     
amtSenderType, SenderBankID, SenderBankName, SenderBankBranch, SenderBankVoucherNo, Amt_paid_date,     
paymentType, rBankID, rBankName, rBankBranch, rBankACNo,rBankAcType, otherCharge, TransStatus,     
status, SEmpID, bTno, imeCommission, bankCommission, TotalRoundAmt, TransferType,    
paidBy, paidDate, paidTime,  PODDate, senderCommission, receiverCommission,approve_by ,@cancel_by , @gmt_date,    
expected_payoutagentid, bonus_value_amount, bonus_type, bonus_on, ben_bank_id, ben_bank_name, test_trn, paid_agent_id,    
send_sms,agent_receiverCommission,agent_receiverSCommission,customer_sno,paid_date_usd_rate,    
local_dot,lock_status,lock_dot,lock_by,    
senderSalary,ReceiverRelation,receiveAgentID,send_mode,confirmDate,sender_mobile,receiver_mobile,    
fax_trans,SenderNativeCountry,ip_address,agent_dollar_rate,ho_dollar_rate,bonus_amt,request_for_new_account,    
trans_mode,digital_id_sender ,digital_id_payout,bonus_value_amount,agent_settlement_rate,agent_ex_gain,    
cancel_date,cancel_by,door_to_door,upload_trn,PNBReferenceNo,receiverID_placeOfIssue,mileage_earn     
from moneysend where refno =@refno    
    
if @status is null    
 set @status='Payment'    
    
 update Moneysend set transStatus='Cancel',lock_status='unlocked',HO_cancel_date=dbo.getDateHO(getutcdate()),  
cancel_date=@gmt_date,cancel_by=@cancel_by    
 where refno=@refno    
    
 UPDATE customerDetail SET trn_amt=trn_amt-m.paidAmt    
 FROM customerDetail c,moneysend m    
 WHERE c.sno=m.customer_sno and convert(varchar,trn_date,101)=convert(varchar,m.local_dot,101)      
 AND m.refno=@refno    
    
 update AgentDetail     
 set CurrentBalance= CurrentBalance - (m.paidAmt-(isNull(m.senderCommission,0)+isNull(m.agent_ex_gain,0))),    
 CurrentCommission = CurrentCommission - isNull(m.senderCommission,0)    
 from AgentDetail a, moneysend m    
 where a.agentCode=m.agentid and     
        m.refno=@refno    
    
 --UPDATING FOR PAYOUT AGNET BALANCE    
 update AgentDetail     
 set payout_agent_balance= isNull(payout_agent_balance,0)+m.TotalRoundAmt    
 from AgentDetail a, moneysend m    
 where a.agentCode=m.expected_payoutagentid and     
        m.refno=@refno    
    
 update agentbranchdetail set current_branch_limit=ISNULL(current_branch_limit,0)-m.paidamt    
 from agentbranchdetail b,moneysend m    
 where agent_branch_code=m.branch_code and m.refno=@refno    
 and branch_limit is not null    
  
    
 if(select send_mode from moneysend where refno=@refno) in ('v','s')    
 begin     
  update cash_collected set tranno=NULL,    
  session_id=NULL,session_by=NULL,session_ts=NULL    
  from cash_collected c, moneysend m    
  where c.tranno=m.tranno and m.refno=@refno and c.branch_id=m.branch_code    
 end    
    
declare @isPending int    
 if exists(select pending_id from deposit_detail     
 where tranno in (select tranno from moneysend where refno=@refno) and pending_id is not null)    
  set @isPending=1    
    
if @status not in ('Hold') or @status is NULL --OR @status='Block'    
begin    
 declare @invoice_no as int    
 set @invoice_no=ident_current('agentBalance')+1    
    
 insert into agentBalance(InVoiceNo,AgentCode,CompanyName,Dot,Amount,CurrencyType,XRate,Mode,staffId,dollar_rate,    
 remarks,branch_code,other_commission,tranno,approved_by,approved_ts)     
 select 'c:'+cast(@invoice_no as varchar),agentid,agentName,@gmt_date,paidAmt,paidCType,exchangerate,'Cancel',@cancel_by,    
 case when agent_dollar_rate is null then dollar_amt else totalRoundamt/ho_dollar_rate end,dbo.decryptDB(refno),     
 branch_code, senderCommission+isNull(agent_ex_gain,0) ,tranno, @cancel_by,@gmt_date    
 from moneysend     
 where refno=@refno    
    
 if @isPending=1 -- IF it is PENDING     
 begin    
  insert pendingTransaction(bankCode,deposit_detail1,deposit_detail2,amtPaid,agentCode,branch_code,depositDOT,pending,postedby)     
  select bankCode,deposit_detail1,deposit_detail2,amtPaid,agentCode,branch_code,depositDOT,'y',postedby from pendingTransaction  where senderName=dbo.decryptDB(@refno)    
    
  update pendingTransaction set deposit_detail1=deposit_detail1 +' (Cancelled)' where senderName=dbo.decryptDB(@refno)    
 end    
     
end    
else if @status IN ('Hold')    
begin    
 if @isPending=1 -- IF it is PENDING     
  update pendingTransaction set senderName=NULL,confirmDate=NULL,confirmBy=NULL,pending='y' where senderName=dbo.decryptDB(@refno)    
  delete MoneySend where refno=@refno    
end     
declare @enable_update_remoteDB char(1),@remote_db  varchar(200)    
select @enable_update_remoteDB=enable_update_remote_DB,@remote_db=remote_db from tbl_interface_setup     
where agentcode=@payout_agentid and mode='Send'    
    
    
exec('insert '+ @table_name +'(status,remarks)    
select ''SUCCESS'','''+ @refno +'''')    
    
create table #temp_status(status varchar(50))    
    
exec('insert #temp_status(status) select top 1 status from '+ @table_name)    
    
if (select status from #temp_status)='Success'    
 commit tran    
else    
 rollback transaction    
    
if @enable_update_remoteDB='y' and (@status='Payment' or @status is NULL)    
begin    
      
 exec spa_integration_partner_cancel_ticket 'c',NULL,@refno,'Cancel',    
 NULL,NULL,@cancel_by,NULL,'Api Cancel',@gmt_get_date,'APIcancel'    
    
    
end    
    
END TRY    
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
           ,[error_date])      
 select -1,@desc,'Cancel','SQL',@desc,'SQL','SPCancel',dbo.getDateHO(getutcdate())      
      
 select 'ERROR','1012','Error Please try again'      
      
end catch    
    
    