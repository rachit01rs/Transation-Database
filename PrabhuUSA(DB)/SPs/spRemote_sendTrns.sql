IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spRemote_sendTrns]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spRemote_sendTrns]
GO
/****** Object:  StoredProcedure [dbo].[spRemote_sendTrns]    Script Date: 04/11/2012 15:12:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--update moneysend set transstatus='Payment' where refno in (dbo.encryptdb('121342242911'),dbo.encryptdb('127334759227'),dbo.encryptdb('127594436327'),          
--dbo.encryptdb('121394172761'))          
--121342242911, 127334759227, 127594436327, 121394172761          
--,2425358,2425314,2425356          
--select confirm_process_id,dot,* from moneysend where refno=dbo.encryptdb('121342242911')          
--spRemote_sendTrns 'i','2425358','system','20100046','6D1B6848_B714_4477_A912_D38612FBC268','y'          
CREATE proc [dbo].[spRemote_sendTrns]          
 @flag char(1),          
 @tranno varchar(8000)=NULL,          
 @user_id varchar(50)=NULL,          
 @agent_id varchar(50)=NULL,          
 @process_id varchar(150),          
 @is_ofac_approved char(1)=null          
AS          
IF @flag='i'          
BEGIN          
DECLARE @remote_db varchar(200),@sql varchar(8000),@extra_value char(2),@dup_char char(1)          
DECLARE @payout_agentid varchar(50),@external_agent_id varchar(50),@external_branch_id varchar(50),          
@enable_update_remoteDB char(1),@external_agent_name varchar(200),@external_branch_name varchar(200),@PartnerAgentCode varchar(50)          
          
set @dup_char=dbo.encryptDb('i')          
          
create table #temp_payout(          
agentcode varchar(50)          
)          
          
exec('insert into #temp_payout(agentcode)          
select distinct expected_payoutagentid from moneysend with(nolock) where tranno in ('+@tranno+')')          
          
select @payout_agentid= agentcode from #temp_payout          
drop table #temp_payout          
          
select @PartnerAgentCode=PartnerAgentCode,@remote_db=remote_db,@external_agent_id=external_agent_id,          
@external_branch_id=external_branch_id,@enable_update_remoteDB=enable_update_remote_DB          
from tbl_interface_setup with(nolock)          
where agentcode=@payout_agentid and mode='Send'          
          
if @external_agent_id is NULL          
 set @external_agent_id='-1'          
if @external_branch_id is NULL          
 set @external_branch_id='-1'          
if @external_agent_name is NULL          
 set @external_agent_name='-1'          
if @external_branch_name is NULL          
 set @external_branch_name='-1'          
          
          
if @enable_update_remoteDB='y'          
BEGIN          
--if @is_ofac_approved is NULL          
--BEGIN          
          
set @sql='update moneysend set transStatus=''Processing'' where tranno IN ('+@tranno+')           
 and confirm_process_id='''+@process_id +''' AND transStatus=''Payment'' and status not in (''Paid'') '          
--if @is_ofac_approved is null          
--SET @sql=@sql + '  and ofac_list is null and compliance_flag is NULL'          
exec(@sql)          
          
          
declare @sql_temp varchar(MAX)          
          
set @sql_temp='insert into tbl_status_moneysend(PartnerAgentCode,Refno,Status,Process_Date,Update_date)          
select '''+@PartnerAgentCode+''',refno,''Pending'',getdate(),NULL from moneysend WITH (NOLOCK) where           
tranno IN ('+@tranno+') and confirm_process_id='''+@process_id+''' AND transStatus=''Processing'''          
set @sql_temp=@sql_temp+' and expected_payoutagentid='''+@payout_agentid +''''          
--if @is_ofac_approved is null          
-- SET @sql_temp=@sql_temp + '  and ofac_list is null and compliance_flag is NULL'          
print (@sql_temp)          
exec (@sql_temp)          
SET @sql='          
INSERT INTO '+@remote_db+'moneySend_integration          
           ([refno],[agentid],[agentname],[Branch_code],[Branch],[CustomerId],[SenderName],[SenderAddress]          
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
           ,[agent_settlement_rate],[agent_ex_gain],[agent_receiverCommission]  ,agent_receiverComm_Currency        
           ,[agent_receiverSCommission],[customer_sno]          
           ,[receiverID_placeOfIssue],[mileage_earn],isIRH_TRN,[transfer_ts],partnerSNO,[c2c_receiver_code],payout_settle_usd)          
SELECT tm.refno,case when '''+@external_agent_id+'''=''-1'' then isNull(sa.ext_agent_code,[agentid]) else '''+@external_agent_id+''' end          
     ,case when '''+@external_agent_name+'''=''-1'' then [agentname] else '''+@external_agent_name+''' end          
     ,case when '''+@external_branch_id+'''=''-1'' then isNUll(sb.ext_branch_code,[Branch_code]) else '''+@external_branch_id+''' end          
           ,case when '''+@external_branch_name+'''=''-1'' then m.[Branch] else '''+@external_branch_name+''' end          
     ,[CustomerId],[SenderName],[SenderAddress]          
           ,[SenderPhoneno],[senderSalary],[senderFax],[SenderCity],[SenderCountry],[SenderEmail]          
           ,[SenderCompany],[senderPassport],[senderVisa],[ReceiverName],[ReceiverAddress],[ReceiverPhone]          
           ,[ReceiverFax],[ReceiverCity],m.[ReceiverCountry],[ReceiverRelation],[ReceiverIDDescription]          
           ,[ReceiverID],[DOT],[DOtTime],[paidAmt],[paidCType],[receiveAmt],[receiveCType],[ExchangeRate]          
           ,[Today_Dollar_rate],[Dollar_Amt],[SCharge],isNull([ReciverMessage],'''')+'' /From :''+[agentname]+'',''+m.[Branch],[TestQuestion],[TestAnswer]          
           ,[amtSenderType],[SenderBankID],[SenderBankName],[SenderBankBranch],[SenderBankVoucherNo]          
           ,[Amt_paid_date],[paymentType],isNull(b.ext_branch_code,rBankID),isNull(b.branch_group,m.rBankName),[rBankBranch]          
           ,[rBankACNo],[rBankAcType],[otherCharge],          
            ''Payment''  [TransStatus]          
           ,m.[status],[SEmpID],[bTno],[imeCommission]          
           ,[bankCommission],[TotalRoundAmt],m.[TransferType]          
           ,[PODDate],[SCharge]-isNull([agent_receiverSCommission],0),[receiverCommission],m.[approve_by],[receiveAgentID],[send_mode]          
           ,[confirmDate],[local_DOT],[sender_mobile],[receiver_mobile]          
           ,[fax_trans],[SenderNativeCountry],[receiverEmail],[ip_address],[agent_dollar_rate]          
           ,[ho_dollar_rate],[bonus_amt],[request_for_new_account],[trans_mode],[digital_id_sender]          
           ,isNull(pa.ext_agent_code,expected_payoutagentid) [expected_payoutagentid],[bonus_value_amount]          
           ,[bonus_type],[bonus_on],[ben_bank_id],[ben_bank_name],[paid_agent_id],[send_sms]          
           ,[agent_settlement_rate],[agent_ex_gain],[agent_receiverCommission] ,agent_receiverComm_Currency         
           ,0.00,[customer_sno]          
           ,[receiverID_placeOfIssue],[mileage_earn],''y'',getdate(),tm.sno,m.c2c_receiver_code,m.payout_settle_usd          
FROM moneysend m with(nolock) join tbl_status_moneysend tm with(nolock) on m.refno=tm.refno          
left outer join agentbranchdetail b with(nolock) on b.agent_branch_code=m.rBankId          
left outer join agentbranchdetail sb with(nolock) on sb.agent_branch_code=m.branch_code          
join agentdetail sa with(nolock) on sa.agentcode=sb.agentcode          
join agentdetail pa with(nolock) on pa.agentcode=m.expected_payoutagentid          
WHERE m.tranno IN ('+@tranno+') and m.transStatus=''Processing'' and m.expected_payoutagentid='''+@payout_agentid+''' and m.confirm_process_id='''+ @process_id+''''          
  
  
--if @is_ofac_approved is null          
-- SET @sql=@sql + ' and m.ofac_list is null and m.compliance_flag is NULL'          
--END           
--ELSE--Normal Transaction Transfer          
--BEGIN          
--declare @approve_date varchar(50)          
--set @approve_date=dbo.getDateHO(getutcdate())          
--Declare @refno varchar(50)          
--select @refno=refno from moneySend WHERE tranno = @tranno and confirm_process_id=@process_id and expected_payoutagentid=@payout_agentid          
--set @sql= '  '+@remote_db+'spRemote_OFAC_Approve_Remote '''+@refno+''','''+@user_id+''','''+@approve_date+''''          
---- ofac_app_ts='''+@approve_date+'''  where refno='''+@refno+''''          
----set @sql= 'insert into '+@remote_db+'tbl_transstatus(refno,userid)          
----select '''+@refno+''','''+@userid+''''          
--END          
print (@sql)          
EXEC (@sql)       
SET @sql= 'update tbl_status_moneysend set status=''Approved'' from tbl_status_moneysend t with(nolock) join moneysend m WITH (NOLOCK) on t.refno=m.refno where           
m.tranno IN ('+@tranno+') and m.confirm_process_id='''+@process_id+''' AND m.transStatus=''Processing'''  
print (@sql)          
EXEC (@sql)    
--          
END          
END          
