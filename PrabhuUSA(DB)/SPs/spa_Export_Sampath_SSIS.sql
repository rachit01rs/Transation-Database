if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spa_Export_Sampath_SSIS]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spa_Export_Sampath_SSIS]
GO

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

CREATE PROC [dbo].[spa_Export_Sampath_SSIS]         
@flag CHAR(1),      
@downloadBy VARCHAR(50) = NULL       
AS      
SET NOCOUNT ON        
    DECLARE @expected_payoutagentid VARCHAR(50)      
    SET @expected_payoutagentid = ISNULL(@expected_payoutagentid, '20100151')      
      
IF @flag = 's'       
    BEGIN       
  select substring(dbo.decryptdb(refno),0,20) [Reference Number],        
  convert(varchar,cast(confirmDate as datetime),111) as [Transaction Date],        
  receiveCType as [Currency],        
  totalRoundAmt [Transaction Amount],        
  substring(senderName,0,50) as [Remitter’s Name],        
  substring(senderPassport,0,40) as [Remitter’s ID],        
  substring(isNULL(SenderPhoneno,sender_mobile),0,20) as [Remitter’s Contact no],        
  substring(isNULL(SenderAddress,'')+','+isNULL(SenderCity,'')+','+SenderCountry,0,200) as [Remitter’s Address],        
  substring(ReceiverName,0,50) as [Beneficiary’s Name],        
  substring(ReceiverID,0,40) as [Beneficiary’s ID],        
  substring(isNULL(ReceiverPhone,receiver_mobile),0,20) as [Beneficiary’s Contact No],        
  substring(isNULL(ReceiverAddress,'')+','+isNULL(ReceiverCity,''),0,200) as [Beneficiary’s Address],        
  substring(CASE WHEN RIGHT(RTRIM(ReciverMessage),1)='/' THEN LEFT(ReciverMessage, LEN(ReciverMessage)-1) ELSE ReciverMessage END,0,200) as [Message],        
    
  CASE WHEN paymentType='Account Deposit to Other Bank' THEN ISNULL(substring(m.rBankAcType,0,6),'')  
 ELSE substring(b.ext_branch_code,0,6) END as [Pay out branch code],        
  ISNULL(substring(b.branch,0,100),'') as [Pay out branch name],        
  CASE WHEN paymentType='Bank Transfer' THEN '7278'   
  WHEN paymentType='Account Deposit to Other Bank' THEN m.ben_bank_Id  
  ELSE '' END as [Pay out bank Code],   
  CASE WHEN paymentType='Bank Transfer' THEN ISNULL(substring(rBankName,0,50),'')   
 WHEN paymentType='Account Deposit to Other Bank' THEN  ISNULL(substring(m.rBankAcType,0,50),'')--ISNULL(substring(m.ben_bank_name,0,50),'')  
 ELSE '' END as [Pay out bank Name],    
  rBankACNo as [Account Number],       
  CASE WHEN paymentType IN('Bank Transfer','Account Deposit') THEN 'SBA'      
    WHEN paymentType = 'Account Deposit to Other Bank' THEN 'SLI'      
    WHEN paymentType = 'Cash Pay' THEN 'POI'      
    WHEN paymentType = 'RGTS' THEN 'SLI'      
  END [Remittance Type]        
        
  from moneysend m with (nolock)        
  left outer join agentbranchdetail b on m.rBankID=b.agent_branch_code    
  JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid        
  where  expected_payoutagentid=@expected_payoutagentid      
  and Transstatus = 'Payment' and status = 'Un-Paid' AND is_downloaded = 'p'  
  AND ISNULL(a.disable_payout,'n')<>'y'       
 END      
IF @flag = 'c'       
 BEGIN      
  UPDATE  dbo.moneySend      
  SET     is_downloaded = 'p' 
  FROM dbo.moneySend m WITH(NOLOCK)
  JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid       
  WHERE   expected_payoutagentid = @expected_payoutagentid      
    AND Transstatus = 'Payment'      
    AND status = 'Un-Paid'      
    AND is_downloaded IS NULL    
    AND ISNULL(a.disable_payout,'n')<>'y'    
      
  SELECT  COUNT(*) row_count      
  FROM    moneysend m WITH ( NOLOCK ) 
  JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid       
  WHERE   expected_payoutagentid = @expected_payoutagentid      
    AND is_downloaded = 'p'      
    AND ISNULL(a.disable_payout,'n')<>'y'  
 END      
      
IF @flag='u'      
 BEGIN      
 --SELECT 1    
--------------------------------------------------------------------------------------------    
   -- PIC Update to Post    
            DECLARE @remote_db VARCHAR(200) ,    
                @sql1 VARCHAR(MAX) ,    
                @paidDate VARCHAR(50) ,    
                @partneragentcode VARCHAR(50)    
    
            IF EXISTS ( SELECT  sno    
                        FROM    static_values    
                        WHERE   sno = 200    
                                AND static_value = 'Prabhu MY' )     
                BEGIN    
                    SELECT  @remote_db = additional_value ,    
                            @partneragentcode = static_data    
                    FROM    static_values    
                    WHERE   sno = 200    
                            AND static_value = 'Prabhu MY'    
    
                    SELECT  refno control_no ,    
 'Post' status    
                    INTO    #temp_MY    
                    FROM  moneysend m WITH ( NOLOCK )    
                    JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid  
                    WHERE   expected_payoutagentid = @expected_payoutagentid    
         AND Transstatus = 'Payment'    
         AND status = 'Un-Paid'    
         AND is_downloaded = 'p'      
                            AND agentid = @partneragentcode    
                            AND ISNULL(a.disable_payout,'n')<>'y'  
    END     
        
--------------------------------------------------------------------------------------------      
  UPDATE  dbo.moneySend      
   SET     is_downloaded = 'y' ,      
   STATUS = 'Post',      
            downloaded_by = ISNULL(@downloadBy, 'SSIS_FOR_SAMPATH_BANK') ,      
            downloaded_ts = dbo.getDateHO(GETUTCDATE())  
            FROM dbo.moneySend m WITH(NOLOCK)
            JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid      
   WHERE   expected_payoutagentid = @expected_payoutagentid      
            AND is_downloaded = 'p'      
   AND Transstatus = 'Payment'    
   AND ISNULL(a.disable_payout,'n')<>'y'  
--------------------------------------------------------------------------------------------    
   -- PIC Update to Post        
   IF @remote_db IS NOT NULL    
   BEGIN    
    SET @sql1 = ' insert into ' + @remote_db    
       + 'tbl_status_moneysend_paid(refno,status)    
  select control_no,''Post'' from #temp_MY'    
      EXEC(@sql1)    
                END    
  --------------------------------------------------------------------------------------------      
     
 END        
      
 ------------------------------------- for feedback response ----------------------------------      
    IF @flag = 'p'       
        BEGIN        
      
            DECLARE @rBankID VARCHAR(50) ,      
                @rBankName VARCHAR(200) ,      
                @rBankBranch VARCHAR(200) ,      
                @ditital_id VARCHAR(100)        
            
            SET @ditital_id = 'Sampath_' + REPLACE(NEWID(), '-', '_')         
           
            SELECT  top 1 @rBankID = b.agent_branch_code ,      
                    @rBankName = a.companyName ,      
                    @rBankBranch = b.Branch      
            FROM    agentdetail a      
                    JOIN agentbranchdetail b ON a.agentcode = b.agentcode      
            WHERE   a.agentcode = @expected_payoutagentid      
                    AND isHeadOffice = 'y'        
            IF @rBankID IS NULL      
    SELECT  top 1  @rBankID = b.agent_branch_code ,      
      @rBankName = a.companyName ,      
      @rBankBranch = b.Branch      
    FROM    agentdetail a      
      JOIN agentbranchdetail b ON a.agentcode = b.agentcode      
    WHERE   a.agentcode = @expected_payoutagentid      
             
               
            INSERT  INTO [temp_trn_csv_pay]      
                    ( [tranno] ,      
                      [refno] ,      
                      [ReceiverName] ,      
                      [TotalRoundAmt] ,      
                      [paidDate] ,      
                      [paidBy] ,      
                      [expected_payoutagentid] ,      
                      [rBankID] ,      
                      [rBankName] ,      
                      [rBankBranch] ,      
                      [digital_id_payout]        
                    )      
                    SELECT  m.tranno ,      
                            m.refno ,      
                            m.receiverName ,      
                            m.totalRoundAmt ,      
                            dbo.getDateHO(GETUTCDATE()) ,      
                            'SYSTEM' ,      
                            @expected_payoutagentid ,      
                            @rBankID ,      
                            @rBankName ,      
                            @rBankBranch ,      
                            @ditital_id      
                    FROM    moneysend m WITH ( NOLOCK )      
                            INNER JOIN SFTP_Feedback_Sampath t ON dbo.encryptdb(t.PIN) = m.refno
                            JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid        
                    WHERE   m.expected_payoutagentid = @expected_payoutagentid      
                            AND m.Transstatus = 'Payment'        
                --AND status = 'Un-Paid'          
            AND m.status = 'Post'      
                            AND t.PROCESS_ID IS NULL      
                            AND t.Order_Status = '0001'    
                            AND ISNULL(a.disable_payout,'n')<>'y'    
              --              AND CAST(t.N_AMTPAID AS MONEY) = m.TotalRoundAmt        
  -------------------------------------------------------------------------------        
            UPDATE  dbo.SFTP_Feedback_Sampath      
            SET     PROCESS_ID = @ditital_id ,      
                    SYSTEM_STATUS = CASE WHEN LOWER(t.Order_Status) = '0001'      
                                              AND m.refno IS NULL      
                                         THEN ' REFNO NOT FOUND'      
 --                                        WHEN LOWER(t.STATUS) = 'p'      
 --                                             AND CAST(t.N_AMTPAID AS MONEY) <> m.TotalRoundAmt      
 --                                        THEN 'AMOUNT DOES NOT MATCHED'      
                                         WHEN LOWER(m.STATUS) = 'paid'      
                                         THEN 'TXN ALREADY PAID'      
                                         WHEN LOWER(t.Order_Status) <> '0001'      
                                         THEN 'SKIPPED'      
                                         ELSE 'SUCCESS'      
                                    END      
            FROM    SFTP_Feedback_Sampath t      
                    LEFT OUTER JOIN dbo.moneySend m WITH ( NOLOCK ) ON dbo.encryptdb(t.PIN) = m.refno    
                    JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid    
            WHERE   t.PROCESS_ID IS NULL AND ISNULL(a.disable_payout,'n')<>'y'          
  -------------------------------------------------------------------------------        
                
-- payment Process run--------------        
            EXEC spa_make_bulk_payment_csv @ditital_id, NULL, 'y'        
------------------------------------        
-----------------------------------------------------------------------------------------------------        
--SELECT  refno FROM ##tempData         
        END   