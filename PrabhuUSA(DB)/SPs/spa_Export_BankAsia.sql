IF OBJECT_ID('spa_Export_BankAsia', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.spa_Export_BankAsia
GO
--spa_Export_BankAsia 'Bank Transfer','2010-09-28 00:00:00:000','2011-09-28 23:59:59.999','1','AG:ranesh1','543sfsdfsdf1','Export_BankAsia','test=2&test=1'
CREATE PROCEDURE dbo.spa_Export_BankAsia
    @trn_type VARCHAR(50) = NULL ,
    @fromDate VARCHAR(50) = NULL ,
    @toDate VARCHAR(50) = NULL ,
    @check CHAR(1) = NULL ,
    @login_user_id VARCHAR(50) = NULL ,
    @process_id VARCHAR(100) = NULL ,
    @batch_id VARCHAR(100) = NULL ,
    @url_desc VARCHAR(5000) = NULL
AS 
    SET NOCOUNT ON
    DECLARE @sql VARCHAR(MAX) ,
        @ledger_tabl VARCHAR(100) ,
        @expected_payoutagentid VARCHAR(50) ,
        @today VARCHAR(50) ,
        @msg_agenttype VARCHAR(200) ,
        @desc VARCHAR(5000),
        @total_amount MONEY,
        @total_row INT
	-----------------------------------------------
    SET @expected_payoutagentid = '20100066'--'20100095'--'33300137'
    SET @today = dbo.getDateHO(GETUTCDATE())
	-----------------------------------------------
	--------------------------------------------------
	------Creating the Temp Table Name----------------
    SET @ledger_tabl = dbo.FNAProcessTbl(@batch_id, REPLACE(@login_user_id,':','_'),
                                         @process_id)
	--------------------------------------------------
	
    SET @sql = '
    SELECT  row_number() over(ORDER BY m.Tranno) [Sl_No] ,
            CAST(dbo.decryptdb(m.refno) AS VARCHAR) [TT_No] ,
            REPLACE(CONVERT(VARCHAR,m.confirmDate,102),''.'',''-'') [Date] ,
            CAST(m.TotalRoundAmt AS VARCHAR) [Amount] ,
            REPLACE(m.ReceiverName, '','', ''-'') [Beneficiary] ,
            CAST(isNull(''A/C-''+m.rBankACNo,'''') AS VARCHAR)[AC_No] ,
            CASE WHEN paymentType=''Bank Transfer'' THEN m.rBankName ELSE m.ben_bank_name END [Bank] ,
            CASE WHEN paymentType=''Bank Transfer'' THEN 
            REPLACE(ISNULL(b.Branch, '''') + ''-'' + ISNULL(b.City, ''''), '','', ''-'')
			ELSE m.rBankAcType END [Branch] ,
            NULL [City] ,
            REPLACE(m.SenderName, '','', ''-'') [Remitter] ,
            REPLACE(ISNULL(m.SenderAddress, '''') + ISNULL(''-'' + m.SenderCity,
                                                         '''') + ISNULL(''-''
                                                              + m.SenderCountry,
                                                              ''''), '','', ''-'') [City_remitter] ,
            NULL [Amount_words] ,
            ISNULL(m.receiver_mobile, m.CustomerId) [Cont_Benef]
    INTO    ' + @ledger_tabl
        + '
    FROM    moneysend m WITH ( NOLOCK )
            LEFT OUTER JOIN agentbranchdetail b WITH ( NOLOCK ) ON m.rBankID = b.agent_branch_code
            JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid 
    WHERE   ISNULL(a.disable_payout,''n'')<>''y'' AND expected_payoutagentid = ''' + @expected_payoutagentid + '''
            AND Transstatus = ''Payment'' '
       SET @sql = @sql + ' AND m.paymentType in (''Account Deposit to Other Bank'',''Bank Transfer'')'
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
						FROM    moneysend m WITH(NOLOCK) 
								JOIN ' + @ledger_tabl
							+ ' t WITH(NOLOCK) ON m.refno = dbo.encryptDb(t.[TT_No])
							JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid 
					WHERE ISNULL(a.disable_payout,''n'')<>''y'''
        END 
         SET @sql = @sql + ' INSERT #temp_total_amount(total_amount,total_row) SELECT sum(CAST(Amount as money)),count(*) FROM ' + @ledger_tabl
        CREATE TABLE #temp_total_amount(total_amount MONEY,total_row int )  
		
    PRINT @sql            
    EXEC (@sql)
-----------------------------------------Bulk Payment------------------------------------------------
IF @check IS NULL 
BEGIN
		declare 
			@rBankID varchar(50),
			@branch_id varchar(50),  
			@rBankName varchar(200), 
			@rBankBranch varchar(200), 
			@GMT_Date datetime,
			@cover_fund money,
			@payout_fund_limit char(1)  
			
			SELECT top 1 @branch_id =agent_branch_code FROM agentbranchdetail a WHERE a.agentCode=@expected_payoutagentid 
			                                        ORDER BY a.isHeadOffice DESC
		IF @branch_id IS NOT NULL
		BEGIN
			
			select @rBankID=b.agent_branch_code,@rBankName=a.companyName, @rBankBranch=b.Branch,  
			@GMT_Date=dateadd(mi,isNUll(gmt_value,345),getutcdate()),@cover_fund=a.currentBalance-isNull(Account_No_IB,0)  
			from agentdetail a join agentbranchdetail b on a.agentcode=b.agentcode where agent_branch_code=@branch_id  

			delete [temp_trn_csv_pay] where digital_id_payout=@ledger_tabl  
			  
			set @sql='INSERT INTO [temp_trn_csv_pay]  
			([tranno],[refno],[ReceiverName],[TotalRoundAmt],[paidDate],[paidBy],[expected_payoutagentid],  
			[rBankID],[rBankName],[rBankBranch],[digital_id_payout])  
			select tranno,refno,receiverName,totalRoundAmt,'''+convert(varchar,@GMT_Date,120)+''','''+@login_user_id+''',  
			'''+@expected_payoutagentid+''','''+@rBankID+''','''+@rBankName+''','''+@rBankBranch+''','''+@ledger_tabl+'''   
									FROM    moneysend m WITH(NOLOCK) 
								JOIN ' + @ledger_tabl
							+ ' t WITH(NOLOCK) ON m.refno = dbo.encryptDb(t.[TT_No])
							JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid 
							WHERE ISNULL(a.disable_payout,''n'')<>''y''' 
			print @sql  
			exec(@sql)  
			  
			print ('spa_make_bulk_payment_csv '''+@ledger_tabl+''',NULL,''y''')  
			exec ('spa_make_bulk_payment_csv '''+@ledger_tabl+''',NULL,''y''') 
		END
END 
------------------------------------------------------------------------------------------------
  SELECT  @total_amount = total_amount,@total_row = total_row           
  FROM    #temp_total_amount 
  
	SET @msg_agenttype=' '
	SET @url_desc=ISNULL(@url_desc,'Null')
            
    IF @check IS NOT NULL 
        SET @msg_agenttype = ' From: ' + @fromDate + ' To: ' + @toDate + ' (Re-Downloaded)' 
    ELSE
		SET @msg_agenttype = ' Till ' + @today 
            
    SET @desc = '<strong><u>Bank Asia DOWNLOAD</u></strong> '          
            + ' is completed.  TXN Found: <strong><u>'          
            + CAST(ISNULL(@total_row, 0) AS VARCHAR) + '</u></strong>  Total Amount: <strong><u>'          
            + CAST(ISNULL(@total_amount, 0) AS VARCHAR)+ '</u></strong> '  + @msg_agenttype 

    PRINT 'spa_message_board ''u'', '''+@login_user_id+''', NULL,'''+ @batch_id+''','''+ @desc+''', ''c'',
        '''+@process_id+''', NULL,'+ ISNULL(@url_desc,'Null')
    EXEC spa_message_board 'u', @login_user_id, NULL, @batch_id, @desc, 'c',
        @process_id, NULL, @url_desc
------------------------------------------------------------------------------------------------