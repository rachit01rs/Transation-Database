USE [PrabhuUsa]
GO
/****** Object:  StoredProcedure [dbo].[spa_cancel_transaction]    Script Date: 01/19/2015 16:44:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select top 10 * from moneysend where status='Un-Paid' and transStatus='Payment'  
--select transStatus,* from moneysend where refno='MKOKJP'  
--spa_cancel_transaction 'RQLMJQPNPQLM','dipen','2009-08-2 12:10:22','Payment'  
ALTER PROCEDURE [dbo].[spa_cancel_transaction]   
@refno varchar(20),  
@cancel_by varchar(50),  
@gmt_get_date varchar(100),  
@status varchar(50)=null,  
@remarks varchar(200)=NULL,  
@DIG_INFO varchar(200)=NULL,  
@isPartner char(1)=NULL  
AS  
  
declare @receiverCountry varchar(100),@payout_agentid varchar(50),@sql_remote varchar(2000)  
declare @gmt_date datetime,@dot varchar(50),@senderPassport varchar(50),@paidAmt money,@isIRH_trn CHAR(1),@tranno INT  
--set @gmt_date=cast(@gmt_get_date as datetime)
SELECT * INTO #temp_moneysend FROM dbo.moneySend WITH(NOLOCK) WHERE refno=@refno  
select @receiverCountry=receiverCountry,@payout_agentid=expected_payoutagentid,@dot=convert(varchar,m.dot,101),@senderPassport=senderPassport,@paidAmt=paidAmt,  
@gmt_date=dateadd(mi,isNUll(gmt_value,480),getutcdate()),@isIRH_trn=isIRH_trn ,@tranno=m.Tranno 
from #temp_moneysend m WITH(NOLOCK) join agentdetail a WITH(NOLOCK) on m.agentid=a.agentcode   
where refno=@refno  
-- XPRESS Check  
--declare @XM_AgentID varchar(50)  
--select @XM_AgentID=XM_AgentID from tbl_setup  
--if @XM_AgentID=@payout_agentid  
----begin  
 --select 'ERROR','3011: '+'Transaction can''t be cancelled Please Contact head office!'  
 --return  
--end  
--End of Xpress Check  
 IF @isIRH_trn='y' and isNULL(@isPartner,'n')='n'  
 BEGIN    
 select 'ERROR','3015: '+'Transaction can not cancelled, Please cancel from External Source.'      
 return    
 END   
  
IF not exists (select tranno FROM moneysend WITH(NOLOCK) WHERE tranno=@tranno AND (  
(TransStatus IN ('Payment','Hold','OFAC','Compliance','Cancel Processing') and status = 'Un-Paid')  
or (transStatus='hold' and status='Post')))  
BEGIN  
 select 'ERROR','3012: '+'Transaction can''t be cancelled'  
 return  
end  
--Check Remote for cancel transaction    
if exists(select tranno FROM #temp_moneysend WITH(NOLOCK) WHERE refno=@refno AND (TransStatus ='Payment' and status = 'Un-Paid'))    
begin    
 exec spa_PartnerCheck_for_cancel @refno    
 if not exists (select tranno from moneysend WITH(NOLOCK) WHERE refno=@refno AND TransStatus IN ('Cancel Processing'))    
 begin    
 return    
 end    
end    
Update moneysend set transstatus='Payment' WHERE tranno=@tranno AND TransStatus IN ('Cancel Processing')  
SET XACT_ABORT ON;  
BEGIN TRY  
begin transaction   
  

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
FROM moneysend WITH(NOLOCK) where tranno=@tranno  
  
if @status is null  
 set @status='Payment'  
  
 update Moneysend set transStatus='Cancel',lock_status='unlocked',HO_cancel_date=dbo.getDateHO(getutcdate()),cancel_date=@gmt_date,cancel_by=@cancel_by  
 where tranno=@tranno  
  
 UPDATE customerDetail SET trn_amt=trn_amt-m.paidAmt  
 FROM customerDetail c WITH(NOLOCK),#temp_moneysend m  WITH(NOLOCK)
 WHERE c.sno=m.customer_sno and convert(varchar,trn_date,101)=convert(varchar,m.local_dot,101)    
 AND m.tranno=@tranno  
  
 update AgentDetail   
 set CurrentBalance= CurrentBalance - (m.paidAmt-(isNull(m.senderCommission,0)+isNull(m.agent_ex_gain,0))),  
 CurrentCommission = CurrentCommission - isNull(m.senderCommission,0)  
 from AgentDetail a WITH(NOLOCK), #temp_moneysend m WITH(NOLOCK)  
 where a.agentCode=m.agentid and   
        m.tranno=@tranno  
  
 --UPDATING FOR PAYOUT AGNET BALANCE  
 update AgentDetail   
 set payout_agent_balance= isNull(payout_agent_balance,0)+m.TotalRoundAmt  
 from AgentDetail a WITH(NOLOCK), #temp_moneysend m WITH(NOLOCK)  
 where a.agentCode=m.expected_payoutagentid and   
        m.tranno=@tranno  
  
 update agentbranchdetail set current_branch_limit=ISNULL(current_branch_limit,0)-m.paidamt  
 from agentbranchdetail b WITH(NOLOCK),#temp_moneysend m WITH(NOLOCK) 
 where agent_branch_code=m.branch_code and m.tranno=@tranno  
 and branch_limit is not null  
  
 if(select send_mode from #temp_moneysend where refno=@refno) in ('v','s')  
 begin   
  update cash_collected set tranno=NULL,  
  session_id=NULL,session_by=NULL,session_ts=NULL  
  from cash_collected c WITH(NOLOCK), #temp_moneysend m WITH(NOLOCK) 
  where c.tranno=m.tranno and m.tranno=@tranno and c.branch_id=m.branch_code  
 end  
  
declare @isPending int  
 if exists(select pending_id from deposit_detail WITH(NOLOCK)   
 where tranno=@tranno and pending_id is not null)  
  set @isPending=1  
  
if @status Not in ('Hold') or @status is NULL --OR @status='Block'  
begin  
 declare @invoice_no as int  
 set @invoice_no=ident_current('agentBalance')+1  
  
 insert into agentBalance(InVoiceNo,AgentCode,CompanyName,Dot,Amount,CurrencyType,XRate,Mode,staffId,dollar_rate,  
 remarks,branch_code,other_commission,tranno,approved_by,approved_ts)   
 select 'c:'+cast(@invoice_no as varchar),agentid,agentName,@gmt_date,paidAmt,paidCType,exchangerate,'Cancel',@cancel_by,  
 case when agent_dollar_rate is null then dollar_amt else totalRoundamt/ho_dollar_rate end,dbo.decryptDB(refno),   
 branch_code, senderCommission+isNull(agent_ex_gain,0) ,tranno, @cancel_by,@gmt_date  
 from #temp_moneysend WITH(NOLOCK)   
 where tranno=@tranno  
  
 if @isPending=1 -- IF it is PENDING   
 begin  
  insert pendingTransaction(bankCode,deposit_detail1,deposit_detail2,amtPaid,agentCode,branch_code,depositDOT,pending,postedby)   
  select bankCode,deposit_detail1,deposit_detail2,amtPaid,agentCode,branch_code,depositDOT,'y',postedby from pendingTransaction WITH(NOLOCK) where senderName=dbo.decryptDB(@refno)  
  
  update pendingTransaction set deposit_detail1=deposit_detail1 +' (Cancelled)' where senderName=dbo.decryptDB(@refno)  
 end  
   
end  
else if @status IN ('Hold')  
begin  
 if @isPending=1 -- IF it is PENDING   
  update pendingTransaction set senderName=NULL,confirmDate=NULL,confirmBy=NULL,pending='y' where senderName=dbo.decryptDB(@refno)  
  delete MoneySend where tranno=@tranno   
end 

----------------------------------------------------------------------------------------------------------------------------------
--------------------- Ticket -----------------------------------------------------------------------------------------------------

if @remarks is not null
begin
 insert TransactionNotes(RefNo,Comments,DatePosted,PostedBy,uploadBy,noteType,tranno)
 values(@refno,'Cancel Note:'+ @remarks,@gmt_date,@cancel_by,'A',2,@tranno)
end
insert TransactionNotes(RefNo,Comments,DatePosted,PostedBy,uploadBy,noteType,tranno)
values(@refno,'****Cancel Refno:' + dbo.decryptDb(@refno) +'****',@gmt_date,@cancel_by,'A',2,@tranno)

----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------  
--declare @enable_update_remoteDB char(1),@remote_db  varchar(200)  
--select @enable_update_remoteDB=enable_update_remote_DB,@remote_db=remote_db from tbl_interface_setup   
--where agentcode=@payout_agentid and mode='Send'  
---- for testing API  
----set @enable_update_remoteDB='n'  
--  
--if @enable_update_remoteDB='y' and (@status='Payment' or @status is NULL)  
--begin  
--  create table #temp(  
--   status varchar(100),  
--   remarks varchar(100)  
--  )  
--  set @sql_remote='spRemote_cancelTrns '''+@refno+''','''+@cancel_by+''','''+@gmt_get_date+''''  
--  set @sql_remote=@sql_remote+','''+@status+''',''#temp'''  
--  print @sql_remote  
--  exec (@sql_remote)  
--  if not exists(select * from #temp)   
--  begin  
--   select 'ERROR','Please Contact Headoffice for cancellation'  
--   rollback tran  
--   return  
--  end  
--  if (select status from #temp)='Error'  
--  begin  
--   select 'ERROR','Please Contact Headoffice for cancellation'  
--   rollback tran  
--   return  
--  end  
--end  
select 'SUCCESS',@refno  
commit tran  
if isNULL(@isPartner,'n')='n'  
exec spa_integration_partner_cancel_ticket 'c',NULL,@refno,'Cancel',NULL,NULL,@cancel_by,NULL,@remarks,@gmt_get_date,@DIG_INFO  
  
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