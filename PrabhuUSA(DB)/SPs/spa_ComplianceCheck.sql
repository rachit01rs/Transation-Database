set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

  
--spa_ComplianceCheck 't',106814    
ALTER  proc [dbo].[spa_ComplianceCheck]  
@flag char(1), --- b  call from ConfirmSend page, c Compliance Check after TXN Saved , t --- Compliance Check ONLY                  
@tranno int=null,  
@Send_CountryName varchar(100)=NULL,  
@Payout_CountryName varchar(100)=NULL,  
@Sender_ID_Number varchar(50)=NULL,                    
@Send_Amount MOney=NULL,  
@Payout_Amount Money=NULL,  
@PaymentType varchar(50)=NULL,  
@Payout_AgentID varchar(20)=NULL,        
@Payout_BranchID Varchar(20)=NULL ,  
@TransStatus Varchar(50)=NULL ,    
@sender_mobile VARCHAR(15)=NULL       
as                    
declare @Block_Customer_Check_By varchar(50),@Block_Max_TXN_AMT money,@Block_Max_TXN_AMT_Days int,                    
@Block_CP_AMT_Sender char(1),@Block_CP_AMT_Beneficiary  char(1),@Block_Max_TXN_No int,@Block_Max_Txn_Nos_days int,                    
@Block_CP_No_Sender  char(1),@Block_CP_No_Beneficiary  char(1),@Max_App_Branch_Limit money                    
      ,@CP_If_TXN_Exceed_AMT money ,@Check_Dup1 varchar(50),@Check_Dup2  varchar(50),@Check_Dup3  varchar(50)                    
      ,@Check_Dup4  varchar(50),@Check_Dup5  varchar(50) ,@Hold_if_cash_date_ne_Txn_date char(1)                    
      ,@Ofac_Enabled  char(1),@Disabled_Cust_info_Teller char(1),@Max_po_amt_cash money                    
      ,@Max_po_amt_Deposit money ,@CP_Hold_PO_Cash money,@CP_HOLD_PO_Deposit money                    
      ,@sender_nativeCountry_beneficiary_country_notsame char(1) ,@Refno varchar(50), @userid varchar(50),          
  @Sender_Name varchar(100),                    
  @Receiver_Name varchar(100)            
declare @message varchar(MAX)  -- added by sujit                
declare @messageall varchar(MAX) -- added by sujit                
declare @txndate datetime ,@SenderNativeCountry varchar(100) ,@nos_of_branch_hold INT,@nos_of_branch_day INT ,    
@SSN_card_id VARCHAR(50)  ,@PartnerAgentCode VARCHAR(50) ,@Send_agent_id VARCHAR(50) ,@User_ID VARCHAR(50),@ofac_list CHAR(1)         
if @tranno is not null                
begin                    
   select               
   @Refno=refno,              
   @Send_CountryName=SenderCountry,                    
   @Payout_CountryName=ReceiverCountry,                    
   @Sender_Name=SenderName,          
   @SenderNativeCountry=SenderNativeCountry,                  
   @Receiver_Name=ReceiverName,                    
   @Sender_ID_Number=SenderPassport,                    
   @Send_Amount=paidAmt,                    
   @Payout_Amount=TotalRoundAmt,        
   @txndate=local_dot,        
   @PaymentType=PaymentType,    
   @sender_mobile=sender_mobile,    
   @SSN_card_id=SSN_card_id,    
   @PartnerAgentCode=expected_payoutagentid,    
   @Send_agent_id=agentid,    
   @User_ID=SEmpID,    
   @ofac_list=ofac_list    
    from moneysend with (nolock) where tranno=@tranno          
  set @userid='System'                  
end          
         
SELECT @Block_Customer_Check_By=Block_Customer_Check_By                    
      ,@Block_Max_TXN_AMT=Block_Max_TXN_AMT                    
      ,@Block_Max_TXN_AMT_Days=Block_Max_TXN_AMT_Days                    
      ,@Block_CP_AMT_Sender=Block_CP_AMT_Sender                    
      ,@Block_CP_AMT_Beneficiary=Block_CP_AMT_Beneficiary                    
      ,@Block_Max_TXN_No=Block_Max_TXN_No                    
      ,@Block_Max_Txn_Nos_days=Block_Max_Txn_Nos_days                    
      ,@Block_CP_No_Sender=Block_CP_No_Sender                    
      ,@Block_CP_No_Beneficiary=Block_CP_No_Beneficiary                    
      ,@Max_App_Branch_Limit=Max_App_Branch_Limit                    
      ,@CP_If_TXN_Exceed_AMT=CP_If_TXN_Exceed_AMT                    
      ,@Check_Dup1=Check_Dup1                    
      ,@Check_Dup2=Check_Dup2                    
      ,@Check_Dup3=Check_Dup3                    
      ,@Check_Dup4=Check_Dup4                    
      ,@Check_Dup5=Check_Dup5                    
      ,@Hold_if_cash_date_ne_Txn_date=Hold_if_cash_date_ne_Txn_date                    
      ,@Ofac_Enabled=Ofac_Enabled                    
      ,@Disabled_Cust_info_Teller=Disabled_Cust_info_Teller                    
      ,@sender_nativeCountry_beneficiary_country_notsame=sender_nativeCountry_beneficiary_country_notsame,    
      @nos_of_branch_hold=nos_of_branch_hold,@nos_of_branch_day=nos_of_branch_day    
  FROM Compliance_Setup                    
where countryName=@Send_CountryName                    
        
--------Check Payout Amoount          
SELECT  @Max_po_amt_cash=Max_po_amt_cash        
      ,@Max_po_amt_Deposit=Max_po_amt_Deposit,        
  @CP_Hold_PO_Cash=CP_Hold_PO_Cash                    
      ,@CP_HOLD_PO_Deposit=CP_HOLD_PO_Deposit                    
  FROM Compliance_Setup                    
where countryName=@Payout_CountryName        
             
-- code added by Sujit                   
                  
-- check amount limit with sender id with days                 
declare @CurrentDate datetime,@CP_Status int,@Return_Message varchar(1000),@suspicious_type VARCHAR(100)          
set @CurrentDate=cast( convert(varchar,dbo.GETDATEHo(getutcdate()),101) as datetime)              
Declare @check_amount_pass money,@check_amount_sender money,@check_amount_receiver money,              
@check_count_pass int,@check_count_sender int,@check_count_receiver int ,    
@check_count_branch int          
        
        
if @flag='b' --- Call this from ConfirmTXN Send Page        
begin        
  if @Send_CountryName is null or                   
   @Payout_CountryName is null or          
   @sender_mobile is null or                  
   @Send_Amount is null or                   
   @Payout_Amount is null or          
   @PaymentType is null         
  begin        
    Select 'Error' Status,'Required Field missing' Message        
   return        
  end        
        
     
 ---- Check Max Payout Amt by Payout Country Wise        
 if @Max_po_amt_cash>0 and @PaymentType='Cash Pay' and @Payout_Amount>=@Max_po_amt_cash         
 begin                    
  set @message = 'Payout Cash-Pickup Limit exceeded '+ cast(@Max_po_amt_cash as varchar) +' to '+ @Payout_CountryName                  
  Select 'Error' Status,@Message Message          
  return              
 end                 
 if @Max_po_amt_Deposit>0 and @PaymentType <> 'Cash Pay' and @Payout_Amount>=@Max_po_amt_Deposit         
 begin                    
    set @message = 'Payout Account Deposit Limit exceeded '+ cast(@Max_po_amt_cash as varchar) +' to '+ @Payout_CountryName                
    Select 'Error' Status,@Message Message        
    return              
 end           
        
set @Max_po_amt_cash=0        
set @Max_po_amt_Deposit=0        
declare @payout_agent_name varchar(150)        
if @Payout_AgentID  is not null     
BEGIN      
 select @payout_agent_name=a.Companyname,@Max_po_amt_cash=a.max_payout_amt_per_trans,  
 @Max_po_amt_Deposit=isNull(a.max_payout_amt_per_trans_deposit,a.max_payout_amt_per_trans)        
 from agentdetail a WITH (NOLOCK) where a.agentCode=@Payout_AgentID        
 IF @payout_agent_name IS NULL   
  SELECT @payout_agent_name=Ext_AgentName FROM dbo.Partner_Agents WHERE Ext_AgentCode=@Payout_AgentID   
END   
  
  
 ---- Check Max Payout Amt by Payout Country Wise        
 if @Max_po_amt_cash>0 and @PaymentType='Cash Pay' and @Payout_Amount>=@Max_po_amt_cash         
 begin                    
  set @message = @payout_agent_name +' Cash-Pickup Limit exceeded '+ cast(@Max_po_amt_cash as varchar) +' to '+ @Payout_CountryName                  
  Select 'Error' Status,@Message Message          
  return              
 end                 
 if @Max_po_amt_Deposit>0 and @PaymentType <> 'Cash Pay' and @Payout_Amount>=@Max_po_amt_Deposit         
 begin                    
    set @message = @payout_agent_name +' Account Deposit Limit exceeded '+ cast(@Max_po_amt_cash as varchar) +' to '+ @Payout_CountryName                
    Select 'Error' Status,@Message Message        
    return              
 end          
--------- Check Payout Agent wise Limit        
if @Payout_BranchID  is not null        
begin      
declare @branch_exists varchar(50) ,@branch_exists_partner varchar(50)    
-- if not exists (select b.agent_branch_code from agentdetail a join agentbranchdetail b on a.agentcode=b.agentcode        
-- where b.agent_branch_code=@Payout_BranchID and a.agentCode=@Payout_AgentID)      -- begin        
--   Select 'Error' Status,'Select Branch ID and Agent ID is not valid' Message        
--   return         
-- end        
select @branch_exists=b.agent_branch_code from agentdetail a join agentbranchdetail b on a.agentcode=b.agentcode        
where b.agent_branch_code=@Payout_BranchID and a.agentCode=@Payout_AgentID    
select @branch_exists_partner=b.Ext_agent_branch_code from Partner_Agents a join Partner_Branch b on a.Ext_agentcode=b.Ext_agentcode        
where b.Ext_agent_branch_code=@Payout_BranchID and a.Ext_agentcode=@Payout_AgentID    
  if @branch_exists is null and @branch_exists_partner is null    
  begin        
     Select 'Error' Status,'Select Branch ID and Agent ID is not valid' Message        
     return         
  end     
end        
         
 Select 'Success' Status,@payout_agent_name Message        
end          
          
if @flag in ('c','t') ----- Compliance CHeck after TXN Is saved in Table        
begin        
-- Get LAST TXN info    
DECLARE @last_senderPassport VARCHAR(50),@last_ssn_card_id VARCHAR(50),@last_tranno VARCHAR(50)    
    
SELECT TOP 1 @last_senderPassport=ISNULL(senderPassport,'-') ,@last_ssn_card_id=ISNULL(ssn_card_id,'-'),@last_tranno=tranno        
FROM moneysend with (nolock)              
where RIGHT(sender_mobile,10) = RIGHT(@sender_mobile,10)        
AND transStatus<>'cancel' AND Tranno < @tranno     
ORDER BY tranno DESC   
    
SELECT  @check_count_pass=COUNT(*),@check_amount_pass=isNull(SUM(paidAmt),0)       
FROM moneysend with (nolock)              
where local_dot between  dateadd(d,-@Block_Max_TXN_AMT_Days,@CurrentDate) and dbo.GETDATEHo(getutcdate())      
AND RIGHT(sender_mobile,10) = RIGHT(@sender_mobile,10)        
AND transStatus<>'cancel'     
     
SELECT @check_amount_sender=isNull(SUM(paidAmt),0), @check_count_sender=COUNT(*)           
FROM moneysend with (nolock)              
where local_dot between  dateadd(d,-@Block_Max_TXN_AMT_Days,@CurrentDate) and dbo.GETDATEHo(getutcdate())         
AND senderName=@Sender_Name     
AND transStatus<>'cancel'     
    
    
SELECT @check_amount_receiver=isNull(SUM(paidAmt),0) , @check_count_receiver=COUNT(*)           
FROM moneysend with (nolock)              
where local_dot between  dateadd(d,-@Block_Max_TXN_AMT_Days,@CurrentDate) and dbo.GETDATEHo(getutcdate())         
AND ReceiverName=@Receiver_Name    
AND transStatus<>'cancel'     
    
    
SELECT @check_count_branch= COUNT(DISTINCT branch_code)         
FROM moneysend with (nolock)              
where local_dot between  dateadd(d,-@nos_of_branch_day,@CurrentDate) and dbo.GETDATEHo(getutcdate())      
AND RIGHT(sender_mobile,10) = RIGHT(@sender_mobile,10)        
AND transStatus<>'cancel'    
    
IF  @check_amount_pass IS NULL    
 SET @check_amount_pass= @Send_Amount-1          
IF  @check_amount_sender IS NULL    
 SET @check_amount_sender= @Send_Amount-1         
IF  @check_amount_receiver IS NULL    
 SET @check_amount_receiver= @Send_Amount-1          
    
    
    
---Check Compliance by Send AMOUNT              
   --print 'Max BLock TXN Amount:-' + cast(@Block_Max_TXN_AMT as varchar) -- + 'Check amt pass:' + cast(@check_amount_pass as varchar)        
   --print 'Check Amt pass:-' + cast(@check_amount_pass as varchar)        
   --return;        
  --print 'Just before the condition checked!!!'         
declare @id_check_flag bit        
set @id_check_flag=0        
       
  if @Block_Max_TXN_AMT>0 and @check_amount_pass >=@Block_Max_TXN_AMT              
  begin            
   set @id_check_flag=1        
   set @message = 'Transaction Limit '+ cast(@Block_Max_TXN_AMT as varchar) +' exceeds by Customer ID!!!'                  
   set @CP_Status=1              
   set @Return_Message=@message              
        
 if @flag='c'        
   insert into transactionNotes(RefNo,Tranno,Comments,DatePosted,notetype,PostedBy,UploadBy,[status])                   
   values(@Refno,@tranno,@message,dbo.GETDATEHo(getutcdate()),'3',@userid,'Amount Exceed - ID','c')                 
        
  end                
       
 if @Block_CP_AMT_Sender='y' and @check_amount_sender >=@Block_Max_TXN_AMT   and @id_check_flag=0           
  begin                    
    set @message = 'Transaction Limit '+ cast(@Block_Max_TXN_AMT as varchar) +' exceeds by Sender Name!!!'                  
    set @CP_Status=1              
    set @Return_Message=case when @Return_Message is not null then @Return_Message + '|' else '' end + @message              
          
  if @flag='c'        
    insert into transactionNotes(RefNo,Tranno,Comments,DatePosted,notetype,PostedBy,UploadBy,[status])                   
    values(@Refno,@tranno,@message,dbo.GETDATEHo(getutcdate()),'3',@userid,'Amount Exceed - Sender Name','c')                 
  end                
 set @id_check_flag=0        
        
 if @Block_CP_No_Beneficiary='y' and @check_amount_receiver >=@Block_Max_TXN_AMT              
  begin                    
  set @message = 'Transaction Limit '+ cast(@Block_Max_TXN_AMT as varchar) +' exceeds by Beneficiary Name!!!'                  
  set @CP_Status=1              
  set @Return_Message=case when @Return_Message is not null then @Return_Message + '|' else '' end + @message              
 if @flag='c'          
  insert into transactionNotes(RefNo,Tranno,Comments,DatePosted,notetype,PostedBy,UploadBy,[status])                   
    values(@Refno,@tranno,@message,dbo.GETDATEHo(getutcdate()),'3',@userid,'Amount Exceed - Beneficiary Name','c')                 
  end                
              
---- Check Nos of TXN           
           
 if @Block_Max_TXN_No>0 and @check_count_pass >=@Block_Max_TXN_No              
  begin                    
 set @id_check_flag=1        
    set @message = 'Nos of '+cast(@Block_Max_TXN_No as varchar) +' TXN Limit exceeds by Customer ID!!!'                  
  set @CP_Status=1              
  set @Return_Message=case when @Return_Message is not null then @Return_Message + '|' else '' end + @message              
 if @flag='c'         
   insert into transactionNotes(RefNo,Tranno,Comments,DatePosted,notetype,PostedBy,UploadBy,[status])                   
  values(@Refno,@tranno,@message,dbo.GETDATEHo(getutcdate()),'3',@userid,'TXN Exceed - Customer ID','c')               
  end                
               
 if @Block_CP_No_Sender='y' and @check_count_sender >=@Block_Max_TXN_No  and @id_check_flag=0            
  begin                    
  set @message = 'Nos of '+cast(@Block_Max_TXN_No as varchar) +' TXN Limit exceeds by Sender Name!!!'                  
  set @CP_Status=1              
  set @Return_Message=case when @Return_Message is not null then @Return_Message + '|' else '' end + @message        
 if @flag='c'        
  insert into transactionNotes(RefNo,Tranno,Comments,DatePosted,notetype,PostedBy,uploadBy,[status])                   
  values(@Refno,@tranno,@message,dbo.GETDATEHo(getutcdate()),'3',@userid,'TXN Exceed - Sender Name','c')                 
  end                
          
  set @id_check_flag=0        
        
 if @Block_CP_No_Beneficiary='y' and @check_count_receiver >=@Block_Max_TXN_No              
  begin                    
  set @message = 'Nos of '+cast(@Block_Max_TXN_No as varchar) +' TXN Limit exceeds by Beneficiary Name!!!'                  
  set @CP_Status=1              
  set @Return_Message=case when @Return_Message is not null then @Return_Message + '|' else '' end + @message        
 if @flag='c'        
  insert into transactionNotes(RefNo,Tranno,Comments,DatePosted,notetype,PostedBy,uploadBy,[status])                   
  values(@Refno,@tranno,@message,dbo.GETDATEHo(getutcdate()),'3',@userid,'TXN Exceed - Beneficiary Name','c')                 
  end                
     
  --- Check Multiple branch TXN Sent    
  if @nos_of_branch_hold>0 and @check_count_branch >=@nos_of_branch_hold              
  begin            
   set @message = 'Customer has sent more than '+ cast(@nos_of_branch_hold as varchar) +' different branches with in past '+CAST(@nos_of_branch_day AS VARCHAR) +' days !!!'                  
   set @CP_Status=1              
   set @Return_Message=@message              
        
  if @flag='c'        
    insert into transactionNotes(RefNo,Tranno,Comments,DatePosted,notetype,PostedBy,UploadBy,[status])                   
    values(@Refno,@tranno,@message,dbo.GETDATEHo(getutcdate()),'3',@userid,'POS Multiple','c')                 
      
  end       
 --- Check Limit per TXN    
  if @CP_If_TXN_Exceed_AMT>0 and @Send_Amount >=@CP_If_TXN_Exceed_AMT  and @id_check_flag=0          
  begin            
   set @message = 'Customer has sent more than threshold amount '+ cast(@CP_If_TXN_Exceed_AMT as varchar) +' '                  
   set @CP_Status=1              
   set @Return_Message=@message              
        
 if @flag='c'        
   insert into transactionNotes(RefNo,Tranno,Comments,DatePosted,notetype,PostedBy,UploadBy,[status])                   
   values(@Refno,@tranno,@message,dbo.GETDATEHo(getutcdate()),'3',@userid,'Threshold Amount exceed per TXN','c')                 
        
  end      
  --- Check Last TXN ID is not same    
  if @last_senderPassport <> @Sender_ID_Number AND @last_tranno IS NOT NULL    
  begin            
 IF @last_senderPassport IS NULL    
 BEGIN     
   set @message = 'Customer with New Sender ID 1. Last Tran ID: '+@last_tranno    
   SET @suspicious_type='Sender ID 1 New Entry'    
 END     
 ELSE     
 BEGIN     
  set @message = 'Previous Customer Sender ID 1:'+ ISNULL(cast(@last_senderPassport as varchar),'Blank') +'. Last Tran ID: '+@last_tranno    
  SET @suspicious_type='Sender ID 1 Not matched with Previous TXN'    
 END     
   set @CP_Status=1              
   set @Return_Message=@message              
        
  if @flag='c'        
    insert into transactionNotes(RefNo,Tranno,Comments,DatePosted,notetype,PostedBy,UploadBy,[status])                   
    values(@Refno,@tranno,@message,dbo.GETDATEHo(getutcdate()),'3',@userid,@suspicious_type,'c')                     
  end       
      
  --- Check if new customer with id    
  if @Sender_ID_Number IS NOT NULL AND @last_tranno IS NULL      
  begin            
   set @message = 'Customer with New Sender ID 1 '+ cast(@Sender_ID_Number as varchar) +'. '    
   set @CP_Status=1              
   set @Return_Message=@message              
        
 if @flag='c'        
   insert into transactionNotes(RefNo,Tranno,Comments,DatePosted,notetype,PostedBy,UploadBy,[status])                   
   values(@Refno,@tranno,@message,dbo.GETDATEHo(getutcdate()),'3',@userid,'Sender ID 1 New Entry','c')                     
  end      
   --- Check Last SSN ID is not same    
  if @last_ssn_card_id <> @SSN_card_id   AND @last_tranno IS NOT NULL        
  begin            
   IF @last_ssn_card_id IS NULL    
 BEGIN     
   set @message = 'Customer with New Sender ID 2. Last Tran ID: '+@last_tranno    
   SET @suspicious_type='Sender ID 2 New Entry'    
 END     
 ELSE     
 BEGIN     
  set @message = 'Previous Customer Sender ID 2:'+ ISNULL(cast(@last_ssn_card_id as varchar),'Blank') +'. Last Tran ID: '+@last_tranno    
  SET @suspicious_type='Sender ID 2 Not matched with Previous TXN'    
 END     
     
   set @CP_Status=1              
   set @Return_Message=@message              
        
 if @flag='c'        
   insert into transactionNotes(RefNo,Tranno,Comments,DatePosted,notetype,PostedBy,UploadBy,[status])                   
   values(@Refno,@tranno,@message,dbo.GETDATEHo(getutcdate()),'3',@userid,@suspicious_type,'c')  
  end               
     
  --- New Customer with SSN ID     
  if @SSN_card_id IS NOT null  AND @last_tranno IS NULL        
  begin            
   set @message = 'Customer with new Sender ID 2 '+ cast(@SSN_card_id as varchar) +'.'               
   set @CP_Status=1              
   set @Return_Message=@message              
        
 if @flag='c'        
   insert into transactionNotes(RefNo,Tranno,Comments,DatePosted,notetype,PostedBy,UploadBy,[status])                   
   values(@Refno,@tranno,@message,dbo.GETDATEHo(getutcdate()),'3',@userid,'Sender ID 2 New Entry','c')                   
  end     
         
if @Hold_if_cash_date_ne_Txn_date = 'y'            
begin            
            
 declare @cashdate datetime            
            
 declare @datedif int            
            
 --SELECT @cashdate = collected_date from cash_collected where tranno = @tranno            
 --SELECT @txndate = dot from moneysend where tranno = @tranno            
            
 select @cashdate = min(collected_date) from cash_collected c  with (nolock)           
 where c.tranno = @tranno            
        
 set @datedif = DATEDIFF(day, @cashdate, @txndate)            
 --select @datedif            
            
 if @datedif <> 0            
 begin            
     set @CP_Status=1        
  set @message = 'Cash collected date is not similar to TXN Date!!!'            
  set @Return_Message=case when @Return_Message is not null then @Return_Message + '|' else '' end + @message        
 if @flag='c'          
  insert into transactionNotes(RefNo,Tranno,Comments,DatePosted,notetype,PostedBy,[status])                   
  values(@Refno,@tranno,@message,dbo.GETDATEHo(getutcdate()),'3',@userid,'c')        
             
 end            
             
end           
        
if @sender_nativeCountry_beneficiary_country_notsame = 'y'        
begin        
    if @SenderNativeCountry is not null         
 begin         
  if LTRIM(RTRIM(@SenderNativeCountry)) <> LTRIM(RTRIM(@Payout_CountryName))        
  begin        
    set @CP_Status=1        
    set @message = 'Remitter Native country and Beneficary Country does not match!!!'            
    set @Return_Message=case when @Return_Message is not null then @Return_Message + '|' else '' end + @message              
    if @flag='c'        
     insert into transactionNotes(RefNo,Tranno,Comments,DatePosted,notetype,PostedBy,uploadBy,[status])                   
     values(@Refno,@tranno,@message,dbo.GETDATEHo(getutcdate()),'3',@userid,'Native and Payout not matched','c')        
  end        
 end        
        
end        
        
-- the above select part has not been checked yet        
        
if @CP_Hold_PO_Cash>0 and @PaymentType='Cash Pay' and @Payout_Amount>=@CP_Hold_PO_Cash         
begin                    
   set @message = 'High volume Cash Pickup: '+cast(@Payout_Amount as varchar) +' !!!'                  
   set @CP_Status=1              
   set @Return_Message=case when @Return_Message is not null then @Return_Message + '|' else '' end + @message          
   if @flag='c'            
  insert into transactionNotes(RefNo,Tranno,Comments,DatePosted,notetype,PostedBy,uploadBy,[status])                   
  values(@Refno,@tranno,@message,dbo.GETDATEHo(getutcdate()),'3',@userid,'High volume Payout Amount - Cash Pickup','c')                 
end                 
if @CP_HOLD_PO_Deposit>0 and @PaymentType<> 'Cash Pay' and @Payout_Amount>=@CP_HOLD_PO_Deposit         
begin                    
   set @message = 'High volume AC Deposit: '+cast(@Payout_Amount as varchar) +' !!!'                  
   set @CP_Status=1              
   set @Return_Message=case when @Return_Message is not null then @Return_Message + '|' else '' end + @message         
   if @flag='c'             
  insert into transactionNotes(RefNo,Tranno,Comments,DatePosted,notetype,PostedBy,uploadby,[status])                   
  values(@Refno,@tranno,@message,dbo.GETDATEHo(getutcdate()),'3',@userid,'High volume Payout Amount- Account Deposit','c')  
end             
DECLARE @process_id VARCHAR(150)    
SET @process_id=dbo.FNAGetNewID()    
    
IF @ofac_list='y' AND @flag='c'    
BEGIN    
  insert into transactionNotes(RefNo,Tranno,Comments,DatePosted,notetype,PostedBy,uploadby,[status])                   
  values(@Refno,@tranno,'Customer is listed in OFAC',dbo.GETDATEHo(getutcdate()),'3',@userid,'OFAC','c')                 
END      
if @CP_Status=1         
begin        
  if @flag='c'        
  begin        
  IF @TransStatus='Hold'    
  BEGIN    
     update moneysend set TransStatus='Hold', compliance_flag='y',compliance_sys_msg='Suspicious Detected. Please check Ticket for detail info'        
     where tranno=@tranno       
  END    
  ELSE ------------- Auto Approve TXN Falls under Compliance    
  BEGIN    
     update moneysend set TransStatus='Compliance',confirmDate=local_dot,    
     approve_by=SEmpID,confirm_process_id=@process_id,    
     HO_confirmDate=dbo.getDateHO(getutcdate()),    
     compliance_flag='y',compliance_sys_msg='Suspicious Detected. Please check Ticket for detail info'        
     where tranno=@tranno        
   END     
  end        
  select 'Error' Status,@Return_Message as Message        
end         
else        
begin        
  if @flag='c'        
  begin        
  IF @TransStatus='Hold'    
  BEGIN    
   update moneysend set TransStatus='Hold' where tranno=@tranno     
  END    
  ELSE ------------- Auto Approve TXN    
  BEGIN    
   IF @ofac_list='y'    
   BEGIN     
    update moneysend set TransStatus='OFAC',confirmDate=local_dot,approve_by=SEmpID,HO_confirmDate=dbo.getDateHO(getutcdate()),    
    confirm_process_id=@process_id    
    where tranno=@tranno     
   END     
   ELSE     
   BEGIN ---- TXN Doesn't falls under OFAC and COmpliance    
       
    update moneysend set TransStatus='Payment',confirmDate=local_dot,approve_by=SEmpID,HO_confirmDate=dbo.getDateHO(getutcdate()),    
    confirm_process_id=@process_id    
    where tranno=@tranno        
       
    IF EXISTS (select enable_update_remote_DB from tbl_interface_setup WHERE enable_update_remote_DB='y' and mode='Send' and PartnerAgentCode=@PartnerAgentCode)    
    BEGIN     
     exec spRemote_sendTrns 'i',@tranno,@User_ID,@Send_agent_id, @process_id    
    END     
   END     
  END     
  end         
  select 'Success' Status,'Success c' as Message         
END     
              
END     
    
  
  
