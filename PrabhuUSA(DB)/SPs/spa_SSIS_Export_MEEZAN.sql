DROP PROC [dbo].[spa_SSIS_Export_MEEZAN]
go  
CREATE PROC [dbo].[spa_SSIS_Export_MEEZAN] @flag CHAR(1) = 's'
AS 
    SET NOCOUNT ON    
    DECLARE @ditital_id VARCHAR(200) ,
        @expected_payoutagentid VARCHAR(50) ,
        @rBankid VARCHAR(50)    
    SET @ditital_id = REPLACE(NEWID(), '-', '_')        
    SET @expected_payoutagentid = '20100081'   
    BEGIN TRY
        BEGIN TRANSACTION trans1 
        IF @flag = 's' -- actual txn to export  
            BEGIN  
                SELECT TOP 1
                        @rBankid = agent_branch_code
                FROM    agentbranchdetail WITH ( NOLOCK )
                WHERE   agentCode = @expected_payoutagentid    
                INSERT  INTO dbo.temp_SSIS_Package_moneysend
                        ( temp_tranno ,
                          process_id
		            )
                        SELECT  tranno ,
                                @ditital_id
                        FROM    moneysend m WITH ( NOLOCK )
                                JOIN agentdetail a WITH ( NOLOCK ) ON a.agentCode = m.agentid
                        WHERE   expected_payoutagentid = @expected_payoutagentid
                                AND Transstatus = 'Payment'
                                AND is_downloaded = 'p'
                                AND status = 'Post'
                                AND ISNULL(a.disable_payout, 'n') <> 'y'   
		  	      
                DECLARE @GMT_Date DATETIME             
                SELECT  @GMT_Date = DATEADD(mi, ISNULL(gmt_value, 345),
                                            GETUTCDATE())
                FROM    agentdetail WITH ( NOLOCK )
                WHERE   agentcode = @expected_payoutagentid   
		  
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
                                @GMT_Date ,
                                'SYSTEM' ,
                                expected_payoutagentid ,
                                ISNULL(rBankID, @rBankid) ,
                                rBankName ,
                                ISNULL(rBankBranch, b.branch) ,
                                @ditital_id
                        FROM    moneysend m WITH ( NOLOCK )
                                LEFT OUTER JOIN agentbranchdetail b WITH ( NOLOCK ) ON b.agent_branch_code = ISNULL(m.rBankID,
                                                              @rBankid)
                                JOIN agentdetail a WITH ( NOLOCK ) ON a.agentCode = m.agentid
                        WHERE   expected_payoutagentid = @expected_payoutagentid
                                AND Transstatus = 'Payment'
                                AND is_downloaded = 'p'
                                AND status = 'Post'
                                AND ISNULL(a.disable_payout, 'n') <> 'y'   
		      
		      
		      
		  -- PIC Update to Post    
		  --update prabhuCash.dbo.moneysend set is_downloaded='y',downloaded_by='system',downloaded_ts=getdate(),status='Post'    
		  --from moneysend u join prabhuCash.dbo.moneysend p    
		  --on u.refno=p.refno where u.expected_payoutagentid=@expected_payoutagentid and u.Transstatus ='Payment'     
		  --and u.is_downloaded='p' and u.status='Un-Paid'    
		      
		  --USA Update to Post    
                UPDATE  moneysend
                SET     is_downloaded = 'y' ,
                        downloaded_by = 'system' ,
                        downloaded_ts = GETDATE()
                FROM    dbo.moneySend m WITH ( NOLOCK )
                        JOIN agentdetail a WITH ( NOLOCK ) ON a.agentCode = m.agentid
                WHERE   expected_payoutagentid = @expected_payoutagentid
                        AND Transstatus = 'Payment'
                        AND is_downloaded = 'p'
                        AND status = 'Post'
                        AND ISNULL(a.disable_payout, 'n') <> 'y'  
		      
		   
		  
		  --XPINCODE|PAYMENTMODE|AMOUNT|CURRENCY_ID|REMITTANCE_PURPOSE_ID|REMITTERNAME|REMITTANCE_DATE|BENENAME|  
		  --BeneACCNO|BANK_CODE|BANKNAME |BRANCHCODE |BRANCHNAME|BRANCH_ADDRESS|BENEADDRESS|BENEFICIARY_MOBILE|  
		  --REMITTER_COUNTRY|   
                SELECT  dbo.decryptdb(refno) AS [XPINCODE] ,
                        CASE WHEN paymentType IN ( 'Cash Pay' ) THEN '2'
                             WHEN paymentType IN ( 'Bank Transfer' ) THEN '3'
                             ELSE '1'
                        END [PAYMENTMODE] ,
                        totalRoundAmt [AMOUNT] ,
                        receiveCType [CURRENCY_ID] ,
                        '1' [REMITTANCE_PURPOSE_ID] ,
                        senderName AS [REMITTERNAME] ,
                        dbo.FNAReplaceSpecialChars(CONVERT(VARCHAR, CAST(confirmDate AS DATETIME), 101),
                                                   '') AS [REMITTANCE_DATE] ,
                        ReceiverName AS [BENENAME] ,
                        CASE WHEN paymentType = 'Cash Pay' THEN NULL
                             ELSE rBankACNo
                        END AS [BeneACCNO] ,
                        CASE WHEN paymentType IN ( 'Bank Transfer', 'Cash Pay' )
                             THEN '16'
                             ELSE ben_bank_id
                        END [BANK_CODE] ,
                        CASE WHEN paymentType IN ( 'Bank Transfer', 'Cash Pay' )
                             THEN 'MBL'
                             ELSE ben_bank_name
                        END [BANKNAME] ,
                        b.ext_branch_code [BRANCHCODE] ,
                        CASE WHEN paymentType IN ( 'Bank Transfer', 'Cash Pay' )
                             THEN rBankBranch
                             ELSE rBankAcType
                        END [BRANCHNAME] ,
                        CASE WHEN paymentType IN ( 'Bank Transfer', 'Cash Pay' )
                             THEN b.address
                             ELSE rBankAcType
                        END [BRANCH_ADDRESS] ,
                        receiverAddress AS [BENEADDRESS] ,      
				--'' as [Beneficiary CNIC],    
				-- receiverphone as [Beneficiary Phone],  
                        receiver_mobile AS [BENEFICIARY_MOBILE] ,  
			   --  '' as [Beneficiary E-Mail],    
                        ISNULL(sendercountry, '') + '|' AS [REMITTER_COUNTRY]    
			   --  '' as [Remitter E-Mail],    
			   --  sender_mobile as [Remitter Mobile],    
			   --  '' as [Message to Beneficiary]    
                FROM    moneysend m WITH ( NOLOCK )
                        JOIN dbo.temp_SSIS_Package_moneysend t WITH ( NOLOCK ) ON t.temp_tranno = m.tranno
                                                              AND t.process_id = @ditital_id
                        LEFT OUTER JOIN agentbranchdetail b WITH ( NOLOCK ) ON b.agent_branch_code = m.rBankID
                        JOIN agentdetail a WITH ( NOLOCK ) ON a.agentCode = m.agentid
                WHERE   expected_payoutagentid = @expected_payoutagentid
                        AND Transstatus = 'Payment'
                        AND ISNULL(a.disable_payout, 'n') <> 'y'
		  
                DELETE  FROM dbo.temp_SSIS_Package_moneysend
                WHERE   process_id = @ditital_id 
		   -- payment Process run--------------    
                CREATE TABLE #temp
                    (
                      col1 VARCHAR(100) ,
                      col2 VARCHAR(100) ,
                      col3 VARCHAR(100)
                    )    
                INSERT  INTO #temp
                        EXEC spa_make_bulk_payment_csv @ditital_id, NULL, 'y'  
            END  
		  
        IF @flag = 'c' -- count the no. of txn to export  
            BEGIN 
                UPDATE  moneysend
                SET     is_downloaded = 'p' ,
                        status = 'Post'
                FROM    dbo.moneySend m WITH ( NOLOCK )
                        JOIN agentdetail a WITH ( NOLOCK ) ON a.agentCode = m.agentid
                WHERE   expected_payoutagentid = @expected_payoutagentid
                        AND Transstatus = 'Payment'
                        AND is_downloaded IS NULL
                        AND status = 'Un-Paid'
                        AND ISNULL(a.disable_payout, 'n') <> 'y'
                SELECT  COUNT(*) row_county
                FROM    moneysend m WITH ( NOLOCK )
                        LEFT OUTER JOIN agentbranchdetail b ON b.agent_branch_code = m.rBankID
                        JOIN agentdetail a WITH ( NOLOCK ) ON a.agentCode = m.agentid
                WHERE   expected_payoutagentid = @expected_payoutagentid
                        AND Transstatus = 'Payment'
                        AND is_downloaded = 'p'
                        AND status = 'Post'
                        AND ISNULL(a.disable_payout, 'n') <> 'y'
            END 

        COMMIT TRANSACTION trans1
    END TRY  
    BEGIN CATCH
        IF @@trancount > 0 
            ROLLBACK TRANSACTION trans1  
        DECLARE @desc VARCHAR(1000)
        SET @desc = 'SQL Error found:  (' + ERROR_MESSAGE() + ')'    
        INSERT  INTO [error_info]
                ( [ErrorNumber] ,
                  [ErrorDesc] ,
                  [Script] ,
                  [ErrorScript] ,
                  [QueryString] ,
                  [ErrorCategory] ,
                  [ErrorSource] ,
                  [IP] ,
                  [error_date]
                )
                SELECT  -1 ,
                        @desc ,
                        'spa_SSIS_Export_MEEZAN' ,
                        'SQL' ,
                        @desc ,
                        'SQL' ,
                        'SP' ,
                        @ditital_id ,
                        GETDATE()  
    END CATCH