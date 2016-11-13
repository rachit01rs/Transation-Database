IF OBJECT_ID('update_slab_paidCommission_dateWise') IS NOT NULL 
    DROP PROC update_slab_paidCommission_dateWise
go
CREATE PROC update_slab_paidCommission_dateWise
    @expected_payoutAgentId VARCHAR(50),
    @country VARCHAR(100),
    @fromdate VARCHAR(50),
    @todate VARCHAR(50),
    @login_user_id VARCHAR(50) = NULL ,
    @batch_Id VARCHAR(100) = NULL, 
    @process_id VARCHAR(100) = NULL   
AS 
	SET @todate=@todate+' 23:59:59.998'
    DECLARE @refno VARCHAR(50),@total_row INT,@agent_name VARCHAR(500),@desc VARCHAR(1000)
    SET @total_row=0
    SELECT @agent_name=CompanyName from dbo.agentDetail WHERE agentCode=@expected_payoutAgentId
    DECLARE db_cursor CURSOR
    FOR   
        SELECT  m.refno
        FROM    moneysend m WITH ( NOLOCK )
        WHERE   status = 'Paid'
                AND m.expected_payoutAgentId = @expected_payoutAgentId
                AND m.confirmDate IS NOT NULL
                AND m.test_trn IS NULL
                AND m.ReceiverCountry=@country
                AND m.paidDate BETWEEN @fromdate AND @todate
                AND ISNULL(agent_receiverCommission,0)=0
                  
      
    OPEN db_cursor   
    FETCH NEXT FROM db_cursor INTO @refno

    WHILE @@FETCH_STATUS = 0 
        BEGIN  
            SET @total_row=@total_row+1
            EXEC update_slab_paidCommission @refno
            FETCH NEXT FROM db_cursor INTO @refno
        END   

    CLOSE db_cursor   
    DEALLOCATE db_cursor
    
   	        
    SET @desc = '<strong><u>'+@agent_name+' ('+@country+') </u></strong> '          
            + ' comission Update.  Total Txn Commission updated: <strong><u>'          
            + CAST(ISNULL(@total_row, 0) AS VARCHAR) + '</u></strong> From: ' + @fromDate + ' To: ' + @toDate 

    --PRINT 'spa_message_board ''u'', '''+@login_user_id+''', NULL,'''+ @batch_id+''','''+ @desc+''', ''c'',
    --    '''+@process_id+''', NULL,'+ ISNULL(@url_desc,'Null')
    EXEC spa_message_board 'u', @login_user_id, NULL, @batch_id, @desc, 'c',
        @process_id, NULL, NULL