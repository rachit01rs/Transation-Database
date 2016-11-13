IF OBJECT_ID('spa_make_bulk_payment_csv', 'P') IS NOT NULL 
    DROP PROC [dbo].[spa_make_bulk_payment_csv]
GO

CREATE PROC [dbo].[spa_make_bulk_payment_csv]    
    @ditital_id_payout VARCHAR(200) ,    
    @send_sms CHAR(1) = NULL ,    
    @is_fromExport CHAR(1) = NULL    
AS     
    IF NOT EXISTS ( SELECT  *    
                    FROM    temp_trn_csv_pay WITH ( NOLOCK )    
                    WHERE   digital_id_payout = @ditital_id_payout )     
        BEGIN                                    
            SELECT  'ERROR' ,    
                    '1001' ,    
                    'Transaction detail not found for payment !!!'                                    
            RETURN                                    
        END                                    
    BEGIN TRY      
      
        BEGIN TRANSACTION      
      
        DECLARE @paidTime VARCHAR(50) ,    
            @podDate DATETIME     
        SET @podDate = dbo.getDateHO(GETUTCDATE())                            
    
        DELETE  temp_trn_csv_pay    
        FROM    temp_trn_csv_pay t WITH ( NOLOCK )    
                JOIN moneySend ms WITH ( NOLOCK ) ON t.refno = ms.refno    
        WHERE   ms.status = 'Paid'    
    
                
        UPDATE  moneysend    
        SET     rBankName = t.rBankName ,    
                rBankBranch = CASE WHEN PaymentType = 'Bank Transfer'    
                                   THEN m.rBankBranch    
                                   ELSE t.rBankBranch    
                              END ,    
                rBankId = CASE WHEN PaymentType = 'Bank Transfer'    
                               THEN m.rBankId    
                               ELSE t.rBankId    
                          END ,    
                paidBy = t.paidBy ,    
                paidDate = t.paidDate ,    
                podDate = @podDate ,    
                paidTime = CONVERT(VARCHAR, dbo.getDateHO(GETUTCDATE()), 108) ,    
                status = 'Paid' ,    
                receiveAgentID = t.expected_payoutAgentId ,    
                digital_id_payout = @ditital_id_payout ,    
                lock_status = 'unlocked'    
        FROM    moneysend m WITH ( NOLOCK )    
                JOIN temp_trn_csv_pay t WITH ( NOLOCK ) ON m.refno = t.refno    
        WHERE   transstatus = 'Payment'    
                AND status IN ( 'Un-Paid', 'Post' )    
                AND m.expected_payoutAgentId = t.expected_payoutAgentId    
                AND m.confirmDate IS NOT NULL    
                AND m.test_trn IS NULL    
                AND t.digital_id_payout = @ditital_id_payout      
                                            
--------------------------------------------------------------------              
        INSERT  transactionNotes    
                ( refno ,    
                  comments ,    
                  datePosted ,    
                  PostedBy ,    
                  uploadBy ,    
                  NoteType ,    
                  tranno    
                )    
                SELECT  m.refno ,    
                        'Trasaction Paid By (AG:' + t.paidBy + ') CSV Paid' ,    
                        GETDATE() ,    
                        t.paidBy ,    
                        'A' ,    
                        2 ,    
                        m.tranno    
                FROM    moneysend m WITH ( NOLOCK )    
                        JOIN temp_trn_csv_pay t WITH ( NOLOCK ) ON m.refno = t.refno    
                WHERE   status = 'Paid'    
                        AND m.expected_payoutAgentId = t.expected_payoutAgentId    
                        AND m.confirmDate IS NOT NULL    
                        AND m.test_trn IS NULL    
                        AND t.digital_id_payout = @ditital_id_payout    
                        AND m.PODDate = @podDate     
  
-------------------------------  TO NOTIFY SENDING API PARTNER ABOUT THEIR TRANSACTION STATUS  
  insert into SOAP_TXN_NOTIFICATION(refno,agentid,notification_remarks,notification_date,notification_type)  
  SELECT  DBO.DECRYPTDB(m.refno) ,m.agentid,'TXN Paid',m.paiddate,'Paid'   
                FROM    moneysend m WITH ( NOLOCK )    
                        JOIN temp_trn_csv_pay t WITH ( NOLOCK ) ON m.refno = t.refno    
                WHERE   status = 'Paid' AND senderBankname='API Transaction'   
                        AND m.expected_payoutAgentId = t.expected_payoutAgentId    
                        AND m.confirmDate IS NOT NULL    
                        AND m.test_trn IS NULL    
                        AND t.digital_id_payout = @ditital_id_payout    
                        AND m.PODDate = @podDate  
-----------------------------------------------------------------------------------------------  
      
        SELECT  m.expected_payoutAgentId ,    
                SUM(m.totalroundamt) totalroundamt    
        INTO    #temp_balance    
        FROM    moneysend m WITH ( NOLOCK )    
                JOIN temp_trn_csv_pay t WITH ( NOLOCK ) ON m.refno = t.refno    
        WHERE   transstatus = 'Payment'    
                AND m.status = 'Paid'    
                AND m.expected_payoutAgentId = t.expected_payoutAgentId    
                AND t.digital_id_payout = @ditital_id_payout    
AND m.PODDate = @podDate    
        GROUP BY m.expected_payoutAgentId      
      
        UPDATE  agentdetail    
        SET     currentBalance = currentBalance - t.totalroundamt    
        FROM    agentdetail a WITH ( NOLOCK )    
                JOIN #temp_balance t ON a.agentCode = t.expected_payoutAgentId      
    
--------------------------------------------------------------------      
        IF @is_fromExport IS NULL     
            BEGIN      
                SELECT  m.tranno MID ,    
                        m.refno ,    
                        m.SenderName ,    
                        m.receiverName ,    
                        m.paidAmt ,    
                        m.SCharge ,    
                        m.totalRoundAmt    
                FROM    temp_trn_csv_pay t WITH ( NOLOCK )    
                        LEFT OUTER JOIN moneysend m WITH ( NOLOCK ) ON t.refno = m.refno    
                WHERE   t.digital_id_payout = @ditital_id_payout    
                        AND m.PODDate = @podDate    
            END      
---------------------------------------------------------------------      
      
---SEND SMS---      
        SET @send_sms = 'y'      
      
        IF @send_sms = 'y'     
            BEGIN  
				--------------------------------------------------------------------------------
				-- SMS Send to Sender After payment---------------------------------  
				INSERT INTO sms_pending (deliverydate,mobileno,message,refno,smsto,country,agentuser,status,sender_id)
				SELECT dbo.getDateHO(GETUTCDATE()),m.sender_mobile,dbo.FNA_GET_SMS_MSG(m.tranno),dbo.decryptDb(m.refno),'S',m.SenderCountry,m.paidBy,'p','447937900000'
				FROM dbo.moneySend m WITH(NOLOCK) JOIN temp_trn_csv_pay t WITH ( NOLOCK ) ON m.refno = t.refno WHERE m.status='Paid'  
				AND m.sender_mobile IS NOT NULL
				AND m.isIRH_trn IS NULL 
				AND m.send_sms='y' 
				AND t.digital_id_payout = @ditital_id_payout
				--------------------------------------------------------------------------------     
            END      
--------------      
DECLARE @remote_db VARCHAR(200) ,    
            @sql VARCHAR(MAX) ,    
            @paidDate VARCHAR(50) ,    
            @PartnerAgentcode VARCHAR(50)      
        SET @paidDate = dbo.getDateHO(GETUTCDATE())      
        IF EXISTS ( SELECT  sno    
                    FROM    static_values    
                    WHERE   sno = 200    
                            AND static_value = 'Prabhu MY' )     
            BEGIN      
                SELECT  @remote_db = additional_value ,    
                        @PartnerAgentcode = static_data    
                FROM    static_values    
                WHERE   sno = 200    
                        AND static_value = 'Prabhu MY'      
      
     
                INSERT  INTO TransPaidStatus_OUT    
                        ( refno ,    
                          rBankId ,    
						  rBankName ,    
                          rBankBranch ,    
                          paidBy ,    
                          paidDate ,    
                          podDate ,    
                          paidTime ,    
                          status ,    
                          receiverCommission ,    
                          receiveAgentID ,    
                          digital_id_payout ,    
                          agent_receiverCommission ,    
                          agent_receiverComm_Currency ,    
                          lock_status ,    
                          agent_receiverSCommission ,    
                          paid_agent_id ,    
                          paid_date_usd_rate    
                        )    
                        SELECT  m.refno ,    
                                m.rBankId ,    
                                m.rBankName ,    
                                m.rBankBranch ,    
                                m.paidBy ,    
                                m.paidDate ,    
                                m.podDate ,    
                                m.paidTime ,    
                                m.status ,    
                                m.receiverCommission ,    
								receiveAgentID ,    
                                m.digital_id_payout ,    
                                m.agent_receiverCommission ,    
                                m.agent_receiverComm_Currency ,    
                                m.lock_status ,    
                                m.agent_receiverSCommission ,    
                                m.paid_agent_id ,    
                                m.paid_date_usd_rate    
                        FROM    moneysend m WITH ( NOLOCK )    
                                JOIN temp_trn_csv_pay t WITH ( NOLOCK ) ON m.refno = t.refno    
                        WHERE   m.status = 'Paid'    
                                AND m.expected_payoutAgentId = t.expected_payoutAgentId    
                                AND t.digital_id_payout = @ditital_id_payout    
                                AND m.PODDate = @podDate    
                                AND m.agentid = @PartnerAgentcode    
     
--set @sql=' insert into '+@remote_db+'tbl_status_moneysend_paid(      
-- refno,rBankId,rBankName,rBankBranch,paidBy,paidDate,podDate,paidTime,status,      
-- receiverCommission,receiveAgentID,digital_id_payout,agent_receiverCommission,      
-- agent_receiverComm_Currency,lock_status,agent_receiverSCommission,paid_agent_id,      
-- paid_date_usd_rate)      
--select m.refno,m.rbankid,m.rBankName,m.rBankBranch,m.paidBy,m.paidDate,m.podDate,m.paidTime,m.status,      
-- m.receiverCommission,m.receiveAgentID,m.digital_id_payout,m.agent_receiverCommission,      
-- m.agent_receiverComm_Currency,m.lock_status,m.agent_receiverSCommission,m.paid_agent_id,      
-- m.paid_date_usd_rate from       
-- moneysend m with (NOLOCK) join temp_trn_csv_pay t on  m.refno=t.refno      
--  where transstatus=''Payment'' and status =''Paid''      
--  and m.expected_payoutAgentId=t.expected_payoutAgentId      
--  and m.confirmDate is not Null and m.test_trn is Null      
--  and t.digital_id_payout='''+@ditital_id_payout+'''      
-- and agentid='''+@PartnerAgentcode+''''      
--      
--print @sql      
--exec (@sql)      
      
      
            END     
                
--------------------------------------------------------------------    
------Calc Commission ----------------------------------------------    
  DECLARE @job_name VARCHAR(300),@spa VARCHAR(1000)    
  SET @job_name='spa_make_bulk_payment_csv'+REPLACE(newid(),'-','_')    
  SET @spa='update_slab_paidCommission_job '''+ @ditital_id_payout +''''    
  EXEC spa_run_sp_as_job @job_name, @spa, 'CalcCommission', 'system'    
            
--------------------------------------------------------------------    
        COMMIT TRANSACTION      
    END TRY      
    BEGIN CATCH      
      
        IF @@trancount > 0     
            ROLLBACK TRANSACTION      
      
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
                        'spa_make_bulk_payment_csv' ,    
                        'SQL' ,    
                        @desc ,    
                        'SQL' ,    
                        'SP' ,    
                        @ditital_id_payout ,    
                        GETDATE()      
        SELECT  'ERROR' ,    
                '1050' ,    
                'Error Please try again'      
      
    END CATCH 