DROP PROC [dbo].[spa_LSlink_cancelpayTRN]  
Go 
CREATE PROC [dbo].[spa_LSlink_cancelpayTRN]  
    @control_no VARCHAR(50) = NULL ,  
    @payout_partner_id VARCHAR(50) = NULL ,  
    @payout_user_id VARCHAR(50) = NULL ,  
    @ho_user_id VARCHAR(50) = NULL  
AS   
    DECLARE @control_no_enc VARCHAR(50)  
    SET @control_no_enc = dbo.encryptDb(@control_no)  
    SELECT  *  
    INTO    #temp  
    FROM    dbo.moneySend WITH ( NOLOCK )  
    WHERE   refno = @control_no_enc  
            AND lock_by = @payout_user_Id  
            --AND expected_payoutagentid = @payout_partner_id   
            AND status='Un-Paid' AND TransStatus='Payment' AND lock_status = 'locked'  
  
    IF EXISTS ( SELECT  'x'  
                FROM    #temp )   
        BEGIN  
            UPDATE  moneysend  
            SET     lock_status = 'unlocked' ,  
                    lock_by = NULL  
            WHERE   refno = @control_no_enc  
                    AND lock_by = @payout_user_Id  
                   --AND expected_payoutagentid = @payout_partner_id   
          
            IF @ho_user_id IS NOT NULL   
                BEGIN  
                    INSERT  INTO dbo.TransactionNotes  
                            ( RefNo ,  
                              Comments ,  
                              DatePosted ,  
                              PostedBy ,  
                              uploadBy ,  
                              noteType ,  
                              tranno   
             )  
                            SELECT  refno , -- RefNo - varchar(50)  
                                    'This Transaction is UNLOCK by :' + @ho_user_id , -- Comments - varchar(500)  
                                    dbo.getDateHO(GETUTCDATE()) , -- DatePosted - datetime  
                                    @ho_user_id , -- PostedBy - varchar(50)  
                                    'A' , -- uploadBy - varchar(50)  
                                    2 , -- noteType - int  
                                    Tranno  -- tranno - int  
                            FROM    #temp  
                END  
                  
            SELECT  'SUCCESS' Status ,  
                    '1006' Code ,  
                    'Transaction sucessfully un-locked ' Message  
          
        END  
    ELSE   
        BEGIN  
            SELECT  'ERROR' Status ,  
                    '1001' Code ,  
                    'Unsuccess to Un-Locked Transactioin <br> Detail may be Incorrect.' Message     
        END