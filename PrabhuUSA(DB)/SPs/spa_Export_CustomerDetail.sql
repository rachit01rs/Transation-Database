IF OBJECT_ID('spa_Export_CustomerDetail', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.spa_Export_CustomerDetail
GO
CREATE PROCEDURE dbo.spa_Export_CustomerDetail
    @customerType CHAR(1) = NULL ,
    @login_user_id VARCHAR(50) = NULL ,
    @process_id VARCHAR(100) = NULL ,
    @batch_id VARCHAR(100) = NULL ,
    @url_desc VARCHAR(100) = NULL,
	@rMonth VARCHAR(10) = NULL,
	@rYear VARCHAR(10) = NULL
AS 
    SET NOCOUNT ON
    DECLARE @sql VARCHAR(MAX) ,
        @ledger_tabl VARCHAR(100) ,
        @desc VARCHAR(5000),
        @total_row INT,@monthName VARCHAR(20)
	------Creating the Temp Table Name----------------
    SET @ledger_tabl = dbo.FNAProcessTbl(@batch_id, REPLACE(@login_user_id,':','_'),
                                         @process_id)
	--------------------------------------------------
	
    SET @sql = '
    SELECT  
		ROW_NUMBER() over(ORDER BY RTRIM(LTRIM(cd.SenderName)),RTRIM(LTRIM(cd.CustomerId)))  [S.N.],
		RTRIM(LTRIM(cd.CustomerId)) [Customer ID],
		RTRIM(LTRIM(cd.SenderName)) [Customer Name],
		RTRIM(LTRIM(cd.SenderAddress)) [Address],
		cd.SenderCountry [Country],
		cd.SenderNativeCountry [Nationality],
		cd.senderFax [Sender ID Type],
		RTRIM(LTRIM(cd.senderPassport)) [Sender ID Number],
		RTRIM(LTRIM(cd.SSN_Card_ID)) [Scoial Security Number] ,
		RTRIM(LTRIM(cd.SenderPhoneno)) [Telephone Number],
		RTRIM(LTRIM(cd.SenderMobile)) [Mobile Number]
    INTO    ' + @ledger_tabl
        + '
    FROM    customerDetail cd WITH ( NOLOCK )
    WHERE 1=1 AND MONTH(ISNULL(cd.update_ts,cd.create_ts)) ='''+@rMonth+''' AND year(ISNULL(cd.update_ts,cd.create_ts)) ='''+@rYear+ ''''  
        IF @customerType IS NOT NULL
			BEGIN
        		IF LOWER(@customerType) ='f'
					SET @sql = @sql + ' AND cd.FreeSMS=''y'''
				ELSE
					SET @sql = @sql + ' AND ISNULL(cd.FreeSMS,''n'')=''n'''	
			END 
	       
      SET @sql = @sql + ' INSERT #temp_total_amount(total_row) select  count(*) FROM ' + @ledger_tabl
        CREATE TABLE #temp_total_amount(total_row int )  
		
    PRINT @sql            
    EXEC (@sql)
   
    
  --  RETURN   
------------------------------------------------------------------------------------------------
  SELECT @total_row = total_row           
  FROM    #temp_total_amount 

	SET @url_desc=ISNULL(@url_desc,'Null')
       SELECT @monthName=month_name FROM tbl_month tm WHERE month_id=+cast(@rMonth as varchar)  	
     
           
    SET @desc = '<strong><u>Customer Detail DOWNLOAD</u></strong> '          
            + ' is completed.  Total Customer : <strong><u>'          
            + CAST(ISNULL(@total_row, 0) AS VARCHAR) + '</u></strong>  Year : <strong><u>'          
            + CAST(ISNULL(@rYear, 0) AS VARCHAR) + '</u></strong>  Month : <strong><u>'          
            + CAST(ISNULL(@monthName, 0) AS VARCHAR) + '</u></strong>' 

    PRINT 'spa_message_board ''u'', '''+@login_user_id+''', NULL,'''+ @batch_id+''','''+ @desc+''', ''c'',
        '''+@process_id+''', NULL,'+ @url_desc
    EXEC spa_message_board 'u', @login_user_id, NULL, @batch_id, @desc, 'c',
        @process_id, NULL, @url_desc
------------------------------------------------------------------------------------------------