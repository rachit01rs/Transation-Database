IF OBJECT_ID('spa_Export_Commercial_Bank_of_Cylon', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.spa_Export_Commercial_Bank_of_Cylon
GO
--spa_Export_BankAsia 'Bank Transfer','2010-09-28 00:00:00:000','2011-09-28 23:59:59.999','1','AG:ranesh1','543sfsdfsdf1','Export_BankAsia','test=2&test=1'
CREATE PROCEDURE dbo.spa_Export_Commercial_Bank_of_Cylon
    @trn_type VARCHAR(50) = NULL ,
    @fromDate VARCHAR(50) = NULL ,
    @toDate VARCHAR(50) = NULL ,
    @check CHAR(1) = NULL ,
    @login_user_id VARCHAR(50) = NULL ,
    @process_id VARCHAR(100) = NULL ,
    @batch_id VARCHAR(100) = NULL ,
    @url_desc VARCHAR(5000) = NULL,
    @paymentType VARCHAR(50) = NULL
AS 
    SET NOCOUNT ON
    DECLARE @sql VARCHAR(MAX) ,
        @ledger_tabl VARCHAR(100) ,
        @expected_payoutagentid VARCHAR(50) ,
        @today VARCHAR(50) ,
        @msg_agenttype VARCHAR(200) ,
        @desc VARCHAR(5000),
        @total_amount MONEY,
        @total_row INT,@agent_name VARCHAR(100),@sequence VARCHAR(50),@accountNumber VARCHAR(50)
	-----------------------------------------------
    SET @expected_payoutagentid = '20100064'---LOCAL---'20100193' --- UAT ---
    SET @accountNumber='1030018143'
    SET @today = dbo.getDateHO(GETUTCDATE())
    SELECT @agent_name=CompanyName FROM dbo.agentDetail WHERE agentCode=@expected_payoutagentid
	-----------------------------------------------
	--------------------------------------------------
	------Creating the Temp Table Name----------------
    SET @ledger_tabl = dbo.FNAProcessTbl(@batch_id, REPLACE(@login_user_id,':','_'),
                                         @process_id)
	--------------------------------------------------


	--SELECT @per_day_count=COUNT(*) FROM dbo.message_board WHERE 
	--source=@batch_id--'Export_Century_Richtone_Ltd' 
	--AND dbo.CTGetdate(as_of_date)=dbo.CTGetdate(@toDate)
	--AND type='c'
	--GROUP by dbo.CTGetdate(as_of_date),source 
	

	 
    SET @sql = '
    SELECT  
        LEFT(dbo.decryptDb(m.refno),16) [REF_NO],
    LEFT('''+@accountNumber+''',10) [ACCOUNT_NO],
	CAST(m.TotalRoundAmt AS NUMERIC(15,2)) [AMOUNT],
	CAST(ISNULL(m.receiveCType,''LKR'') AS VARCHAR(3)) [CURRENCY],
	CASE WHEN m.paymentType=''Cash Pay'' THEN ''C'' WHEN m.paymentType IN (''Account Deposit'',''Bank Transfer'') THEN ''A''  ELSE ''O'' END [REM_TYPE],
	''S'' [CHG_FROM],
	LEFT(ISNULL(m.SenderName,''''),70) [CUST_NAME],
	LEFT(ISNULL(m.reason_for_remittance,''''),70) [DETAILS],
	LEFT(ISNULL(m.ReceiverName,''''),70) [BENE_NAME],
	LEFT(ISNULL(m.ReceiverAddress,''''),90) [BENE_ADDRESS],
	LEFT(ISNULL(m.receiver_mobile,''''),30) [BENE_TEL],
	LEFT(ISNULL(m.ReceiverID,''''),30) [BENE_ID_NO],
	LEFT(ISNULL(m.rBankACNo,''''),20) [BENE_ACCNO],
	LEFT(ISNULL(pa.ext_agent_code,''''),4) [BENE_BANK_CODE],
	LEFT(ISNULL(b.ext_branch_code,''''),3) [BENE_BRANCH_CODE],
	'''' [BANK_TO_BANK_INFO]
    INTO    ' + @ledger_tabl
        + '
    FROM    moneysend m WITH ( NOLOCK )
    JOIN dbo.agentDetail pa WITH ( NOLOCK ) ON m.expected_payoutagentid=pa.agentCode
            LEFT OUTER JOIN agentbranchdetail b WITH ( NOLOCK ) ON m.rBankID = b.agent_branch_code
      JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid       
    WHERE  ISNULL(a.disable_payout,''n'')<>''y'' AND expected_payoutagentid = ''' + @expected_payoutagentid + '''
            AND Transstatus = ''Payment'''
    IF @paymentType IS NULL
       SET @sql = @sql + ' AND m.paymentType in (''Account Deposit'',''Bank Transfer'',''Cash Pay'')'
    ELSE
	   SET @sql = @sql + ' AND m.paymentType ='''+@paymentType+''''
--    IF @trn_type IS NOT NULL 
--        SET @sql = @sql + ' AND m.paymentType=''' + @trn_type + ''''
--    ELSE
--		 SET @sql = @sql + ' AND m.paymentType not in (''Cash Pay'')'
    IF @check IS NOT NULL 
        BEGIN
            SET @sql = @sql + ' AND m.confirmDate BETWEEN ''' + @fromDate
                + ''' AND ''' + @toDate + '''
							AND m.status IN (''Paid'')'
        END     
    ELSE 
        BEGIN
            SET @sql = @sql + ' AND m.status=''Un-Paid'' 
            
						UPDATE  dbo.moneySend
						SET     status=''Post'',
								is_downloaded = ''y'' ,
								downloaded_by = ''' + @login_user_id + ''' ,
								downloaded_ts = ''' + @today + '''
						FROM    moneysend m WITH ( NOLOCK ) 
								JOIN ' + @ledger_tabl
							+ ' t WITH ( NOLOCK ) ON m.refno = dbo.encryptDb(t.[REF_NO])
							  JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid 
				WHERE	ISNULL(a.disable_payout,''n'')<>''y'''
        END 
         SET @sql = @sql + ' INSERT #temp_total_amount(total_amount,total_row) SELECT sum([AMOUNT]),count(REF_NO) FROM ' + @ledger_tabl
        CREATE TABLE #temp_total_amount(total_amount MONEY,total_row int )  
		
 --PRINT @sql            
   EXEC (@sql)
    
    -----------------------------------------Bulk Payment------------------------------------------------
--IF @check IS NULL
--BEGIN

--		declare 
--			@rBankID varchar(50),
--			@branch_id varchar(50),  
--			@rBankName varchar(200), 
--			@rBankBranch varchar(200), 
--			@GMT_Date datetime,
--			@cover_fund money,
--			@payout_fund_limit char(1)  
			
--			SELECT top 1 @branch_id =agent_branch_code FROM agentbranchdetail a WHERE a.agentCode=@expected_payoutagentid 
--			                                        ORDER BY a.isHeadOffice DESC
--		IF @branch_id IS NOT NULL
--		BEGIN
			
--			select @rBankID=b.agent_branch_code,@rBankName=a.companyName, @rBankBranch=b.Branch,  
--			@GMT_Date=dateadd(mi,isNUll(gmt_value,345),getutcdate()),@cover_fund=a.currentBalance-isNull(Account_No_IB,0)  
--			from agentdetail a  WITH(NOLOCK)  join agentbranchdetail b  WITH(NOLOCK)  on a.agentcode=b.agentcode where agent_branch_code=@branch_id  

--			delete [temp_trn_csv_pay] where digital_id_payout=@ledger_tabl  
			  
--			set @sql='INSERT INTO [temp_trn_csv_pay]  
--			([tranno],[refno],[ReceiverName],[TotalRoundAmt],[paidDate],[paidBy],[expected_payoutagentid],  
--			[rBankID],[rBankName],[rBankBranch],[digital_id_payout])  
--			select tranno,refno,receiverName,totalRoundAmt,'''+convert(varchar,@GMT_Date,120)+''','''+@login_user_id+''',  
--			'''+@expected_payoutagentid+''','''+@rBankID+''','''+@rBankName+''','''+@rBankBranch+''','''+@ledger_tabl+'''   
--									FROM    moneysend m WITH(NOLOCK) 
--								JOIN ' + @ledger_tabl
--							+ ' t WITH ( NOLOCK ) ON m.refno = dbo.encryptDb(t.[Ref_no]) JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid WHERE ISNULL(a.disable_payout,''n'')<>''y''' 
--			--print @sql  
--			exec(@sql)  
			  
--			--print ('spa_make_bulk_payment_csv '''+@ledger_tabl+''',NULL,''y''')  
--			exec ('spa_make_bulk_payment_csv '''+@ledger_tabl+''',NULL,''y''') 
--		END
--END 
------------------------------------------------------------------------------------------------

  SELECT  @total_amount = total_amount,@total_row = total_row           
  FROM    #temp_total_amount 
  
	SET @msg_agenttype=' '
	--SET @url_desc=ISNULL(@url_desc,'Null')
           
    IF @check IS NOT NULL
		BEGIN
 			SET @sequence='ReDownloaded'
			SET @msg_agenttype = ' From: ' + @fromDate + ' To: ' + @toDate + ' (Re-Downloaded)'    	
		END 
    ELSE
		BEGIN
			SET @msg_agenttype = ' Till ' + @today
			SELECT @sequence=dbo.FNAExportSequenceNumber(@expected_payoutagentid)
		END
		 
		SET @url_desc='Sequence=' + @sequence+ '&'  
		if @paymentType is null
			set @paymentType='ALL'
            
    SET @desc = '<strong><u>'+@agent_name+' DOWNLOAD</u></strong> '          
            + ' is completed.  TXN Found: <strong><u>'          
            + CAST(ISNULL(@total_row, 0) AS VARCHAR) + '</u></strong>  Total Amount: <strong><u>'          
            + CAST(ISNULL(@total_amount, 0) AS VARCHAR)+ '</u></strong> Payment Type: <strong><u>'          
            + @paymentType+ '</u></strong> '  + @msg_agenttype 
       --SELECT @paymentType
       --RETURN
    PRINT 'spa_message_board ''u'', '''+@login_user_id+''', NULL,'''+ @batch_id+''','''+ @desc+''', ''c'',
        '''+@process_id+''', NULL,'+ ISNULL(@url_desc,'Null')
    EXEC spa_message_board 'u', @login_user_id, NULL, @batch_id, @desc, 'c',
        @process_id, NULL, @url_desc
------------------------------------------------------------------------------------------------