DROP PROCEDURE spa_Search_TxnForAmendment
GO
CREATE PROC [dbo].[spa_Search_TxnForAmendment]                                                    
@flag char(1),                                                    
@tranno int,                                
@Partner_agentid varchar(50),                                
@refno varchar(50) = NULL,                          
@sempid varchar(50)=null                                
AS                                
if @flag='s'                                
begin                                
                                        
  declare @receiverCountry varchar(100),@senderName varchar(150),@receiverName varchar(150),                           
  @SenderNativeCountry varchar(150),@totalroundAmt money, @db_sempid varchar(50), @status varchar(10),                          
  @transstatus varchar(10),@is_downloaded char(10),@acknowledge_by varchar(50),@ofac_list char(1),@ofac_app_by varchar(50),                          
  @compliance_flag char(1), @lock_status varchar(20),@agent_id varchar(50)                          
                        
  select @agent_id=agentid,@db_sempid=sempid,@status=status,@transstatus=transstatus                          
  ,@is_downloaded=is_downloaded,@receiverCountry=receivercountry,@senderName=sendername,@receiverName=receiverName,                                
  @SenderNativeCountry=SenderNativeCountry,@totalroundAmt=totalroundAmt                          
  from moneysend where tranno=@tranno and expected_payoutagentid=@Partner_agentid                  
                             
  if @db_sempid is null                               
  begin                                
   select 'ERROR' Error,'1001' ErrorCode, 'Requested Transaction not Belongs to Payout Agent CIMB' ErrorMessage                                
   return                                
  end                            
                            
  declare @TRN_APV_NOT_SAME char(1)                        
  declare @gmt_now datetime,@row_approved int,@gmt_value varchar(10),@mangmt_appv_trn_local money                          
                        
  select @gmt_value=gmt_value, @TRN_APV_NOT_SAME = dont_allow_apv_same_user from agentDetail where agentCode=@agent_id                                          
  select @mangmt_appv_trn_local=mangmt_appv_trn_local from agent_function where agent_id=@agent_id                                
                        
                        
  declare @ex_rate_margin float,@sCharge_margin float                                
                         
                      
                        
  if upper(@status)='PAID'                          
  begin                          
   select 'ERROR' Error,'1001' ErrorCode, 'This already paid' ErrorMessage                                
   return                                
  end                          
                              
 declare @DestinationCountry varchar(5),
		 @senderFirstName varchar(50),
		 @senderLastName varchar(50),
		 @Nationality varchar(10),                                
		 @receiverFirstName varchar(50),
		 @receiverMiddleName VARCHAR(50),
		 @receiverLastName varchar(50),
		 @confirm_process_id VARCHAR(200)                    
                               
 --print @receiverCountry                            
                    
 SELECT @confirm_process_id=ms.confirm_process_id FROM moneySend ms WHERE tranno=@tranno AND ms.expected_payoutagentid=@Partner_agentid              
 /*--------- SENDER Name --------------*/                                                        
 select @senderFirstName=ltrim(rtrim(FirstName+' '+isNULL(MiddleName,''))),
		@senderLastName=ltrim(rtrim(isNULL(LastName,''))) 
 from split_FullName(@senderName)
 
  /*--------- RECEIVER Name --------------*/                                               
-- select @receiverFirstName=ltrim(rtrim(FirstName+' '+isNULL(MiddleName,''))),
--		@receiverLastName=ltrim(rtrim(isNULL(LastName,''))) 
-- from split_FullName(@receiverName)
select @receiverFirstName=ISNULL(FirstName,''),
	   @receiverMiddleName=ISNULL(MiddleName,''),
	   @receiverLastName=ISNULL(LastName,'')
from split_FullName(@receiverName) 
                                                              
 select               
 dbo.decryptdb(refno) PartnerTransactionID,              
  tranno Tranno,                                    
   convert(varchar,local_dot,101)+' '+convert(varchar,local_dot,108) ProcessDateTime,                                
   @receiverCountry DestinationCountry,                                
   receivectype DestinationCurrency,                                
   paymentType paymentType,                                                
   round((ext_payout_amount/Today_dollar_rate),0,1) LocalAmount,             
   receiveamt PayoutAmount,                                
   expected_payoutagentid PayoutAgentID,                  
   @senderFirstName senderFirstName,                                
   @senderLastName senderLastName,                                
   ltrim(rtrim(senderAddress)) senderAddress,                                              
   ltrim(rtrim(senderCity)) senderCity,                                
   Sender_State senderState,                                
   testquestion senderPostcode,                                
   sendercountry senderCountry,                                
   ltrim(rtrim(senderPhoneno)) senderPhoneNumber,                                
   ltrim(rtrim(sender_mobile)) senderMobileNumber,                                                                
   ReceiverIDDescription receiverIDType,                                
   receiverid receiverID_No,                                
 ID_Issue_Date benID_DateOfExpiry,       
   --replace(convert(varchar,dbo.CTGetdate(isnull(ID_Issue_Date,getdate())),111),'/','-')  benID_DateOfExpiry,                                
  -- replace(convert(varchar,cast(sendervisa as datetime),111),'/','-') DateOfExpiry,                                          
  --replace(convert(varchar,Date_of_birth,111),'/','-') DateOfBirth,                                           
   case when fax_trans='M' THEN '1'/*male*/ ELSE '2'/*female*/ end ben_Gender,                                                              
   @receiverFirstName receiverFirstName, 
   @receiverMiddleName receiverMiddleName ,                              
   @receiverLastName receiverLastName,                                
   ltrim(rtrim(ReceiverAddress)) receiverAddress,                                                
   @receiverCountry receiverCountry,              
   receiverfax receiverstate,                                
   ltrim(rtrim(receiverPhone)) receiverPhoneNumber,                                
   ltrim(rtrim(receiver_mobile)) receiverMobileNumber,                                                              
   case when paymentType='Bank Transfer' then rBankAcNo else '' end BankAccount,                                
   case when paymentType='Bank Transfer' then ben_bank_name else '' end Bank,                                
   case when paymentType='Bank Transfer' then ben_bank_id else '' end LocalBankCode,                                
   case when paymentType='Bank Transfer' then rBankAcType else '' end BankBranch,                                
   case when paymentType='Bank Transfer' then PNBReferenceNO else '' end BankAddress,                                                  
   sEmpId,is_downloaded,lock_status,status,transstatus/*,acknowledge_by*/,confirm_process_id,refno ,                              
   ofac_list,ofac_app_by,ofac_app_ts, compliance_flag,compliance_sys_msg,      
   Branch_code  Branch_code ,DOT                             
   from moneysend where tranno=@tranno                                         
end 