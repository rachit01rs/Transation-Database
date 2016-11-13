DROP PROC [dbo].[spa_unblock_txn]  
Go  
--spa_unblock_txn '8906162','deepen','test'  
CREATE PROC [dbo].[spa_unblock_txn]
    @tranno VARCHAR(1000) ,
    @userid VARCHAR(50) ,
    @remarks VARCHAR(200)
AS 
	SET NOCOUNT ON
    CREATE TABLE #temp
        (
          tranno BIGINT ,
          refno VARCHAR(50)
        )
    BEGIN TRY
        BEGIN TRANSACTION
			EXEC ('INSERT INTO #temp (tranno,refno)
			SELECT tranno,refno from moneysend with(nolock) where tranno in ('+ @tranno +')')
				
			UPDATE  moneysend
			SET     transStatus = ISNULL(transStatusPrevious, 'Payment')
			FROM    dbo.moneySend m WITH ( NOLOCK )
					JOIN #temp t ON m.Tranno = t.tranno
			    
			INSERT  INTO TransactionNotes
					( RefNo ,
					  Comments ,
					  DatePosted ,
					  PostedBy ,
					  uploadBy ,
					  noteType ,
					  tranno
						
						
					)
					SELECT  refno ,
							@remarks ,
							dbo.getDateHO(GETUTCDATE()) ,
							'HO:' + @userid ,
							'A' ,
							2 ,
							tranno
					FROM    #temp 
        SELECT  'SUCCESS' STATUS ,
                'UnBlock Successful ... ' msg	    
        COMMIT TRANSACTION          
            
 --**** Thrid party Status Update (Prabhu Cash)           
        DECLARE @refno VARCHAR(50)
        DECLARE db_cursor CURSOR
        FOR
            SELECT  refno
            FROM    #temp WITH ( NOLOCK ) 
         

        OPEN db_cursor   
        FETCH NEXT FROM db_cursor INTO @refno

        WHILE @@FETCH_STATUS = 0 
            BEGIN 
                EXEC spa_integration_partner_cancel_ticket 'u', NULL, @refno,
                    'Un-Block', NULL, NULL, @userid, NULL, @remarks, NULL,
                    NULL   
                FETCH NEXT FROM db_cursor INTO @refno
            END   

        CLOSE db_cursor   
        DEALLOCATE db_cursor
            
        DROP TABLE #temp	
        	
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
                  [error_date]
                )
                SELECT  -1 ,
                        @desc ,
                        'spa_unblock_txn' ,
                        'SQL' ,
                        @desc ,
                        'SQL' ,
                        'spa_unblock_txn' ,
                        GETDATE()            

        SELECT  'ERROR' STATUS ,
                'Please try again: ' + CAST(@@IDENTITY AS VARCHAR(10)) msg

    END CATCH 