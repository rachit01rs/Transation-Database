DROP PROC [dbo].[spRemote_Processing]  
Go
--alter table moneySend add remote_download char(1)  
  
CREATE PROC [dbo].[spRemote_Processing]
    @flag CHAR(1) ,
    @tranno INT = NULL ,
	@refno varchar(50) = NULL
AS 
    SET NOCOUNT ON
	DECLARE     @confirm_process_id VARCHAR(150) ,  
                @SEMPID VARCHAR(50),  
                @payout_agentid VARCHAR(50),  
                @remote_db VARCHAR(100),  
				@previous_status varchar(100),  
                @sql VARCHAR(5000) 
				
    IF @flag = 's' 
        SELECT TOP 50  
                m.*  
        FROM    moneysend m WITH ( NOLOCK )  
                LEFT OUTER JOIN tbl_status_moneysend t WITH ( NOLOCK ) ON t.Refno = m.refno  
                JOIN agentdetail a WITH ( NOLOCK ) ON a.agentcode = m.agentid  
        WHERE   transstatus = 'Processing'  
                AND DATEDIFF(MINUTE, confirmDate,  
                             dbo.CTgetGMTDate(GETUTCDATE(), a.GMT_value, 0)) > 10  
                AND CASE WHEN t.Process_Date IS NOT NULL  
                         THEN DATEDIFF(MINUTE, t.Process_Date, GETDATE())  
                         ELSE 1  
                    END > CASE WHEN t.Process_Date IS NOT NULL THEN 10  
                               ELSE 0  
                          END  
                AND remote_download IS NULL  
        ORDER BY confirmDate 
        
    IF @flag = 'u'   
        BEGIN    
             
            SELECT  @refno = refno ,  
                    @confirm_process_id = confirm_process_id ,  
                    @SEMPID = SEMPID ,  
					@previous_status= transStatus,  
                    @payout_agentid=expected_payoutagentid  
            FROM    moneysend WITH ( NOLOCK )  
            WHERE   Tranno = @tranno  
                    AND transStatus = 'Processing'  
            IF @confirm_process_id IS NULL   
                BEGIN  
                    SELECT  'ERROR' [STATUS] ,  
                            'TXN CAN''T BE RE-PROCESSED. PLEASE CONTACT SUPPORT TEAM.' [MESSAGE]  
                    RETURN  
                END  
			IF @previous_status in ('OFAC','Compliance')  
                BEGIN  
                    SELECT  'ERROR' [STATUS] ,  
                            'TXN CAN''T BE RE-PROCESSED NOW. PLEASE APPROVE FROM '+@previous_status+' MENU.' [MESSAGE]  
                    RETURN  
                END  
    
            --- Checking in USA system---------------------------------------------------------------------  
            CREATE TABLE #temp_check  
                (  
                  transstatus VARCHAR(50) ,  
                  refno VARCHAR(50)  
                )  
            SELECT  @remote_db = remote_db  
            FROM    tbl_interface_setup  
            WHERE   agentcode = @payout_agentid  
                    AND mode = 'Send'   
            IF @remote_db IS NOT NULL   
                BEGIN    
                    SET @sql = ' INSERT INTO #temp_check (transstatus,refno) SELECT transstatus,refno   
					FROM ' + @remote_db + 'moneysend WITH(NOLOCK) WHERE refno=''' + @refno + ''''  
					EXEC (@sql)  
                    IF EXISTS ( SELECT  'x'  
                                FROM    #temp_check )   
                        BEGIN  
                            UPDATE  dbo.moneySend  
                            SET     TransStatus = t.transstatus ,  
                                    remote_download = 'y'  
                            FROM    dbo.moneySend m WITH ( NOLOCK )  
                                    JOIN #temp_check t ON m.refno = t.refno  
       
                            SELECT  'SUCCESS' [STATUS] ,  
                                    'TXN NO:' + CAST(@TRANNO AS VARCHAR(50))  
                                    + ' WILL BE TRANSFERED' [MESSAGE]  
                            RETURN       
                        END  
                END   
   --------------------------------------------------------------------------------------  
              
            IF EXISTS ( SELECT  'x'  
                        FROM    tbl_status_moneysend WITH ( NOLOCK )  
                        WHERE   refno = @refno  
                                AND Status = 'Pending'  
                                AND DATEDIFF(MINUTE, Process_Date, GETDATE()) > 10 )   
                BEGIN  
                      
                          
                        --- Clearing the data from staging process for Re-process  
                    DELETE  FROM tbl_status_moneysend  
                    WHERE   refno = @refno  
                            AND Status = 'Pending'  
                    DELETE  FROM STATING_PROCESS.DBO.MONEYSEND_OUT  
                    WHERE   refno = @refno  
                        -----------------------------------------------------------       
                    EXEC spRemote_sendTrns 'i', @tranno, @SEMPID, '92400000',  
                        @confirm_process_id   
      
                    SELECT  'SUCCESS' [STATUS] ,  
                            'TXN NO:' + CAST(@TRANNO AS VARCHAR(50))  
                            + ' WILL BE TRANSFERED WITHIN 5 MIN' [MESSAGE]  
                          
                      
                END  
            ELSE   
                IF EXISTS ( SELECT  'x'  
                                FROM    dbo.moneySend m WITH ( NOLOCK )  
                                        LEFT OUTER JOIN tbl_status_moneysend t  
                                        WITH ( NOLOCK ) ON m.refno = t.refno  
                                        LEFT OUTER JOIN STATING_PROCESS.DBO.MONEYSEND_OUT mo ON m.refno = mo.refno  
                                WHERE   m.refno = @refno  
                                        AND t.Status IS NULL  
                                        AND m.TransStatus = 'Processing'  
                                        AND mo.refno IS NULL )   
                    BEGIN  
                        EXEC spRemote_sendTrns 'i', @tranno, @SEMPID,  
                            '92400000', @confirm_process_id   
      
                        SELECT  'SUCCESS' [STATUS] ,  
                                'TXN NO:' + CAST(@TRANNO AS VARCHAR(50))  
                                + ' WILL BE TRANSFERED WITHIN 5 MIN' [MESSAGE]  
                    END  
                ELSE   
                    BEGIN  
                        SELECT  'ERROR' [STATUS] ,  
                                'TXN CAN''T BE RE-PROCESSED. IT IS ALREADY IN RE-PROCESS STATE.' [MESSAGE]  
                    END   
        END

		IF @flag = 'r' -- send the txn manually to Prabhu Malaysia.
		BEGIN
			if @refno is null
			BEGIN
				SELECT 'ERROR' STATUS,'Required Field Blank...' MESSAGE
				RETURN
			END
			SET @refno=dbo.encryptdb(@refno)
		    IF exists (SELECT  'x'
					FROM moneySend ms WITH(NOLOCK) 
					join tbl_interface_setup tis  with(nolock)
					on ms.expected_payoutagentid=tis.agentcode 
					and tis.mode='Send'
					and enable_update_remote_DB='y'
					WHERE   ms.refno = @refno
							AND ms.Status='Un-Paid' 
							AND ms.TransStatus = 'Payment')
			BEGIN
				SELECT  @tranno = tranno ,
						@confirm_process_id = confirm_process_id ,
						@SEMPID = SEMPID 
				FROM    moneysend WITH ( NOLOCK )
				WHERE   refno= @refno 
				EXEC spRemote_sendTrns 'i', @tranno, @SEMPID,
                            '92400000', @confirm_process_id 
			    SELECT  'SUCCESS' [STATUS] ,
                                'TXN NO:' + CAST(@TRANNO AS VARCHAR(50))
                                + ' WILL BE TRANSFERED WITHIN 5 MIN' [MESSAGE]
			END
			ELSE
			BEGIN
				SELECT 'ERROR' STATUS,'TXN IS INVALID TO SEND / TXN ALREADY IN SENDING PROCESS....' MESSAGE
			END
		END
		
        
