DROP PROC [dbo].[spa_Export_LBC_SSIS]       
go    
CREATE PROC [dbo].[spa_Export_LBC_SSIS]       
@flag CHAR(1),      
@downloadBy VARCHAR(50) = 'Auto_LBC',    
@digital_id VARCHAR(200)=NULL         
AS      
SET NOCOUNT ON        
    DECLARE @expected_payoutagentid VARCHAR(50),@username VARCHAR(50),@password VARCHAR(50),@agentID VARCHAR(50)      
    SET @expected_payoutagentid = ISNULL(@expected_payoutagentid, '20100201')      
    SET @username ='Prabhu'      
    SET @password ='prabhu'      
    SET @agentID='10024'      
IF @flag = 's'       
    BEGIN           
  SELECT      
  @agentID AgentID,      
  SUBSTRING(@username,1,15) Username,      
  SUBSTRING(@password,1,15) Password,      
  CASE WHEN m.paymentType = 'Cash Pay' THEN 'IPPA'            
    WHEN m.paymentType = 'Account Deposit to Other Bank' THEN 'RTA'            
    WHEN m.paymentType = 'Home Delivery' THEN 'PP24'           
  END ProdType,      
  SUBSTRING(dbo.decryptdb(m.refno),1,30) Reference,       
  SUBSTRING(CASE WHEN ISNULL(dbo.FNAFristMiddleLastName('l',m.senderName),'')='' 
				THEN dbo.FNAFristMiddleLastName('f',m.senderName) 
				ELSE dbo.FNAFristMiddleLastName('l',m.senderName) END,1,30) ShipLName,      
  SUBSTRING(dbo.FNAFristMiddleLastName('f',m.senderName),1,30) ShipFName,      
  SUBSTRING(dbo.FNAFristMiddleLastName('m',m.senderName),1,30) ShipMName,      
  SUBSTRING(dbo.FNAReplaceSpecialChars(m.SenderAddress,'-'),1,30) ShipStreet1,      
  NULL ShipStreet2,      
  NULL ShipStreet3,      
  SUBSTRING(dbo.FNAReplaceSpecialChars(m.SenderCity,'-'),1,30) ShipCity,    
  NULL ShipProv,      
  NULL ShipArea,      
  SUBSTRING(dbo.FNAReplaceSpecialChars(m.SenderPhoneno,'-'),1,30) ShipContactNo1,      
  SUBSTRING(ISNULL(dbo.FNAReplaceSpecialChars(m.sender_mobile,'-'),'0000000000'),1,30) ShipContactNo2,      
  SUBSTRING(CASE WHEN ISNULL(dbo.FNAFristMiddleLastName('l',m.ReceiverName),'')='' 
				THEN dbo.FNAFristMiddleLastName('f',m.ReceiverName) 
				ELSE dbo.FNAFristMiddleLastName('l',m.ReceiverName) END,1,30) ConLName,      
  SUBSTRING(dbo.FNAFristMiddleLastName('f',m.ReceiverName),1,30) ConFName,      
  SUBSTRING(dbo.FNAFristMiddleLastName('m',m.ReceiverName),1,30) ConMName,      
  NULL ConName2,      
  SUBSTRING(dbo.FNAReplaceSpecialChars(m.ReceiverAddress,'-'),1,30) ConStreet1,    
  NULL ConStreet2,      
  NULL ConStreet3,      
  SUBSTRING(dbo.FNAReplaceSpecialChars(m.ReceiverCity,'-'),1,30) ConCity,    
  NULL ConProv,      
  NULL ConArea,      
  SUBSTRING(dbo.FNAReplaceSpecialChars(ISNULL(m.receiver_mobile,'0000000000'),'-'),1,30) ConContactNo1,      
  SUBSTRING(dbo.FNAReplaceSpecialChars(m.ReceiverPhone,'-'),1,15) ConContactNo2,      
  CASE WHEN m.paymentType = 'Account Deposit to Other Bank' THEN dbo.FNAReplaceSpecialChars(m.ben_bank_id,'-') ELSE NULL END BankCode,      
  CASE WHEN m.paymentType = 'Account Deposit to Other Bank' THEN dbo.FNAReplaceSpecialChars(m.rBankACNo,'-') ELSE NULL END BankAccountNo,      
  CASE WHEN m.paymentType = 'Account Deposit to Other Bank' THEN dbo.FNAReplaceSpecialChars(m.ben_bank_name,'-') ELSE NULL END BankBranch,      
  m.TotalRoundAmt RemitAmount,      
  NULL AgentUser      
  from moneysend m with (nolock)        
  left outer join agentbranchdetail b with (nolock) on m.rBankID=b.agent_branch_code  
  JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid    
  where  expected_payoutagentid=@expected_payoutagentid      
  and Transstatus = 'Payment' and status = 'Un-Paid' AND is_downloaded = 'p'  AND ISNULL(a.disable_payout,'n')<>'y'     
    END      
          
IF @flag = 'c'       
 BEGIN      
  UPDATE  dbo.moneySend      
  SET     is_downloaded = 'p'  FROM dbo.moneySend m WITH(NOLOCK)
  JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid        
  WHERE   expected_payoutagentid = @expected_payoutagentid      
    AND Transstatus = 'Payment'      
    AND status = 'Un-Paid'      
    AND is_downloaded IS NULL  AND ISNULL(a.disable_payout,'n')<>'y'     
      
  SELECT  COUNT(*) row_count      
  FROM    moneysend WITH ( NOLOCK )      
  WHERE   expected_payoutagentid = @expected_payoutagentid      
    AND is_downloaded = 'p'      
 END      
      
IF @flag='u'      
 BEGIN      
-- SELECT 1  
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
  
					SET @sql1 = ' insert into ' + @remote_db  
					   + 'tbl_status_moneysend_paid(refno,status)  
						SELECT REFNO,''Post'' FROM moneysend m with(nolock)
						JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid   
						WHERE   expected_payoutagentid = '''+@expected_payoutagentid+'''
								AND is_downloaded = ''p''      
								AND Transstatus = ''Payment''
								AND ISNULL(a.disable_payout,''n'')<>''y''  
								AND agentid='''+@partneragentcode+''''
					EXEC(@sql1)  
                END  
  --------------------------------------------------------------------------------------------     
  UPDATE  dbo.moneySend      
   SET		is_downloaded = 'y' ,      
			STATUS = 'Post',      
            downloaded_by = ISNULL(@downloadBy, 'SSIS_FOR_LBC') ,      
            downloaded_ts = dbo.getDateHO(GETUTCDATE()) 
            FROM dbo.moneySend m WITH(NOLOCK)
            JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid  
   WHERE   expected_payoutagentid = @expected_payoutagentid      
            AND is_downloaded = 'p'      
   AND Transstatus = 'Payment'       
   AND ISNULL(a.disable_payout,'n')<>'y'  
 END        
     
     
    
    
 ------------------------------------- for LBC feedback response ----------------------------------        
    IF @flag = 'p'         
        BEGIN          
        
            DECLARE @rBankID VARCHAR(50) ,        
                @rBankName VARCHAR(200) ,        
                @rBankBranch VARCHAR(200)        
              
            --SET @digital_id = 'Sampath_' + REPLACE(NEWID(), '-', '_')           
             
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
                            @digital_id        
                    FROM    moneysend m WITH ( NOLOCK )        
                            INNER JOIN tbl_Feedback_Txn t ON dbo.encryptdb(t.Ref_No) = m.refno  
                            JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid        
                    WHERE   m.expected_payoutagentid = @expected_payoutagentid        
                            AND m.Transstatus = 'Payment'          
                --AND status = 'Un-Paid'            
                            AND m.status = 'Post'        
                            AND t.PROCESS_ID =@digital_id        
                            AND t.Feedback_Status = 'A' 
                            AND ISNULL(a.disable_payout,'n')<>'y'         
              --              AND CAST(t.N_AMTPAID AS MONEY) = m.TotalRoundAmt          
  -------------------------------------------------------------------------------          
            UPDATE  dbo.tbl_Feedback_Txn        
            SET     IMPORTED_DATE = dbo.getDateHO(GETUTCDATE()) ,    
     PayoutAgent = @expected_payoutagentid,    
                    SYSTEM_STATUS = CASE WHEN UPPER(t.Feedback_Status) = 'A' AND m.refno IS NULL        
            THEN ' REFNO NOT FOUND'        
                                         WHEN UPPER(t.Feedback_Status) = 'E' AND substring(t.Remarks,1,2)='P1'    
            THEN ' Invalid Product type (PP24 | IPPA | RTA) only'    
         WHEN UPPER(t.Feedback_Status) = 'E' AND substring(t.Remarks,1,2)='B1'    
            THEN ' Invalid Bank Code'     
         WHEN UPPER(t.Feedback_Status) = 'E' AND substring(t.Remarks,1,2)='L1'    
            THEN ' Login error. Username, Password or AgentID is invalid'       
         WHEN UPPER(t.Feedback_Status) = 'E' AND substring(t.Remarks,1,2)='D1'    
            THEN ' Duplicate reference'     
                                             
                                         WHEN UPPER(t.Feedback_Status) = 'E' AND substring(t.Remarks,1,2)='S1'    
            THEN ' Error processing in the Server'    
         WHEN UPPER(t.Feedback_Status) = 'E' AND substring(t.Remarks,1,2)='R1'    
            THEN ' List of required fields without value)'     
         WHEN UPPER(t.Feedback_Status) = 'E' AND substring(t.Remarks,1,2)='I1'    
            THEN ' Request Denied, Information does not match with the server'       
         WHEN UPPER(t.Feedback_Status) = 'E' AND substring(t.Remarks,1,2)='C1'    
            THEN ' Request Denied, Transaction already processed for delivery'                 
                                 WHEN LOWER(m.STATUS) = 'paid'        
            THEN 'TXN ALREADY PAID'        
                                        WHEN UPPER(t.Feedback_Status) <> 'A'        
            THEN 'SKIPPED'        
                                        ELSE 'SUCCESS'        
                                    END        
            FROM    tbl_Feedback_Txn t        
                    LEFT OUTER JOIN dbo.moneySend m WITH ( NOLOCK ) ON dbo.encryptdb(t.Ref_No) = m.refno  
                    JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid        
            WHERE   t.PROCESS_ID =@digital_id AND ISNULL(a.disable_payout,'n')<>'y'            
  -------------------------------------------------------------------------------          
                  
-- payment Process run--------------          
            EXEC spa_make_bulk_payment_csv @digital_id, NULL, 'y'          
------------------------------------          
-----------------------------------------------------------------------------------------------------          
--SELECT  refno FROM ##tempData           
        END 