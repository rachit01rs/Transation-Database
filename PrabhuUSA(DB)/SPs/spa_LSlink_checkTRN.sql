DROP proc [dbo].[spa_LSlink_checkTRN]    
go
--spa_LSlink_checkTRN '219160055419','96700047','admin',':','904BAE39_B8DA_4BC5_ADA1_F9221080E418'  
--spa_LSlink_checkTRN '211105173621','96700000','pmtnepal','127.0.0.1','Dp5AF4950E091_472A_B1AD_3228E4F77E2A'  
--EXEC LS_PrabhuCash.PrabhuCash.dbo.spa_LSlink_checkTRN '217150105327','96700000','pmtnepal','127.0.0.1','A7C7BCB7_8452_4AAF_8FBF_B8EC807F6731'  
CREATE proc [dbo].[spa_LSlink_checkTRN]    
@control_no varchar(50),    
@payout_partner_id varchar(50),    
@payout_user_id varchar(50),    
@client_pc_id varchar(200),-- Digital ID or IP Address    
@session_id varchar(200)    
as    
  
Declare @sql varchar(max),@sql1 varchar(max),@temptablename varchar(1000),@sqlErr varchar(max),@agent_country varchar(50)  
  
set @temptablename=dbo.FNAProcessTBl(@payout_user_id, @payout_partner_id, @session_id)  
  
  
if exists ( select status from moneysend with (nolock) where status='Paid' and receivercountry='Nepal' and refno=dbo.encryptdb(@control_no))  
begin  
set @sql='select ''ERROR'' LS_status,''1001'' Code,''This Transaction has been Already Paid !!'' Message into '+@temptablename  
 exec(@sql)  
 return  
end  
if exists ( select status from moneysend with (nolock) where lock_status='locked' and receivercountry='Nepal' and refno=dbo.encryptdb(@control_no))  
begin  
set @sql='select ''ERROR'' LS_status,''1001'' Code,''This Transaction Status is Locked !!'' Message into '+@temptablename  
 exec(@sql)  
 return  
end  
  
if not exists(    
 select  status from moneysend with (nolock) where status='Un-Paid' and TransStatus='Payment' and paymenttype IN (select static_data FROM static_values WHERE sno=7 and (additional_value ='C' or additional_value='B'))  
 and (lock_status='unlocked' or lock_status is null)  and receivercountry='Nepal'    
 and refno=dbo.encryptdb(@control_no))    
 begin    
 set @sql='select ''ERROR'' LS_status,''1002'' Code,''Invalid Transaction'' Message into '+@temptablename  
 exec(@sql)  
 return  
 end    
  
set @sql1='  
SELECT ''SUCCESS'' LS_status,dbo.decryptdb(refno) refno, agentid, agentname, branch_code, branch, customerid,   
sendername, senderaddress, senderphoneno, sendersalary,  sendercity,   
sendercountry, senderemail, sendercompany, senderpassport, sendervisa, receivername, receiveraddress, receiverphone,    
receivercity, receivercountry, receiverrelation,   dot, dottime, paidamt, paidctype, receiveamt, receivectype,   
exchangerate, today_dollar_rate, dollar_amt, scharge,     
senderbankvoucherno,  paymenttype, rbankid, rbankname, rbankbranch, rbankacno,   
rbankactype, othercharge, transstatus, status, sempid,  imecommission, bankcommission, totalroundamt, transfertype,    
sendercommission, receiveagentid, send_mode,local_dot,sender_mobile,receiver_mobile,sendernativecountry,  
ip_address, agent_dollar_rate, ho_dollar_rate, bonus_amt, request_for_new_account,digital_id_sender,  
expected_payoutagentid,bonus_value_amount,bonus_type,bonus_on,ben_bank_id,ben_bank_name,paid_agent_id,  
ReciverMessage,send_sms,agent_settlement_rate,agent_ex_gain,agent_receiverSCommission,  
confirmDate,approve_by,customer_sno,senderFax,ReceiverIDDescription,payout_settle_usd,  
receiverID,TestQuestion,receiverID_placeOfIssue,'''+@session_id +''' session_id into '+@temptablename+'  
from moneysend with (nolock)   
 where status=''Un-Paid'' and TransStatus=''Payment''   
 and (paymenttype=''Cash Pay''  OR paymenttype IN (select static_data FROM static_values WHERE sno=7 and (additional_value =''C'' or additional_value=''B'')))      
 and (lock_status=''unlocked'' or lock_status is null)    
 and receivercountry=''Nepal''   
 and refno=dbo.encryptdb('''+@control_no+''')'  
--print (@sql1)  
exec(@sql1)  
  
if @@rowcount>0  
begin   
update moneysend set lock_status='locked',lock_dot=getdate(),lock_by=@payout_user_id    
where refno=dbo.encryptdb(@control_no)  
end   
     
  
  
    
    
    
    
    
    
  
  