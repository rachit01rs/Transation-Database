
/****** Object:  StoredProcedure [dbo].[spa_ComplianceCheck_V2]    Script Date: 09/16/2013 02:06:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--spa_ComplianceCheck 't',106814    
--[spa_ComplianceCheckAuto_V2]  'd'   
Alter proc [dbo].[spa_ComplianceCheckAuto_V2]              
@flag char(1)= null--- b  call from ConfirmSend page, c Compliance Check after TXN Saved , t --- Compliance Check ONLY                  
   
as   

declare @tranno int,                    
@Send_CountryName varchar(100),                    
@Payout_CountryName varchar(100),         
@Sender_ID_Number varchar(50),                    
@Send_Amount MOney,                    
@Payout_Amount Money,         
@PaymentType varchar(50),                    
@Payout_AgentID varchar(20),        
@Payout_BranchID Varchar(20) ,    
@TransStatus Varchar(50) ,    
@sender_mobile VARCHAR(15)   

--declare @flag char(1)
--set @flag='c'
--drop table #temp    
--drop table #PaymentRule_Setup_v2          
--drop table #TEMP_TRANNO
if @flag='d'
begin
	delete moneysend_staging where status='c'
	return
end
DECLARE @sno_staging int  
  
SELECT TOP 1 @sno_staging=sno,@tranno=ms.Tranno,@TransStatus=ms.TransStatus  
  FROM moneysend_staging ms with (nolock) WHERE STATUS IS NULL OR (ms.[status]='p' AND datediff(mi,process_ts,GETDATE())>5)  
ORDER BY sno  
  
  if @sno_staging is Null
	return
UPDATE moneysend_staging  
SET STATUS='p',process_ts=GETDATE() WHERE sno=@sno_staging  
  

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
@SSN_card_id VARCHAR(50)  ,@PartnerAgentCode VARCHAR(50) ,@Send_agent_id VARCHAR(50) ,@User_ID VARCHAR(50),@ofac_list CHAR(1),
@send_states VARCHAR(150),@remitter_address VARCHAR(200),@benef_account_no VARCHAR(150)         
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
   @ofac_list=ofac_list,
   @send_states=ad.states,
   @remitter_address=m.SenderAddress,
   @benef_account_no=m.rBankACNo    
    from moneysend m with (nolock) JOIN agentDetail ad
    ON m.agentid=ad.agentCode
     where tranno=@tranno          
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
 select @payout_agent_name=a.Companyname,@Max_po_amt_cash=a.max_payout_amt_per_trans,@Max_po_amt_Deposit=isNull(a.max_payout_amt_per_trans_deposit,a.max_payout_amt_per_trans)        
 from agentdetail a WITH (NOLOCK) where a.agentCode=@Payout_AgentID        
        
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
    
  
CREATE TABLE #temp  
(  
 compliance_id INT  
) 

SELECT p.* INTO #PaymentRule_Setup_v2  
FROM   (  
           SELECT sno  
           FROM   PaymentRule_Setup_v2 prs  WITH (NOLOCK)
           WHERE  prs.destination_country IS NULL  
                  AND prs.send_agent_country IS NULL  
                  AND prs.enable_disable = 'y'  
                  AND prs.admin_check='y'
           UNION   
           SELECT sno  
           FROM   PaymentRule_Setup_v2 prs  WITH (NOLOCK) 
           WHERE  send_agent_country = @Send_CountryName  
                  AND prs.destination_country IS NULL  
                  AND prs.send_states IS NULL  
                  AND prs.enable_disable = 'y' 
                  AND prs.admin_check='y'  
           UNION  
           SELECT sno  
           FROM   PaymentRule_Setup_v2 prs  WITH (NOLOCK)
           WHERE  prs.send_states = @send_states  
                  AND prs.destination_country IS NULL  
                  AND prs.enable_disable = 'y'  
                  AND prs.admin_check='y'
           UNION  
           SELECT sno  
           FROM   PaymentRule_Setup_v2 prs  WITH (NOLOCK)
           WHERE  prs.destination_country = @Payout_CountryName  
                  AND prs.send_agent_country IS NULL  
                  AND prs.enable_disable = 'y'  
                  AND prs.admin_check='y' 
           UNION   
           SELECT sno  
           FROM   PaymentRule_Setup_v2 prs  WITH (NOLOCK)
           WHERE  prs.destination_country = @Payout_CountryName  
                  AND prs.send_agent_country = @Send_CountryName  
                  AND prs.send_states IS NULL  
                  AND prs.enable_disable = 'y' 
                  AND prs.admin_check='y'  
           UNION   
           SELECT sno  
           FROM   PaymentRule_Setup_v2 prs  WITH (NOLOCK)
           WHERE  prs.destination_country = @Payout_CountryName  
                  AND prs.send_states = @send_states  
                  AND prs.enable_disable = 'y'  
                  AND prs.admin_check='y'
       ) l  
       JOIN PaymentRule_Setup_v2 p  WITH (NOLOCK)
            ON  l.sno = p.sno   
  
      
 ---- Check by Customer Mobile  
INSERT #temp  
  (  
    compliance_id  
  )  
SELECT p.sno  
FROM   #PaymentRule_Setup_v2 p  
       OUTER APPLY(  
    SELECT SUM(paidamt) Send_Amount,  
           COUNT(*) TotalTXN  
    FROM   moneySend ms WITH (NOLOCK)  
    WHERE  ms.transStatus <> 'Cancel'  
           AND ms.local_dot BETWEEN DATEADD(d, p.nos_of_days * -1, dbo.GETDATEHo(GETUTCDATE()))   
               AND dbo.GETDATEHo(GETUTCDATE())  
           AND  RIGHT(ms.sender_mobile, 10)=RIGHT(@sender_mobile, 10)             
) a  
WHERE  (max_send_amount <= (@Send_Amount + ISNULL(Send_Amount, 0)) and Send_Amount is not null)  
       OR  (max_sender_nos <= (1 + ISNULL(TotalTXN, 0)) and TotalTXN is not nULL)  
          
---- Check by Remitter Name  
IF EXISTS (SELECT * FROM #PaymentRule_Setup_v2 p WITH (NOLOCK) WHERE p.check_remitter = 'y')  
BEGIN   
INSERT #temp  
  (  
    compliance_id  
  )  
SELECT sno  
FROM   #PaymentRule_Setup_v2 p  
       OUTER APPLY(  
    SELECT SUM(paidamt) Send_Amount,  
           COUNT(*) TotalTXN  
    FROM   moneySend ms WITH (NOLOCK)  
    WHERE  ms.transStatus <> 'Cancel'  
           AND ms.local_dot BETWEEN DATEADD(d, p.nos_of_days * -1, dbo.GETDATEHo(GETUTCDATE()))   
               AND dbo.GETDATEHo(GETUTCDATE())  
           AND REPLACE(ms.SenderName, ' ', '') = REPLACE(@Sender_Name, ' ', '')  
           AND RIGHT(ms.sender_mobile, 10) <> RIGHT(@sender_mobile, 10)  
) a  
WHERE  ( (max_send_amount <= (@Send_Amount + ISNULL(Send_Amount, 0)) and Send_Amount is not null)  
       OR  (max_sender_nos <= (1 + ISNULL(TotalTXN, 0)) and TotalTXN is not nULL))  
       AND p.check_remitter = 'y'  
  
END  


---- Check by Benef Name  
IF EXISTS (SELECT * FROM #PaymentRule_Setup_v2 p WITH (NOLOCK) WHERE p.check_benef = 'y')  
BEGIN   
INSERT #temp  
  (  
    compliance_id  
  )  
SELECT sno  
FROM   #PaymentRule_Setup_v2 p  
       OUTER APPLY(  
    SELECT SUM(paidamt) Send_Amount,  
           COUNT(*) TotalTXN  
    FROM   moneySend ms WITH (NOLOCK)  
    WHERE  ms.transStatus <> 'Cancel'  
           AND ms.local_dot BETWEEN DATEADD(d, p.nos_of_days * -1, dbo.GETDATEHo(GETUTCDATE()))   
               AND dbo.GETDATEHo(GETUTCDATE())  
           AND REPLACE(ms.ReceiverName, ' ', '') = REPLACE(@Receiver_Name, ' ', '')  
           AND RIGHT(ms.sender_mobile, 10) <> RIGHT(@sender_mobile, 10)  
) a  
WHERE  ( (max_send_amount <= (@Send_Amount + ISNULL(Send_Amount, 0)) and Send_Amount is not null)  
       OR  (max_sender_nos <= (1 + ISNULL(TotalTXN, 0)) and TotalTXN is not nULL))  
       AND p.check_benef = 'y'  
END  


---- Check by Remitter Address  
IF EXISTS (SELECT * FROM #PaymentRule_Setup_v2 p WITH (NOLOCK) WHERE p.check_remitter_address = 'y')  
BEGIN   
INSERT #temp  
  (  
    compliance_id  
  )  
SELECT sno  
FROM   #PaymentRule_Setup_v2 p  
       OUTER APPLY(  
    SELECT SUM(paidamt) Send_Amount,  
           COUNT(*) TotalTXN  
    FROM   moneySend ms WITH (NOLOCK)  
    WHERE  ms.transStatus <> 'Cancel'  
           AND ms.local_dot BETWEEN DATEADD(d, p.nos_of_days * -1, dbo.GETDATEHo(GETUTCDATE()))   
               AND dbo.GETDATEHo(GETUTCDATE())  
           AND REPLACE(ms.SenderAddress, ' ', '') = REPLACE(@remitter_address, ' ', '')  
           AND RIGHT(ms.sender_mobile, 10) <> RIGHT(@sender_mobile, 10)  
) a  
WHERE ( (max_send_amount <= (@Send_Amount + ISNULL(Send_Amount, 0)) and Send_Amount is not null)  
       OR  (max_sender_nos <= (1 + ISNULL(TotalTXN, 0)) and TotalTXN is not nULL))  
       AND p.check_remitter_address = 'y'  
END  

---- Check by Beneficiary Account No  
IF EXISTS (SELECT * FROM #PaymentRule_Setup_v2 p WITH (NOLOCK) WHERE p.check_benef_acc_no = 'y')  
BEGIN   
INSERT #temp  
  (  
    compliance_id  
  )  
SELECT sno  
FROM   #PaymentRule_Setup_v2 p  
       OUTER APPLY(  
    SELECT SUM(paidamt) Send_Amount,  
           COUNT(*) TotalTXN  
    FROM   moneySend ms WITH (NOLOCK)  
    WHERE  ms.transStatus <> 'Cancel'  
           AND ms.local_dot BETWEEN DATEADD(d, p.nos_of_days * -1, dbo.GETDATEHo(GETUTCDATE()))   
               AND dbo.GETDATEHo(GETUTCDATE())  
           AND REPLACE(ms.rBankACNo, ' ', '') = REPLACE(@benef_account_no, ' ', '')  
           AND RIGHT(ms.sender_mobile, 10) <> RIGHT(@sender_mobile, 10)  
) a  
WHERE  ( (max_send_amount <= (@Send_Amount + ISNULL(Send_Amount, 0)) and Send_Amount is not null)  
       OR  (max_sender_nos <= (1 + ISNULL(TotalTXN, 0)) and TotalTXN is not nULL))  
       AND p.check_benef_acc_no = 'y'  
END   

---- Check by Different Location  
IF EXISTS (SELECT * FROM #PaymentRule_Setup_v2 p WITH (NOLOCK) WHERE p.check_location_id = 'y')  
BEGIN   
INSERT #temp  
  (  
    compliance_id  
  )  
SELECT sno  
FROM   #PaymentRule_Setup_v2 p  
       OUTER APPLY(  
    SELECT COUNT(DISTINCT branch_code) TotalTXN  
    FROM   moneySend ms WITH (NOLOCK)  
    WHERE  ms.transStatus <> 'Cancel'  
           AND ms.local_dot BETWEEN DATEADD(d, p.nos_of_days * -1, dbo.GETDATEHo(GETUTCDATE()))   
               AND dbo.GETDATEHo(GETUTCDATE())  
           AND RIGHT(ms.sender_mobile, 10) = RIGHT(@sender_mobile, 10)  
) a  
WHERE   max_sender_nos <= (1 + ISNULL(TotalTXN, 0)) and TotalTXN is not null  
       AND p.check_location_id = 'y'  
END   
     

 IF EXISTS(SELECT * FROM #temp)  AND @flag='c'
 BEGIN     
      
  INSERT INTO TransactionNotes    
  (    
       
   RefNo,    
   Comments,    
   DatePosted,    
   PostedBy,    
   uploadBy,    
   noteType,    
   tranno,    
   [status]    
       
  )    
  select distinct    
   @Refno,    
   prsv.RuleName,    
   dbo.GETDATEHo(getutcdate()),    
   'system',    
   prsv.RuleName,    
   '3',    
   @tranno,    
   tcl.compliance_id       
  FROM #temp tcl JOIN PaymentRule_Setup_v2 prsv    
  ON tcl.compliance_id=prsv.sno       
 END  
 
declare @id_check_flag bit        
set @id_check_flag=0        
       

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
    set @Return_Message=case when @Return_Message is not null then @Return_Message + '|' else '' end + @message              
        
  if @flag='c'        
    insert into transactionNotes(RefNo,Tranno,Comments,DatePosted,notetype,PostedBy,UploadBy)                   
    values(@Refno,@tranno,@message,dbo.GETDATEHo(getutcdate()),'3',@userid,@suspicious_type)                     
  end       
      
  --- Check if new customer with id    
  if @Sender_ID_Number IS NOT NULL AND @last_tranno IS NULL      
  begin            
   set @message = 'Customer with New Sender ID 1 '+ cast(@Sender_ID_Number as varchar) +'. '    
   set @CP_Status=1              
   set @Return_Message=@message              
        
	 if @flag='c'        
	   insert into transactionNotes(RefNo,Tranno,Comments,DatePosted,notetype,PostedBy,UploadBy)                   
	   values(@Refno,@tranno,@message,dbo.GETDATEHo(getutcdate()),'3',@userid,'Sender ID 1 New Entry')                     
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
   set @Return_Message=case when @Return_Message is not null then @Return_Message + '|' else '' end + @message               
        
  if @flag='c'        
   insert into transactionNotes(RefNo,Tranno,Comments,DatePosted,notetype,PostedBy,UploadBy)                   
   values(@Refno,@tranno,@message,dbo.GETDATEHo(getutcdate()),'3',@userid,@suspicious_type)                   
  end               
     
  --- New Customer with SSN ID     
  if @SSN_card_id IS NOT null  AND @last_tranno IS NULL        
  begin            
   set @message = 'Customer with new Sender ID 2 '+ cast(@SSN_card_id as varchar) +'.'               
   set @CP_Status=1              
   set @Return_Message=case when @Return_Message is not null then @Return_Message + '|' else '' end + @message              
        
 if @flag='c'        
   insert into transactionNotes(RefNo,Tranno,Comments,DatePosted,notetype,PostedBy,UploadBy)                   
   values(@Refno,@tranno,@message,dbo.GETDATEHo(getutcdate()),'3',@userid,'Sender ID 2 New Entry')                   
  end     
                
        
DECLARE @process_id VARCHAR(150)    
SET @process_id=dbo.FNAGetNewID()    
    
IF @ofac_list='y' AND @flag='c'    
BEGIN    
  insert into transactionNotes(RefNo,Tranno,Comments,DatePosted,notetype,PostedBy,uploadby)                   
  values(@Refno,@tranno,'Customer is listed in OFAC',dbo.GETDATEHo(getutcdate()),'3',@userid,'OFAC')                 
END  
  
  
      
IF @CP_Status=1         
BEGIN        
  IF @flag='c'        
  BEGIN        
   IF @TransStatus='Hold'    
   BEGIN    
   update moneysend set TransStatus='Hold',   
        compliance_flag='y',  
        compliance_sys_msg='Suspicious Detected. Please check Ticket for detail info'        
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
  END        
  SELECT 'Error' Status,@Return_Message as Message        
END         
ELSE        
BEGIN        
  IF @flag='c'        
  BEGIN        
	IF @TransStatus='Hold'    
	 BEGIN    
			update moneysend set TransStatus='Hold' where tranno=@tranno     
	END    
  ELSE ------------- Auto Approve TXN    
  BEGIN    
   IF @ofac_list='y'    
   BEGIN     
    UPDATE moneysend SET TransStatus='OFAC',confirmDate=local_dot,approve_by=SEmpID,HO_confirmDate=dbo.getDateHO(getutcdate()),    
    confirm_process_id=@process_id    
    WHERE tranno=@tranno     
   END     
   ELSE     
   BEGIN ---- TXN Doesn't falls under OFAC and COmpliance    
       
    update moneysend set TransStatus='Payment',confirmDate=local_dot,approve_by=SEmpID,HO_confirmDate=dbo.getDateHO(getutcdate()),    
    confirm_process_id=@process_id    
    where tranno=@tranno        
       
--    IF EXISTS (select enable_update_remote_DB from tbl_interface_setup WHERE enable_update_remote_DB='y' and mode='Send'     
--    --and PartnerAgentCode=@PartnerAgentCode    
--    )    
--    BEGIN     
--     exec spRemote_sendTrns 'i',@tranno,@User_ID,@Send_agent_id, @process_id    
--    END     
   END     
  END     
  end         
  select 'Success' Status,'Success c' as Message  
END     
             
END     
   
------------------ START API AGENTS -------------------  
DECLARE @api_agent_id VARCHAR(MAX)     
SELECT @api_agent_id=xm_agentid+','+tranglo_agentid FROM tbl_setup   
     
SET @api_agent_id = LTRIM(RTRIM(@api_agent_id))  
SELECT @api_agent_id =CASE WHEN @api_agent_id IS NOT NULL AND @api_agent_id<>'' THEN   
  @api_agent_id+','+agentcode   
 ELSE agentcode END  
FROM tbl_integrated_agents  

CREATE TABLE #TEMP_TRANNO(tranno int)
INSERT INTO #TEMP_TRANNO
EXEC('select tranno from moneysend where tranno ='+@tranno+' and expected_payoutagentid in ('+@api_agent_id+')')
IF EXISTS(SELECT * FROM #TEMP_TRANNO)
BEGIN  
 print('update moneysend set transstatus=case when ofac_list=''y'' then ''OFAC''   
 when compliance_flag=''y'' then ''Compliance'' else ''Hold'' end where tranno = '+@tranno+'
 and expected_payoutagentid in ('+@api_agent_id+')  ')
END  
------------------ END API AGENTS -------------------  

--UPDATE moneysend_staging  SET STATUS='c',process_ts=GETDATE() WHERE sno=@sno_staging  