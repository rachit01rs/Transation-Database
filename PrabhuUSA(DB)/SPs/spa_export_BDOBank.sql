IF OBJECT_ID('spa_export_BDOBank', 'P') IS NOT NULL 
    DROP PROC [dbo].[spa_export_BDOBank]  
go
CREATE PROC [dbo].[spa_export_BDOBank] @flag CHAR(1)   
  
/*  
@FLAG   
 S => select all the txn to export.  
 c => count all the txn to export.  
 p => paid the txn which was exported.  
*/
AS 
    SET NOCOUNT ON  
    DECLARE @sql VARCHAR(MAX) ,
        @agent_id VARCHAR(50)  
---------------------------------------------------  
    SET @agent_id = '20100128'  
---------------------------------------------------  
--'20100025'  
  
    IF @flag = 's' 
        BEGIN  
	                            
            
            SELECT  dbo.decryptdb(refno) [Reference No.] ,
                    REPLACE(CONVERT(VARCHAR, CAST(confirmDate AS DATETIME), 102),
                            '.', '') [Trans Date] ,
                    SUBSTRING(RTRIM(LTRIM(SenderName)), 1, 100) [Sender Name] ,
                    SUBSTRING(RTRIM(LTRIM(REPLACE(ISNULL(senderAddress, ''),
                                                  ',', ' - '))), 1, 75) [Sender Address1] ,
                    '' [Sender Address2] ,
                    SUBSTRING(RTRIM(LTRIM(ISNULL(senderPhoneno, ''))), 1, 30) [Sender Phone] ,
                    SUBSTRING(RTRIM(LTRIM(ReceiverName)), 1, 100) [Receiver Name] ,
                    SUBSTRING(RTRIM(LTRIM(REPLACE(ISNULL(ReceiverAddress, ''),
                                                  ',', ' - '))), 1, 75) [Receiver Address1] ,
                    '' [Receiver Address2] ,
                    SUBSTRING(RTRIM(LTRIM(ISNULL(Receiver_mobile, ''))), 1, 30) [Receiver Mobile Phone] ,
                    CASE WHEN receiverRelation IN ( 'Wife', 'Mother', 'Sister',
                                                    'Grand Mother',
                                                    'Sister in Law',
                                                    'Mother in Law', 'Aunt',
                                                    'Daughter' ) THEN 'F'
                         ELSE 'M'
                    END [Receiver Gender] ,
                    '' [Receiver Birth date] ,
                    CASE WHEN paymentType = 'Cash Pay' THEN '01'
                         WHEN paymentType = 'Bank Transfer' THEN '02'
                         WHEN paymentType = 'Account Deposit to Other Bank'
                         THEN '04'
                         WHEN paymentType = 'Home Delivery' THEN '05'
                         ELSE ''
                    END [Transaction Type] ,
                    CASE WHEN paymentType = 'Cash Pay' THEN 'BPMM'
                         WHEN paymentType = 'Bank Transfer' THEN 'CBBM'
                         WHEN paymentType = 'Account Deposit to Other Bank'
                         THEN 'CBOM'
                         WHEN paymentType = 'Home Delivery' THEN 'DDMM'
                         ELSE ''
                    END [Payable Code] ,
                    CASE WHEN paymentType = 'Cash Pay' THEN 'BDO'
                         WHEN paymentType = 'Bank Transfer' THEN 'BDO'
                         WHEN paymentType = 'Account Deposit to Other Bank'
                         THEN RTRIM(LTRIM(ben_bank_id))
                         WHEN paymentType = 'Home Delivery' THEN ''
                         ELSE ''
                    END [Bank Code] ,
                    CASE WHEN paymentType = 'Cash Pay' THEN 'BDO'
                         WHEN paymentType = 'Bank Transfer' THEN 'BDO'
                         WHEN paymentType = 'Account Deposit to Other Bank'
                         THEN 'MAKATI'
                         WHEN paymentType = 'Home Delivery' THEN ''
                         ELSE ''
                    END [Branch name] ,
                    SUBSTRING(RTRIM(LTRIM(ISNULL(rBankACNo, ''))), 1, 20) [Acct. No] ,
                    RTRIM(LTRIM(receiveCType)) [Landed Currency] ,
                    CAST(totalRoundAmt AS VARCHAR) [Landed Amount] ,
                    SUBSTRING(RTRIM(LTRIM(REPLACE(ISNULL(reciverMessage, ''),
                                                  ',', ' - '))), 1, 50) [Instruction to BDO Br.] ,
                    SUBSTRING(RTRIM(LTRIM(REPLACE(ISNULL(testQuestion, ''),
                                                  ',', ' - '))), 1, 50) [Instruction to Jollibee]	  
           FROM    moneysend m WITH ( NOLOCK )
                    LEFT OUTER JOIN agentbranchdetail b ON b.agent_branch_code = m.rBankID
                     JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid
            WHERE   expected_payoutagentid = @Agent_id
                    AND Transstatus = 'Payment'
                    AND status = 'Un-Paid'
                    AND is_downloaded = 'p'  AND ISNULL(a.disable_payout,'n')<>'y'
            
            
--            UPDATE  moneysend
--            SET     status = 'Post' ,
--                    is_downloaded = 'y' ,
--                    downloaded_ts = dbo.getDateHO(GETUTCDATE()) ,
--                    downloaded_by = 'System'
--            WHERE   expected_payoutagentid = @Agent_id
--                    AND Transstatus = 'Payment'
--                    AND status = 'Un-Paid'
--                    AND is_downloaded = 'p' 

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
                    WHERE   expected_payoutagentid = @Agent_id
							AND Transstatus = 'Payment'
							AND status = 'Un-Paid'
							AND is_downloaded = 'p'	 
                            AND agentid = @partneragentcode
                             AND ISNULL(a.disable_payout,'n')<>'y'
				END 
				
--------------------------------------------------------------------------------------------
			
			
            UPDATE  moneysend
            SET     status = 'Post' ,
                    is_downloaded = 'y' ,
                    downloaded_ts = dbo.getDateHO(GETUTCDATE()) ,
                    downloaded_by = 'System'
                    FROM dbo.moneySend m WITH(NOLOCK)
                    JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid
            WHERE   expected_payoutagentid = @Agent_id
                    AND Transstatus = 'Payment'
                    AND status = 'Un-Paid'
                    AND is_downloaded = 'p' 	
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
  
    IF @flag = 'c' 
        BEGIN  
            UPDATE  moneysend
            SET     is_downloaded = 'p' FROM dbo.moneySend m WITH(NOLOCK)
              JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid
            WHERE   expected_payoutagentid = @agent_id
                    AND Transstatus = 'Payment'
                    AND is_downloaded IS NULL
                    AND status = 'Un-Paid'  
                     AND ISNULL(a.disable_payout,'n')<>'y'
  
            SELECT  COUNT(*) row_count ,
                    CAST(SUM(totalRoundAmt) AS VARCHAR) total_PHP
            FROM    moneysend m WITH ( NOLOCK )
              JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid
            WHERE   is_downloaded = 'p'
                    AND transStatus = 'Payment'
                    AND status = 'Un-Paid'
                    AND expected_payoutagentid = @agent_id 
                     AND ISNULL(a.disable_payout,'n')<>'y' 
        END  
  
    IF @flag = 'p' 
        BEGIN  
 -----------------------------------------------------------------------------------------------------  
            DECLARE @rBankID VARCHAR(50) ,
                @rBankName VARCHAR(200) ,
                @rBankBranch VARCHAR(200) ,
                @ditital_id VARCHAR(100)  
      
            SET @ditital_id = 'BDO_' + REPLACE(NEWID(), '-', '_')   
     
            SELECT  @rBankID = b.agent_branch_code ,
                    @rBankName = a.companyName ,
                    @rBankBranch = b.Branch
            FROM    agentdetail a
                    JOIN agentbranchdetail b ON a.agentcode = b.agentcode
            WHERE   a.agentcode = @agent_id
                    AND isHeadOffice = 'y' 
            IF @rBankID is null
				SELECT TOP 1 @rBankID = b.agent_branch_code ,  
						@rBankName = a.companyName ,  
						@rBankBranch = b.Branch  
				FROM    agentdetail a  
						JOIN agentbranchdetail b ON a.agentcode = b.agentcode 
				WHERE   a.agentcode = @agent_id   
         
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
                            CAST(ISNULL(t.D_PAID, dbo.getDateHO(GETUTCDATE())) AS DATETIME) ,
                            'SYSTEM' ,
                            @agent_id ,
                            @rBankID ,
                            @rBankName ,
                            @rBankBranch ,
                            @ditital_id
                    FROM    moneysend m WITH ( NOLOCK )
                            INNER JOIN FTP_FeedBack_BDO t ON dbo.encryptdb(t.C_TREFNO) = m.refno
                              JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid                            
                    WHERE   m.expected_payoutagentid = @Agent_id
                            AND m.Transstatus = 'Payment'  
                --AND status = 'Un-Paid'    
                            AND m.status = 'Post'
                            AND t.PROCESS_ID IS NULL
                            AND t.C_STATUS = 'Paid'
                            AND CAST(t.N_AMTPAID AS MONEY) = m.TotalRoundAmt 
                             AND ISNULL(a.disable_payout,'n')<>'y' 
  -------------------------------------------------------------------------------  
            UPDATE  dbo.FTP_FeedBack_BDO
            SET     PROCESS_ID = @ditital_id ,
                    SYSTEM_STATUS = CASE WHEN LOWER(t.C_STATUS) = 'paid'
                                              AND m.refno IS NULL
                                         THEN ' REFNO NOT FOUND'
                                         WHEN LOWER(t.C_STATUS) = 'paid'
                                              AND CAST(t.N_AMTPAID AS MONEY) <> m.TotalRoundAmt
                                         THEN 'AMOUNT DOES NOT MATCHED'
                                         WHEN LOWER(m.STATUS) = 'paid'
                                         THEN 'TXN ALREADY PAID'
                                         WHEN LOWER(t.C_STATUS) <> 'paid'
                                         THEN 'SKIPPED'
                                         ELSE 'SUCCESS'
                                    END
            FROM    FTP_FeedBack_BDO t
                    LEFT OUTER JOIN dbo.moneySend m WITH ( NOLOCK ) ON dbo.encryptdb(t.C_TREFNO) = m.refno
                      JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid
            WHERE   t.PROCESS_ID IS NULL    AND ISNULL(a.disable_payout,'n')<>'y'
  -------------------------------------------------------------------------------  
          
-- payment Process run--------------  
            EXEC spa_make_bulk_payment_csv @ditital_id, NULL, 'y'  
------------------------------------  
-----------------------------------------------------------------------------------------------------  
--SELECT  refno FROM ##tempData   
        END   
  