IF OBJECT_ID('spa_Export_Soneri_Bank', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.spa_Export_Soneri_Bank
GO
--spa_Export_BankAsia 'Bank Transfer','2010-09-28 00:00:00:000','2011-09-28 23:59:59.999','1','AG:ranesh1','543sfsdfsdf1','Export_BankAsia','test=2&test=1'
CREATE PROCEDURE dbo.spa_Export_Soneri_Bank
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
        @total_row INT,@agent_name VARCHAR(100),@sequence VARCHAR(50),@CompanyCode VARCHAR(10)
	-----------------------------------------------
    SET @expected_payoutagentid = '20100064'--LOCAL--'20100186 '--UAT--''---Live
    SET @today = dbo.getDateHO(GETUTCDATE())
     SET @CompanyCode='PRBH'
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
	 '''+@CompanyCode+''' [Company Code],
    LEFT(dbo.decryptDb(m.refno),20) [TRANSACTION Refer no],
	LEFT(ISNULL(m.SenderName,''''),30) [Remitter NAME],
	CONVERT(VARchar ,isnull(confirmDate,GETDATE()),3) [REMITTANCEDATE],
	LEFT(ISNULL(m.ReceiverName,''''),30) [BENEFICIRY NAME],
	CAST(m.TotalRoundAmt AS NUMERIC(14,2)) [LCY AMOUNT],
	LEFT(ISNULL(m.rBankACNo,''''),20) [BEN. ACCOUNT*],
	LEFT(ISNULL(b.ext_branch_code,''''),4) [BEN. Bank BRANCH CODE],
	LEFT(ISNULL(m.sender_mobile,''''),14) [BEN.CONTACT NO],
	m.rBankName [BEN. BR ADDRESS L1],
	LEFT(ISNULL(m.rBankBranch,''''),30) [BEN.  BR ADDRESS L2],
	LEFT(ISNULL(b.address,''''),30) [BEN. BR ADDRESS L3],
	LEFT(ISNULL(m.receiveCType,''''),3) [Currency Code]
    INTO    ' + @ledger_tabl
        + '
    FROM    moneysend m WITH ( NOLOCK )
            LEFT OUTER JOIN agentbranchdetail b WITH ( NOLOCK ) ON m.rBankID = b.agent_branch_code
            JOIN agentdetail a WITH ( NOLOCK ) ON a.agentCode = m.agentid
    WHERE ISNULL(a.disable_payout, ''n'') <> ''y''  AND  expected_payoutagentid = ''' + @expected_payoutagentid + '''
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
							AND m.status IN (''Paid'',''Post'')'
        END     
    ELSE 
        BEGIN
            SET @sql = @sql + ' AND m.status=''Un-Paid'' 
            
						UPDATE  dbo.moneySend
						SET     status=''Post'',
								is_downloaded = ''y'' ,
								downloaded_by = ''' + @login_user_id + ''' ,
								downloaded_ts = ''' + @today + '''
						FROM    moneysend m
								JOIN ' + @ledger_tabl
							+ ' t ON m.refno = dbo.encryptDb(t.[TRANSACTION Refer no])
					'
        END 
         SET @sql = @sql + ' INSERT #temp_total_amount(total_amount,total_row) SELECT sum([LCY AMOUNT]),count([TRANSACTION Refer no]) FROM ' + @ledger_tabl
        CREATE TABLE #temp_total_amount(total_amount MONEY,total_row int )  
		
  --PRINT @sql            
    EXEC (@sql)
    
--    -----------------------------------------Bulk Payment------------------------------------------------
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
--							+ ' t ON m.refno = dbo.encryptDb(t.[TRANSACTION Refer no])' 
--			--print @sql  
--			exec(@sql)  
			  
--			--print ('spa_make_bulk_payment_csv '''+@ledger_tabl+''',NULL,''y''')  
--			exec ('spa_make_bulk_payment_csv '''+@ledger_tabl+''',NULL,''y''') 
--		END
--END 
--------------------------------------------------------------------------------------------------

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
       
    PRINT 'spa_message_board ''u'', '''+@login_user_id+''', NULL,'''+ @batch_id+''','''+ @desc+''', ''c'',
        '''+@process_id+''', NULL,'+ ISNULL(@url_desc,'Null')
    EXEC spa_message_board 'u', @login_user_id, NULL, @batch_id, @desc, 'c',
        @process_id, NULL, @url_desc
------------------------------------------------------------------------------------------------