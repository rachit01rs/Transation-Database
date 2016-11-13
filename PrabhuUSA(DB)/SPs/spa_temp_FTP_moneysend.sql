IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_temp_FTP_moneysend]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_temp_FTP_moneysend]
GO

/****** Object:  StoredProcedure [dbo].[spa_temp_FTP_moneysend]    Script Date: 03/21/2014 12:35:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
** Database : PrabhuUSA
** Object : spa_temp_FTP_moneysend
**
** Purpose : [FTP intregation]
**
** Author:  Sunita Shrestha
** Date:    21/03/2014
**
** Modifications:
** Examples:
*/

CREATE PROC [dbo].[spa_temp_FTP_moneysend]
AS
BEGIN
    DECLARE @pinno      VARCHAR(20)
           ,@processid  VARCHAR(200)
    
    SELECT processid
          ,pinno INTO #temp
    FROM   [tbl_FTP_Import_File_Data] T WITH (NOLOCK)
    WHERE  T.DataInsertedInMoneySend = 'p' 
    
    ----------------Cursor Starts----------------------------------------------------
    
    DECLARE FTP       CURSOR  
    FOR
        SELECT processid
              ,pinno  
        FROM   #temp
    
    OPEN FTP
    FETCH NEXT FROM FTP INTO @processid,@pinno                                            
    WHILE @@FETCH_STATUS=0 
          ---------------------------------------------------------------------------------
    BEGIN
        DECLARE @flag                 CHAR(1)
               ,@agentcode            VARCHAR(50)
               ,@agent_branch_code    VARCHAR(50)
               ,@user_pwd             VARCHAR(50)
               ,@accessed             VARCHAR(50)
               ,@CALC_BY              CHAR(1)	---- 'c' by Collected AMT, 'p' Payout amt
               ,@AUTHORIZED_REQUIRED  CHAR(1)
        
        SET @CALC_BY = 'p'
        SET @AUTHORIZED_REQUIRED = 'y'
        
        DECLARE @Block_branch            VARCHAR(50)
               ,@BranchCodeChar          VARCHAR(50)
               ,@lock_status             VARCHAR(5)
               ,@agent_user_id           VARCHAR(50)
        
        DECLARE @user_count              INT
               ,@limit_per_TXN           MONEY
               ,@agentname               VARCHAR(100)
               ,@branch                  VARCHAR(100)
               ,@gmtdate                 DATETIME
               ,@COLLECT_CURRENCY        VARCHAR(5)
               ,@generate_partner_pinno  CHAR(1)  
        
        DECLARE @payout_branch_id        VARCHAR(50)
               ,@payout_agent_id         VARCHAR(50)
               ,@BANK_BRANCHID           VARCHAR(50)
               ,@SENDER_NAME             VARCHAR(50)
               ,@RECEIVER_NAME           VARCHAR(50)
               ,@COLLECT_AMT             MONEY
               ,@RECEIVER_COUNTRY        VARCHAR(50)
               ,@SENDER_COUNTRY          VARCHAR(50)
               ,@PAYMENTTYPE             VARCHAR(50)
               ,@BANKID                  VARCHAR(50)
               ,@BANK_ACCOUNT_NUMBER     VARCHAR(50)
               ,@OTHER_BANK_BRANCH_NAME  VARCHAR(100)
               ,@AGENT_TXNID             VARCHAR(50)
               ,@username                VARCHAR(50)
               ,@partnerID               VARCHAR(50)
        
        DECLARE @sql                     VARCHAR(8000)    
        DECLARE @return_value            VARCHAR(1000) 
        
        DECLARE @currentBalance          MONEY
               ,@allow_integration_user  CHAR(1)
               ,@last_login              DATETIME
        SET @flag='s'
        --------------------------------------------------------------------------------------------------
        SELECT @partnerID = t.PartnerID
              ,@payout_branch_id = T.LocationID
              ,@BANK_BRANCHID = T.BeneficiaryBankBranchCode
              ,@COLLECT_CURRENCY = t.PayoutCCY
              ,@SENDER_NAME = t.RemitterName
              ,@RECEIVER_NAME = t.BeneficiaryName
              ,@COLLECT_AMT = t.PayoutAMT
              ,@RECEIVER_COUNTRY = t.PayoutCountry
              ,@BANKID = t.BeneficiaryBankCode
              ,@BANK_ACCOUNT_NUMBER = T.BankAccountNo
              ,@OTHER_BANK_BRANCH_NAME = T.BeneficiaryBankBranchName
              ,@PAYMENTTYPE = t.PaymentMode
              ,@AGENT_TXNID = t.pinno
        FROM   [tbl_FTP_Import_File_Data] T WITH (NOLOCK)
        WHERE  T.PINNO = @pinno
               AND T.processid = @processid
               AND T.DataInsertedInMoneySend = 'p' 
        
        IF @partnerID IS NULL
        BEGIN
            SET @return_value = 
                '[1001] Invalid txn. Please contact Support Personal'
            
            UPDATE dbo.tbl_FTP_Import_File_Data
            SET    DataInsertedInMoneySend = 'F'
                  ,DataInsertedDate = GETDATE()
                  ,Remarks = @return_value
            FROM   [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
            WHERE  T.PINNO = @pinno
                   AND T.processid = @processid
                   AND T.DataInsertedInMoneySend = 'P'
            
            SET @flag = 'f'
        END
        
        IF @flag='s'
           --------------------------------------------------------------------------------------------------
        BEGIN
            SELECT @agentcode = a.agentcode
                  ,@agentname = a.companyName
                  ,@user_pwd = u.user_pwd
                  ,@agent_user_id = u.agent_user_id
                  ,@accessed = a.accessed
                  ,@SENDER_COUNTRY = a.country
                  ,@branch = b.branch
                  ,@agent_branch_code = b.agent_branch_code
                  ,@BranchCodeChar = b.BranchCodeChar
                  ,@Block_branch = ISNULL(b.block_branch ,'n')
                  ,@lock_status = ISNULL(u.lock_status ,'n')
                  ,@COLLECT_CURRENCY = a.currencyType
                  ,@gmtdate = DATEADD(mi ,ISNULL(gmt_value ,345) ,GETUTCDATE())
                  ,@currentBalance = (ISNULL(a.limit ,0)-ISNULL(a.currentBalance ,0))
                  ,@limit_per_TXN = a.limitPerTran
                  ,--@allow_integration_user = ISNULL(u.allow_integration_user, 'n'),
                   @generate_partner_pinno = ISNULL(a.generate_partner_pinno ,'n')
                  ,@last_login = last_login
                  ,@username = u.User_login_Id
            FROM   agentDetail a WITH(NOLOCK)
                   JOIN agentbranchdetail b WITH(NOLOCK)
                        ON  a.agentcode = b.agentcode
                   JOIN agentsub u WITH(NOLOCK)
                        ON  b.agent_branch_code = u.agent_branch_code
            WHERE  u.agent_user_id = @partnerID
            
            IF @agentcode IS NULL
            BEGIN
                SET @return_value = 
                    '[1001] User not defined. Please to check the Setup.'
                
                UPDATE dbo.tbl_FTP_Import_File_Data
                SET    DataInsertedInMoneySend = 'F'
                      ,DataInsertedDate = GETDATE()
                      ,Remarks = @return_value
                FROM   [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
                WHERE  T.PINNO = @pinno
                       AND T.processid = @processid
                       AND T.DataInsertedInMoneySend = 'P'
                
                SET @flag = 'f'
            END
            
            IF @accessed NOT IN ('Granted')
            BEGIN
                SET @return_value = '[1002] Agent is Blocked'    
                
                UPDATE dbo.tbl_FTP_Import_File_Data
                SET    DataInsertedInMoneySend = 'F'
                      ,DataInsertedDate = GETDATE()
                      ,Remarks = @return_value
                FROM   [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
                WHERE  T.PINNO = @pinno
                       AND T.processid = @processid
                       AND T.DataInsertedInMoneySend = 'P' 
                
                SET @flag = 'f'
            END 
            
            IF @Block_branch='y'
            BEGIN
                SET @return_value = '[1003] Branch is Blocked'    
                UPDATE dbo.tbl_FTP_Import_File_Data
                SET    DataInsertedInMoneySend = 'F'
                      ,DataInsertedDate = GETDATE()
                      ,Remarks = @return_value
                FROM   [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
                WHERE  T.PINNO = @pinno
                       AND T.processid = @processid
                       AND T.DataInsertedInMoneySend = 'P'
                
                SET @flag = 'f'
            END 
            --
            --	IF @allow_integration_user = 'n'
            --	BEGIN
            --	    SET @return_value = 'Your userid is not allowed for Web Services'
            --	    SELECT '1003' Code,
            --	           @AGENT_REFID AGENT_REFID,
            --	           @return_value MESSAGE,
            --	           NULL REFID
            --
            --	    RETURN
            --	END
            
            IF @flag='s'
            BEGIN
                DECLARE @isError CHAR(1)
                SELECT @isError = isError
                      ,@PAYMENTTYPE = item
                FROM   dbo.FNA_ApiGetPaymentType(@PAYMENTTYPE)
                
                IF @isError IS NOT NULL
                BEGIN
                    UPDATE dbo.tbl_FTP_Import_File_Data
                    SET    DataInsertedInMoneySend = 'F'
                          ,DataInsertedDate = GETDATE()
                          ,Remarks = @PAYMENTTYPE
                    FROM   [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
                    WHERE  T.PINNO = @pinno
                           AND T.processid = @processid
                           AND T.DataInsertedInMoneySend = 'P'  
                    
                    SET @flag = 'f'
                END
                                                            
                IF @flag='s'
                BEGIN
                    DECLARE @check_anywhere CHAR(1) 
                    --SELECT @check_anywhere=ISNULL(isanywhere,'n') FROM service_charge_setup WHERE agent_id=@agentcode
                    --AND rec_country= @RECEIVER_COUNTRY    
                    SET @check_anywhere = 'n'    
                    
                    
                    DECLARE @BANK_NAME               VARCHAR(100)
                           ,@PAYOUTCURRENCY          VARCHAR(5)
                           ,@max_payout_amt_cash     MONEY
                           ,@BANK_BRANCH_NAME        VARCHAR(100)
                           ,@max_payout_amt_account  MONEY
                           ,@branch_block            VARCHAR(50)
                           ,@payout_agent_status     VARCHAR(50)
                           ,@PAYOUT_COUNTRY          VARCHAR(100)
                           ,@Payout_AgentCan         VARCHAR(50)
                           ,@branch_Type             VARCHAR(50)    
                    
                    SELECT @payout_agent_id = a.agentCode
                          ,@BANK_NAME = companyName
                          ,@payout_agent_status = a.accessed
                          ,@BANK_BRANCH_NAME = CASE 
                                                    WHEN b.Branch_Type=
                                                         'AC Deposit' THEN 
                                                         ISNULL(b.branch_group ,'') 
                                                        +' '
                                                    ELSE ''
                                               END+b.branch
                          ,@Payout_AgentCan = a.agentCan
                          ,@branch_block = ISNULL(block_branch ,'n')
                          ,@PAYOUT_COUNTRY = a.country
                          ,@PAYOUTCURRENCY = currencyType
                          ,@max_payout_amt_cash = ISNULL(a.max_payout_amt_per_trans ,0)
                          ,@max_payout_amt_account = ISNULL(max_payout_amt_per_trans_deposit ,0)
                          ,@branch_Type = b.branch_type
                    FROM   agentdetail a WITH(NOLOCK)
                           JOIN agentbranchdetail b WITH(NOLOCK)
                                ON  a.agentcode = b.agentcode
                    WHERE  agent_branch_code = @payout_branch_id
                           AND a.accessed = 'Granted'
                           AND a.Country = @RECEIVER_COUNTRY    
                    
                    IF @check_anywhere='n'
                       AND (@payout_agent_id='' OR @payout_agent_id IS NULL)
                    BEGIN
                        SET @return_value = 
                            '[1001] Payout Branch ID is not provided or Payout Branch ID doesnt matched with PayoutCountry'
                        
                        UPDATE dbo.tbl_FTP_Import_File_Data
                        SET    DataInsertedInMoneySend = 'F'
                              ,DataInsertedDate = GETDATE()
                              ,Remarks = @return_value
                        FROM   [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
                        WHERE  T.PINNO = @pinno
                               AND T.processid = @processid
                               AND T.DataInsertedInMoneySend = 'P'  
                        
                        SET @flag = 'f'
                    END    
                    
                    IF @payout_agent_id IS NULL
                       AND @check_anywhere='n'
                    BEGIN
                        SET @return_value = '[3003] Invalid Payout Branch ID'    
                        UPDATE dbo.tbl_FTP_Import_File_Data
                        SET    DataInsertedInMoneySend = 'F'
                              ,DataInsertedDate = GETDATE()
                              ,Remarks = @return_value
                        FROM   [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
                        WHERE  T.PINNO = @pinno
                               AND T.processid = @processid
                               AND T.DataInsertedInMoneySend = 'P'
                        
                        SET @flag = 'f'
                    END
                    
                    IF @branch_block='y'
                    BEGIN
                        SET @return_value = 
                            '[3004] Payout Branch ID is not active'
                        
                        UPDATE dbo.tbl_FTP_Import_File_Data
                        SET    DataInsertedInMoneySend = 'F'
                              ,DataInsertedDate = GETDATE()
                              ,Remarks = @return_value
                        FROM   [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
                        WHERE  T.PINNO = @pinno
                               AND T.processid = @processid
                               AND T.DataInsertedInMoneySend = 'P'  
                        
                        SET @flag = 'f'
                    END    
                    
                    IF @check_anywhere='y'
                        SET @PAYOUT_COUNTRY = @RECEIVER_COUNTRY
                    ELSE 
                    IF @Payout_Country<>@RECEIVER_COUNTRY
                    BEGIN
                        SET @return_value = 
                            '[3003] Invalid Payout Branch ID and Country'
                        
                        UPDATE dbo.tbl_FTP_Import_File_Data
                        SET    DataInsertedInMoneySend = 'F'
                              ,DataInsertedDate = GETDATE()
                              ,Remarks = @return_value
                        FROM   [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
                        WHERE  T.PINNO = @pinno
                               AND T.processid = @processid
                               AND T.DataInsertedInMoneySend = 'P'
                        
                        SET @flag = 'f'
                    END
                    
                    IF @flag='s'
                    BEGIN
                        DECLARE @check_bank     VARCHAR(50)
                               ,@ben_bank_name  VARCHAR(150)
                               ,@ben_bank_id    VARCHAR(50)
                               ,@ifsc_code      VARCHAR(50)
                        
                        
                        IF @PAYMENTTYPE='Account Deposit to Other Bank'
                        BEGIN
                            IF @BANKID IS NULL
                            BEGIN
                                SET @return_value = 
                                    '[3002] For Bank  Location ID and Bank ID must be defined'
                                
                                UPDATE dbo.tbl_FTP_Import_File_Data
                                SET    DataInsertedInMoneySend = 'F'
                                      ,DataInsertedDate = GETDATE()
                                      ,Remarks = @return_value
                                FROM   [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
                                WHERE  T.PINNO = @pinno
                                       AND T.processid = @processid
                                       AND T.DataInsertedInMoneySend = 'P'
                                
                                SET @flag = 'f'
                            END
                         
   
                                IF EXISTS(
                                       SELECT *
                                       FROM   commercial_bank cb WITH(NOLOCK)
                                              JOIN commercial_bank_branch cbb 
                                                   WITH(NOLOCK)
                                                   ON  cb.Commercial_id = cbb.Commercial_id
                                       WHERE  cbb.sno = @BANK_BRANCHID
                                   )
                                BEGIN
                                    SELECT @check_bank = cb.COMMERCIAL_ID
                                          ,@ben_bank_name = cbb.bankName
                                          ,@ben_bank_id = cb.external_bank_id
                                          ,@OTHER_BANK_BRANCH_NAME = cbb.BranchName
                                          ,@ifsc_code = cbb.IFSC_Code
                                    FROM   commercial_bank cb WITH(NOLOCK)
                                           JOIN commercial_bank_branch cbb WITH(NOLOCK)
                                                ON  cb.Commercial_id = cbb.Commercial_id
                                    WHERE  cbb.sno = @BANK_BRANCHID
                                END
                                ELSE
                                BEGIN
                                    --SET @ben_bank_id = @BANKID    
                                    SET @check_bank = NULL    
                                    SELECT @check_bank = COMMERCIAL_ID
                                          ,@ben_bank_name = BANK_NAME
                                          ,@ben_bank_id = external_bank_id
                                    FROM   commercial_bank WITH(NOLOCK)
                                    WHERE  commercial_id = @BANKID
                                           AND PAYOUT_AGENT_ID = @payout_agent_id
                                END	
                                
                                IF @check_bank IS NULL
                                BEGIN
                                    SET @return_value = 
                                        '[3002] Payout BANK ID is invalid'
                                    
                                    UPDATE dbo.tbl_FTP_Import_File_Data
                                    SET    DataInsertedInMoneySend = 'F'
                                          ,DataInsertedDate = GETDATE()
                                          ,Remarks = @return_value
                                    FROM   [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
                                    WHERE  T.PINNO = @pinno
                                           AND T.processid = @processid
                                           AND T.DataInsertedInMoneySend = 'P'
                                    
                                    SET @flag = 'f'
                                END
                                
                                IF @BANK_ACCOUNT_NUMBER IS NULL
                                BEGIN
                                    SET @return_value = 
                                        '[3010] Bank Account No is blank'
                                    
                                    UPDATE dbo.tbl_FTP_Import_File_Data
                                    SET    DataInsertedInMoneySend = 'F'
                                          ,DataInsertedDate = GETDATE()
                                          ,Remarks = @return_value
                                    FROM   [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
                                    WHERE  T.PINNO = @pinno
                                           AND T.processid = @processid
                                           AND T.DataInsertedInMoneySend = 'P'
                                    
                                    SET @flag = 'f'
                                END
                               
                                SET @OTHER_BANK_BRANCH_NAME = RTRIM(LTRIM(@OTHER_BANK_BRANCH_NAME)) 
                                IF @OTHER_BANK_BRANCH_NAME=''
                                   OR @OTHER_BANK_BRANCH_NAME IS NULL
                                BEGIN
                                    SET @return_value = 
                                        '[3011] For Account Deposit to Other Bank payment mode Bank branch is mandatory valid.'
                                    
                                    UPDATE dbo.tbl_FTP_Import_File_Data
                                    SET    DataInsertedInMoneySend = 'F'
                                          ,DataInsertedDate = GETDATE()
                                          ,Remarks = @return_value
                                    FROM   [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
                                    WHERE  T.PINNO = @pinno
                                           AND T.processid = @processid
                                           AND T.DataInsertedInMoneySend = 'P'
                                    
                                    SET @flag = 'f'
                                END
                                
                                IF @BANK_BRANCHID IS NOT NULL
                                BEGIN
                                    --- ADDED FOR MAPPING Branch of NEPAL (ACCOUNT DEPOSIT TO OTHER)
                                    IF EXISTS(
                                           SELECT 'x'
                                           FROM   dbo.commercial_bank c WITH(NOLOCK)
                                                  JOIN dbo.commercial_bank_branch 
                                                       b 
                                                       WITH(NOLOCK)
                                                       ON  c.Commercial_id = b.Commercial_id
                                           WHERE  b.IFSC_Code = @BANK_BRANCHID
                                                  AND c.country = 'NEPAL'
                                                  AND b.Commercial_id = @BANKID
                                                  AND c.PAYOUT_AGENT_ID = @payout_agent_id
                                       )
                                    BEGIN
                                        SELECT @OTHER_BANK_BRANCH_NAME = b.BranchName
                                              ,@ifsc_code = b.IFSC_Code
                                        FROM   dbo.commercial_bank c WITH(NOLOCK)
                                               JOIN dbo.commercial_bank_branch b 
                                                    WITH(NOLOCK)
                                                    ON  c.Commercial_id = b.Commercial_id
                                        WHERE  b.IFSC_Code = @BANK_BRANCHID
                                               AND c.country = 'NEPAL'
                                               AND b.Commercial_id = @BANKID
                                               AND c.PAYOUT_AGENT_ID = @payout_agent_id
                                    END---- END
                                END
                            END
                            
                            IF @PAYMENTTYPE='Cash Pay BDP'
                               AND @branch_type<>'External'
                            BEGIN
                                SET @return_value = 
                                    '[3002] LOCATION_ID is not valid BDP Location'
                                
                                UPDATE dbo.tbl_FTP_Import_File_Data
                                SET    DataInsertedInMoneySend = 'F'
                                      ,DataInsertedDate = GETDATE()
                                      ,Remarks = @return_value
                                FROM   [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
                                WHERE  T.PINNO = @pinno
                                       AND T.processid = @processid
                                       AND T.DataInsertedInMoneySend = 'P'  
                                
                                SET @flag = 'f'
                            END
                            
                            IF @PAYMENTTYPE='NEFT'
                            BEGIN
                                IF @BANK_BRANCHID IS NULL
                                BEGIN
                                    SET @return_value = 
                                        '[3002] For NEFT LOCATION_ID and BANK_BRANCHID must be defined'
                                    
                                    UPDATE dbo.tbl_FTP_Import_File_Data
                                    SET    DataInsertedInMoneySend = 'F'
                                          ,DataInsertedDate = GETDATE()
                                          ,Remarks = @return_value
                                    FROM   [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
                                    WHERE  T.PINNO = @pinno
                                           AND T.processid = @processid
                                           AND T.DataInsertedInMoneySend = 'P'
                                    
                                    SET @flag = 'f'
                                END
                                
                                
                                SET @ben_bank_id = @BANKID    
                                SET @check_bank = NULL    
                                
                                SELECT @check_bank = cb.COMMERCIAL_ID
                                      ,@ben_bank_name = cbb.bankName
                                      ,@ben_bank_id = cb.external_bank_id
                                      ,@OTHER_BANK_BRANCH_NAME = cbb.BranchName
                                      ,@ifsc_code = cbb.IFSC_Code
                                FROM   commercial_bank cb WITH(NOLOCK)
                                       JOIN commercial_bank_branch cbb WITH(NOLOCK)
                                            ON  cb.Commercial_id = cbb.Commercial_id
                                WHERE  cbb.sno = @BANK_BRANCHID
                                       AND PAYOUT_AGENT_ID = @payout_agent_id
                                
                                IF @check_bank IS NULL
                                BEGIN
                                    SET @return_value = 
                                        '[3002] Payout Branch ID is invalid'
                                    
                                    UPDATE dbo.tbl_FTP_Import_File_Data
                                    SET    DataInsertedInMoneySend = 'F'
                                          ,DataInsertedDate = GETDATE()
                                          ,Remarks = @return_value
                                    FROM   [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
                                    WHERE  T.PINNO = @pinno
                                           AND T.processid = @processid
                                           AND T.DataInsertedInMoneySend = 'P'
                                    
                                    SET @flag = 'f'
                                END
                                
                                IF @BANK_ACCOUNT_NUMBER IS NULL
                                BEGIN
                                    SET @return_value = 
                                        '[3010] Bank Account No is blank'
                                    
                                    UPDATE dbo.tbl_FTP_Import_File_Data
                                    SET    DataInsertedInMoneySend = 'F'
                                          ,DataInsertedDate = GETDATE()
                                          ,Remarks = @return_value
                                    FROM   [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
                                    WHERE  T.PINNO = @pinno
                                           AND T.processid = @processid
                                           AND T.DataInsertedInMoneySend = 'P'
                                    
                                    SET @flag = 'f'
                                END
                                
                                SET @OTHER_BANK_BRANCH_NAME = RTRIM(LTRIM(@OTHER_BANK_BRANCH_NAME)) 
                                    --IF @OTHER_BANK_BRANCH_NAME='' OR @OTHER_BANK_BRANCH_NAME IS NULL
                                    --BEGIN
                                    --	 set @return_value='For Account Deposit to Other Bank payment mode Bank branch is mandatory valid.'
                                    --	 select '3011' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL REFID
                                    --	 return
                                    --END
                            END
                            
                               DECLARE @Branch_group VARCHAR(200)    
                                IF @PAYMENTTYPE='Bank Transfer'
                                BEGIN
                                    IF @Payout_AgentCan NOT IN ('Both' ,'None')
                                    BEGIN
                                        SET @return_value = 
                                            '[3002] Select Location ID can not perform Account Deposit'
                                        
                                        UPDATE dbo.tbl_FTP_Import_File_Data
                                        SET    DataInsertedInMoneySend = 'F'
                                              ,DataInsertedDate = GETDATE()
                                              ,Remarks = @return_value
                                        FROM   [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
                                        WHERE  T.PINNO = @pinno
                                               AND T.processid = @processid
                                               AND T.DataInsertedInMoneySend = 
                                                   'P'
                                        
                                        SET @flag = 'f'
                                    END
                                    
                                    IF @BANK_ACCOUNT_NUMBER IS NULL
                                    BEGIN
                                        SET @return_value = 
                                            '[3010] Bank Account No is blank'
                                        
                                        UPDATE dbo.tbl_FTP_Import_File_Data
                                        SET    DataInsertedInMoneySend = 'F'
                                              ,DataInsertedDate = GETDATE()
                                              ,Remarks = @return_value
                                        FROM   [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
                                        WHERE  T.PINNO = @pinno
                                               AND T.processid = @processid
                                               AND T.DataInsertedInMoneySend = 
                                                   'P'
                                        
                                        SET @flag = 'f'
                                    END
                                END    
                                
                                IF @flag='s'
                                BEGIN
                                    DECLARE @ho_cost_send_rate                MONEY
                                           ,@ho_premium_send_rate             MONEY
                                           ,@ho_premium_payout_rate           MONEY
                                           ,@agent_customer_diff_value        MONEY
                                           ,@agent_sending_rate_margin        MONEY
                                           ,@agent_payout_rate_margin         MONEY
                                           ,@agent_sending_cust_exchangerate  MONEY
                                           ,@agent_payout_agent_cust_rate     MONEY
                                           ,@ho_exrate_applied_type           VARCHAR(20)
                                           ,@scharge                          MONEY
                                           ,@sendercommission                 MONEY
                                           ,@agent_receiverSCommission        MONEY
                                           ,@ho_dollar_rate                   MONEY
                                           ,@agent_settlement_rate            MONEY
                                           ,@exchangerate                     MONEY
                                           ,@today_dollar_rate                MONEY
                                           ,@round_by                         INT
                                           ,@receiveamt                       MONEY
                                           ,@totalroundamt                    MONEY
                                           ,@Create_ts                        DATETIME    
                                    
                                    SELECT @ho_dollar_rate = x.DollarRate
                                          ,@agent_settlement_rate = x.NPRRate
                                          ,@exchangerate = x.exchangerate
                                          ,@today_dollar_rate = ISNULL(b.customer_rate ,x.customer_rate)
                                          ,@round_by = ISNULL(x.qtyCurrency ,2)
                                          ,@ho_cost_send_rate = x.exchangeRate+
                                           ISNULL(x.agent_premium_send ,0)
                                          ,@ho_premium_send_rate = ISNULL(x.agent_premium_send ,0)
                                          ,@ho_premium_payout_rate = ISNULL(x.agent_premium_payout ,0)
                                          ,@agent_customer_diff_value = ISNULL(x.customer_diff_value ,0)
                                          ,@agent_sending_rate_margin = ISNULL(x.margin_sending_agent ,0)
                                          ,@agent_payout_rate_margin = ISNULL(x.receiver_rate_diff_value ,0)
                                          ,@agent_sending_cust_exchangerate = 
                                           ISNULL(x.sending_cust_exchangerate ,0)
                                          ,@agent_payout_agent_cust_rate = 
                                           ISNULL(x.payout_agent_rate ,0)
                                          ,@ho_exrate_applied_type = 
                                           'countrywise'
                                          ,@PAYOUTCURRENCY = x.ReceiveCType
                                    FROM   agentCurrencyRate x WITH(NOLOCK)
                                           LEFT OUTER JOIN agent_branch_rate b 
                                                WITH(NOLOCK)
                                                ON  x.agentId = b.agentid
                                                    AND b.agent_branch_code = @agent_branch_code
                                    WHERE  x.agentId = @agentcode
                                           AND x.receiveCountry = @PAYOUT_COUNTRY
                                           AND x.currencyType = @COLLECT_CURRENCY
                                           AND x.receiveCType<>'USD' 
                                    --AND x.receiveCType=@PAYOUTCURRENCY    
                                    
                                    IF EXISTS(
                                           SELECT Currencyid
                                           FROM   agentpayout_CurrencyRate WITH(NOLOCK)
                                           WHERE  agentid = @agentcode
                                                  AND payout_agent_id = @payout_agent_id
                                       )
                                    BEGIN
                                        --PRINT 'insert agent wise'    
                                        SELECT @ho_dollar_rate = x.DollarRate
                                              ,@agent_settlement_rate = x.NPRRate
                                              ,@exchangerate = x.exchangerate
                                              ,@today_dollar_rate = x.customer_rate
                                              ,@round_by = ISNULL(x.qtyCurrency ,2)
                                              ,@ho_cost_send_rate = x.exchangeRate 
                                              +
                                               ISNULL(x.agent_premium_send ,0)
                                              ,@ho_premium_send_rate = ISNULL(x.agent_premium_send ,0)
                                              ,@ho_premium_payout_rate = ISNULL(x.agent_premium_payout ,0)
                                              ,@agent_customer_diff_value = 
                                               ISNULL(x.customer_diff_value ,0)
                                              ,@agent_sending_rate_margin = 
                                               ISNULL(x.margin_sending_agent ,0)
                                              ,@agent_payout_rate_margin = 
                                               ISNULL(x.receiver_rate_diff_value ,0)
                                              ,@agent_sending_cust_exchangerate = 
                                               ISNULL(x.sending_cust_exchangerate ,0)
                                              ,@agent_payout_agent_cust_rate = 
                                               ISNULL(x.payout_agent_rate ,0)
                                              ,@ho_exrate_applied_type = 
                                               'payoutwise'
                                        FROM   agentpayout_CurrencyRate x WITH(NOLOCK)
                                        WHERE  x.agentId = @agentcode
                                               AND payout_agent_id = @payout_agent_id
                                    END
                                    
                                    UPDATE dbo.tbl_FTP_Import_File_Data
                                    SET ho_dollar_rate =@ho_dollar_rate 
                                              ,agent_settlement_rate=@agent_settlement_rate 
                                              ,exchangerate=@exchangerate
                                              ,today_dollar_rate=@today_dollar_rate 
                                              ,round_by=@round_by 
                                              ,ho_cost_send_rate=@ho_cost_send_rate 
                                              ,ho_premium_send_rate=@ho_premium_send_rate 
                                              ,ho_premium_payout_rate=@ho_premium_payout_rate 
                                              ,agent_customer_diff_value=@agent_customer_diff_value 
                                              ,agent_sending_rate_margin=@agent_sending_rate_margin 
                                              ,agent_payout_rate_margin=@agent_payout_rate_margin 
                                              ,agent_sending_cust_exchangerate=@agent_sending_cust_exchangerate
                                              ,agent_payout_agent_cust_rate=@agent_payout_agent_cust_rate 
                                              ,ho_exrate_applied_type=@ho_exrate_applied_type 
                                              ,PAYOUTCURRENCY=@PAYOUTCURRENCY
									          ,DataInsertedInMoneySend ='T'
                                              ,DataInsertedDate =dbo.getDateHO(GETDATE())
                                              ,Remarks ='Ready for Approve.'
                                               FROM   
                                               [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
                                                        WHERE  T.PINNO = @pinno
                                                               AND T.processid =@processid
                                                               AND T.DataInsertedInMoneySend ='P'
                                    
                                    
             END
             END
             END
             END
             end                                      
    ------------------------------------------------
    FETCH NEXT FROM FTP INTO @processid ,@pinno
 END                
 CLOSE FTP                  
 DEALLOCATE FTP   	
 END
-------------------------------------------------			
			
GO


